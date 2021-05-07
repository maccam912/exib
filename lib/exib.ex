defmodule Exib do
  @moduledoc """
  Documentation for `Exib`.
  """

  def baseurl() do
    Application.fetch_env!(:exib, :baseurl)
  end

  def options() do
    Application.fetch_env!(:exib, :options)
  end
end
