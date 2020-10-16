defmodule Exib.Trader do

  def options_scalper(symbol, strike) do
    # Step 1: Get contract ID for stock and first opt month
    [%{"conid" => conid, "sections" => sections} | _] = Exib.Api.search_contract(symbol)
    [_ | tl] = sections
    [%{"months" => months} | _] = tl
    [first_month | _] = String.split(months, ";")
    # Step 3: Get contract IDs for options
    [call | [put | _]] = Exib.Api.get_options_contracts(conid, first_month, strike)
    %{"conid" => call_conid} = call
    %{"conid" => put_conid} = put
    # Build orders
    call_order = Exib.Order.market_order(call_conid, "BUY", 1)
    put_order = Exib.Order.market_order(put_conid, "SELL", 1)
    buy_OID = UUID.uuid4()
    sell_OID = UUID.uuid4()
    underlying_buy = Exib.Order.limit_order(conid, "BUY", 30, strike-1, buy_OID)
    underlying_sell = Exib.Order.limit_order(conid, "SELL", 30, strike+1, sell_OID)
    underlying_buy_close_raw = Exib.Order.limit_order(conid, "SELL", 30, strike)
    underlying_buy_close = Exib.Order.set_parent(underlying_buy_close_raw, buy_OID)
    underlying_sell_close_raw = Exib.Order.limit_order(conid, "BUY", 30, strike)
    underlying_sell_close = Exib.Order.set_parent(underlying_sell_close_raw, sell_OID)
    orders = [call_order, put_order, underlying_sell, underlying_buy, underlying_buy_close, underlying_sell_close]
    #orders
    #  |> Enum.map(&Exib.Api.preview_order/1)
    #  |> Jason.encode!
    #  |> IO.puts
    orders
      |> Enum.map(&Exib.Api.place_and_confirm/1)
    #Exib.Api.place_orders(orders)
  end
end
