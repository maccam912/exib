defmodule Exib.OldWs do
use WebSockex

def subscribe(conid) do
  WebSockex.send_frame(__MODULE__, {:binary, "smd+#{conid}+{\"fields\":[\"31\",\"83\"]}"})
end

def start_link(state) do
  WebSockex.start_link("wss://localhost:5000/v1/api/ws", __MODULE__, state, name: __MODULE__, debug: [:trace])
end

def handle_ibkr(%{"hb" => _}, state) do
  # Ignore
  {:ok, state}
end

def handle_ibkr(%{"success" => _username}, state) do
  IO.puts "Logged in."
  {:ok, state}
end

def handle_ibkr(%{"args" => %{"authenticated" => true}}, state) do
  IO.puts "Authenticated"
  {:ok, state}
end

def handle_frame({:binary, payload}, state) do
  msg = Jason.decode!(payload)
  handle_ibkr(msg, state)
end

def handle_frame({type, msg}, state) do
  IO.puts "Unrecognized: Type: #{inspect type} -- Message: #{inspect msg}"
  {:ok, state}
end

def handle_cast({:send, {type, msg} = frame}, state) do
  IO.puts "Sending #{type} frame with payload: #{msg}"
  {:reply, frame, state}
end

end
