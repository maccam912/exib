defmodule Exib.OptionProtection do
  use GenServer

  @refreshInterval 60000

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link({symbol, strike, side}) do
    resp = GenServer.start_link(__MODULE__, {symbol, strike, side, :flat}, name: __MODULE__)
    GenServer.cast(__MODULE__, :monitor)
    resp
  end

  def handle_info(:monitor, state) do
    handle_cast(:monitor, state)
  end

  def handle_cast(:monitor, {symbol, strike, :buy, :flat}) do
    [%{"c" => last_price} | _] = Exib.Api.get_history_from_symbol(symbol)
    IO.puts("waiting to buy")
    IO.puts(last_price)

    if last_price > strike do
      [%{"conid" => conid} | _] = Exib.Api.search_contract(symbol)
      order = Exib.Order.market_order(conid, "BUY", 100)
      Exib.Api.place_and_confirm(order)
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :buy, :long}}
    else
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :buy, :flat}}
    end
  end

  def handle_cast(:monitor, {symbol, strike, :buy, :long}) do
    [%{"c" => last_price} | _] = Exib.Api.get_history_from_symbol(symbol)
    IO.puts("waiting to re-sell")
    IO.puts(last_price)

    if last_price < strike do
      [%{"conid" => conid} | _] = Exib.Api.search_contract(symbol)
      order = Exib.Order.market_order(conid, "SELL", 100)
      Exib.Api.place_and_confirm(order)
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :buy, :flat}}
    else
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :buy, :long}}
    end
  end

  def handle_cast(:monitor, {symbol, strike, :sell, :flat}) do
    [%{"c" => last_price} | _] = Exib.Api.get_history_from_symbol(symbol)
    IO.puts("waiting to sell")
    IO.puts(last_price)

    if last_price < strike do
      [%{"conid" => conid} | _] = Exib.Api.search_contract(symbol)
      order = Exib.Order.market_order(conid, "SELL", 100)
      Exib.Api.place_and_confirm(order)
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :sell, :short}}
    else
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :sell, :flat}}
    end
  end

  def handle_cast(:monitor, {symbol, strike, :sell, :short}) do
    [%{"c" => last_price} | _] = Exib.Api.get_history_from_symbol(symbol)
    IO.puts("waiting to re-buy")
    IO.puts(last_price)

    if last_price > strike do
      [%{"conid" => conid} | _] = Exib.Api.search_contract(symbol)
      order = Exib.Order.market_order(conid, "BUY", 100)
      Exib.Api.place_and_confirm(order)
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :sell, :flat}}
    else
      Process.send_after(self(), :monitor, @refreshInterval)
      {:noreply, {symbol, strike, :sell, :short}}
    end
  end
end
