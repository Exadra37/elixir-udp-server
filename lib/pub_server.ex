defmodule UdpServer.PubSubServer do

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, []) # Start 'er up
    # |> IO.inspect(label: 'PubSubServer.start_link/1')
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  def init(_args) do
    Phoenix.PubSub.subscribe(UdpServer.PubSub, "udp:server")
    # |> IO.inspect(label: 'PubSubServer.init/1')
    {:ok, {}}
  end

  def handle_info({:packet, packet} = data, state) do
    # state = [data | state]
    # punt the data to a new function that will do pattern matching
    IO.inspect(data, label: "PubSubServer.handle_info/2 {:packet, packet} = data")
    # IO.inspect(state, label: "PubSubServer.handle_info/2 state")

    HamMessageParser.parse(packet)
    |> IO.inspect()

    {:noreply, state}
  end

  def handle_info(data, state) do
    state = [data | state]
    # punt the data to a new function that will do pattern matching
    IO.inspect(data, label: "PubSubServer.handle_info/2 data")
    IO.inspect(state, label: "PubSubServer.handle_info/2 state")

    {:noreply, state}
  end

  def handle_call(data, from, state) do
    # punt the data to a new function that will do pattern matching
    IO.inspect(data, label: "PubSubServer.handle_call/2")
    IO.inspect(from, label: "PubSubServer.handle_call/2")
    {:noreply, state}
  end

end
