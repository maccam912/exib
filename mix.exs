defmodule Exib.MixProject do
  use Mix.Project

  def project do
    [
      app: :exib,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Exib.Application, []},
      env: [baseurl: "https://localhost:5000/v1/portal", options: [ssl: [{:verify, :verify_none}], recv_timeout: 10000]]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"}
    ]
  end
end
