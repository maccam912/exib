defmodule ExibTest do
  use ExUnit.Case
  doctest Exib

  test "tickle" do
    %HTTPoison.Response{status_code: sc} = Exib.Api.tickle()
    assert sc == 200
  end

  test "sso" do
    assert Exib.Api.sso_validate()
  end

  test "check auth" do
    assert Exib.Api.check_auth()
  end

  test "accounts" do
    accounts = Exib.Api.get_accounts()
    assert length(accounts) > 0
  end

  test "subaccounts" do
    accounts = Exib.Api.get_subaccounts()
    assert accounts
  end

  test "account info" do
    single_acct = Exib.Api.get_account_info()
    [first_acct | _] = Exib.Api.get_accounts()
    single_acct = Map.put(single_acct, "covestor", false)
    assert Map.equal?(single_acct, first_acct)
  end

  test "account summary" do
    %{"availablefunds" => %{"amount" => amt}} = Exib.Api.get_account_summary()
    assert amt > 0
  end

  test "account ledger" do
    %{"BASE" => %{"cashbalance" => amt}} = Exib.Api.get_account_ledger()
    assert amt > 0
  end

  test "account allocation" do
    %{"assetClass" => %{"long" => %{"CASH" => cash}}} = Exib.Api.get_account_allocation()
    assert cash > 0
  end

  test "account positions" do
    [%{"mktValue" => mktValue} | _] = Exib.Api.get_account_positions()
    assert mktValue != 0
  end

  test "search" do
    [%{"conid" => conid} | _] = Exib.Api.search_contract("AMD")
    assert conid == 4391
  end

  test "history" do
    [%{"c" => last_price} | _] = Exib.Api.get_history_from_symbol("AMD")
    assert last_price < 1000
    assert last_price > 0
  end
end
