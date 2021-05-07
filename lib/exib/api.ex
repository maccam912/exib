defmodule Exib.Api do
  def ib_api_caller(endpoint) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!("#{Exib.baseurl()}/#{endpoint}", [], Exib.options())

    {:ok, decoded} = Jason.decode(body)
    decoded
  end

  def ib_api_caller_post(endpoint) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.post!("#{Exib.baseurl()}/#{endpoint}", "", [], Exib.options())

    {:ok, decoded} = Jason.decode(body)
    decoded
  end

  def ib_api_caller(endpoint, payload) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.post!(
        "#{Exib.baseurl()}/#{endpoint}",
        Jason.encode!(payload),
        [{"content-type", "application/json"}],
        Exib.options()
      )

    {:ok, decoded} = Jason.decode(body)
    decoded
  end

  def tickle() do
    HTTPoison.get!("#{Exib.baseurl()}/tickle", [], Exib.options())
  end

  def sso_validate() do
    %HTTPoison.Response{status_code: sc} =
      HTTPoison.get!("#{Exib.baseurl()}/sso/validate", [], Exib.options())

    sc == 200
  end

  def check_auth() do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!("#{Exib.baseurl()}/iserver/auth/status", [], Exib.options())

    %{"authenticated" => authenticated} = Jason.decode!(body)
    authenticated
  end

  def reauthenticate() do
    ib_api_caller_post("/iserver/reauthenticate")
  end

  def get_accounts() do
    ib_api_caller("portfolio/accounts")
  end

  def get_subaccounts() do
    ib_api_caller("portfolio/subaccounts")
  end

  def get_account_info() do
    ib_api_caller("portfolio/#{Exib.AccountServ.id()}/meta")
  end

  def get_account_summary() do
    ib_api_caller("portfolio/#{Exib.AccountServ.id()}/summary")
  end

  def get_account_ledger() do
    ib_api_caller("portfolio/#{Exib.AccountServ.id()}/ledger")
  end

  def get_account_allocation() do
    ib_api_caller("portfolio/#{Exib.AccountServ.id()}/allocation")
  end

  def get_account_positions() do
    page = 0
    ib_api_caller("portfolio/#{Exib.AccountServ.id()}/positions/#{page}")
  end

  def search_contract(symbol) do
    ib_api_caller("iserver/secdef/search", %{"symbol" => symbol})
  end

  def get_history_from_symbol(symbol) do
    [%{"conid" => conid} | _] = ib_api_caller("iserver/secdef/search", %{"symbol" => symbol})
    get_history_from_contract(conid)
  end

  def get_history_from_contract(conid) do
    %{"data" => data} =
      ib_api_caller("iserver/marketdata/history?conid=#{conid}&period=1y&bar=1d&outsideRth=true")

    data
    |> Stream.map(fn candle ->
      %{candle | "t" => DateTime.from_unix!(Map.get(candle, "t"), :millisecond)}
    end)
    |> Enum.to_list()
  end

  def get_options_contracts(conid, month, strike) do
    contract_ids =
      ib_api_caller(
        "iserver/secdef/info?conid=#{conid}&sectype=OPT&month=#{month}&strike=#{strike}"
      )

    contract_ids
  end

  def get_orders() do
    ib_api_caller("iserver/account/orders")
  end

  def preview_order(order) do
    ib_api_caller("iserver/account/#{Exib.AccountServ.id()}/order/whatif", order)
  end

  def place_order(order) do
    IO.puts(Jason.encode!(order))
    response = ib_api_caller("iserver/account/#{Exib.AccountServ.id()}/order", order)
    IO.puts(Jason.encode!(response))
    response
  end

  def place_orders(orders) do
    ib_api_caller("iserver/account/#{Exib.AccountServ.id()}/orders", %{"orders" => orders})
  end

  def reply_to_messages(replyid) do
    IO.puts(replyid)
    ib_api_caller("iserver/reply/#{replyid}", %{"confirmed" => true})
  end

  def place_and_confirm(order) do
    [details | _] = Exib.Api.place_order(order)
    %{"id" => id} = details
    reply = Exib.Api.reply_to_messages(id)
    {:ok, details, reply}
  end
end
