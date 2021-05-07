defmodule Exib.AccountServ do
  use GenServer

  @refreshInterval 30000

  def id() do
    GenServer.call(__MODULE__, :account)
  end

  def refresh() do
    GenServer.cast(__MODULE__, :refresh)
  end

  def start_link(_arg) do
    resp = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    GenServer.cast(__MODULE__, :refresh)
    GenServer.cast(__MODULE__, :tickle)
    resp
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:account, _from, st) do
    %{:accountId => accountId} = st
    {:reply, accountId, st}
  end

  def handle_cast(:refresh, _st) do
    [%{"accountId" => accountId} | _] = Exib.Api.get_accounts()
    {:noreply, %{:accountId => accountId}}
  end

  def handle_cast(:tickle, st) do
    Exib.Api.reauthenticate()
    Process.send_after(self(), :tickle, @refreshInterval)
    {:noreply, st}
  end

  def handle_info(:tickle, st) do
    handle_cast(:tickle, st)
  end
end
