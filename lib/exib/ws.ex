defmodule Exib.Ws do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, ConnPid} = :gun.open("localhost:5000/v1/api/ws", 443)
    {:ok, Protocol} = :gun.await_up(ConnPid)
    {:ok, %{}}
  end

end
