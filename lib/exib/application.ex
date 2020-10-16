defmodule Exib.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Exib.Worker.start_link(arg)
      # {Exib.Worker, arg}
      {Exib.AccountServ, []},
      #%{
      #  id: Exib.AccountServ,
      #  start: {Exib.AccountServ, :init, [%{}]}
      # }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exib.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
