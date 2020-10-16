    defmodule Exib.Api do

    def ib_api_caller(endpoint) do
      %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!("#{Exib.baseurl()}/#{endpoint}", [], Exib.options())
      {:ok, decoded} = Jason.decode(body)
      decoded
    end

    def ib_api_caller(endpoint, payload) do
      %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.post!("#{Exib.baseurl()}/#{endpoint}", Jason.encode!(payload), [{"content-type", "application/json"}], Exib.options())
      {:ok, decoded} = Jason.decode(body)
      decoded
    end

    def tickle() do
      HTTPoison.get!("#{Exib.baseurl()}/tickle", [], Exib.options())
    end

    def sso_validate() do
      %HTTPoison.Response{status_code: sc} = HTTPoison.get!("#{Exib.baseurl()}/sso/validate", [], Exib.options())
      sc == 200
    end

    def check_auth() do
      %HTTPoison.Response{body: body} = HTTPoison.get!("#{Exib.baseurl()}/iserver/auth/status", [], Exib.options())
      %{"authenticated" => authenticated} = Jason.decode!(body)
      authenticated
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

    def get_history(symbol) do
      [%{"conid" => conid} | _] = ib_api_caller("iserver/secdef/search", %{"symbol" => symbol})
      %HTTPoison.Response{body: body} = HTTPoison.get!("#{Exib.baseurl()}/iserver/marketdata/history?conid=#{conid}&period=1min", [], Exib.options())
      %{"data" => data} = Jason.decode!(body)
      data
    end

    def get_orders() do
      ib_api_caller("iserver/account/orders")
    end
end
