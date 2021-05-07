defmodule Exib.Trader do
  def options_scalper(symbol, strike, bracket_amount) do
    # Step 1: Get contract ID for stock and first opt month
    [%{"conid" => conid, "sections" => sections} | _] = Exib.Api.search_contract(symbol)
    [_ | tl] = sections
    [%{"months" => months} | _] = tl
    [first_month | _] = String.split(months, ";")
    # Step 3: Get contract IDs for options
    [call | [put | _]] = Exib.Api.get_options_contracts(conid, first_month, strike)
    %{"conid" => call_conid} = call
    %{"conid" => put_conid} = put

    # Open straddle
    call_order = Exib.Order.market_order(call_conid, "BUY", 1)
    put_order = Exib.Order.market_order(put_conid, "BUY", 1)
    [call_order, put_order] |> Enum.map(&Exib.Api.place_and_confirm/1)

    buy_OID = UUID.uuid4()
    sell_OID = UUID.uuid4()
    underlying_buy = Exib.Order.limit_order(conid, "BUY", 30, strike - bracket_amount, buy_OID)
    underlying_sell = Exib.Order.limit_order(conid, "SELL", 30, strike + bracket_amount, sell_OID)

    underlying_buy_close_raw = Exib.Order.limit_order(conid, "SELL", 30, strike)
    underlying_buy_close = Exib.Order.set_parent(underlying_buy_close_raw, buy_OID)
    underlying_sell_close_raw = Exib.Order.limit_order(conid, "BUY", 30, strike)
    underlying_sell_close = Exib.Order.set_parent(underlying_sell_close_raw, sell_OID)

    buyside = [underlying_buy, underlying_buy_close]
    [%{"id" => id} | _] = Exib.Api.place_orders(buyside)
    Exib.Api.reply_to_messages(id)

    sellside = [underlying_sell, underlying_sell_close]
    [%{"id" => id} | _] = Exib.Api.place_orders(sellside)
    Exib.Api.reply_to_messages(id)
    :ok
  end
end
