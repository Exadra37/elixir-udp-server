defmodule UdpServer.PubSubSubscriber do

  use GenServer

  def start_link(args) do
    IO.inspect args, label: "args"
    GenServer.start_link(__MODULE__, [], name: __MODULE__) # Start 'er up
    # |> IO.inspect(label: 'PubSubServer.start_link/1')
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  def init(_args) do
    Phoenix.PubSub.subscribe(UdpServer.PubSub, "udp:server")
    # |> IO.inspect(label: 'PubSubServer.init/1')
    {:ok, []}
  end

  def handle_info({:packet, packet} = data, state) do
    state = [data | state]

    HamMessageParser.parse(packet)
    |> IO.inspect(label: ":packet parsed")

    {:noreply, state}
  end

  def handle_info({:start_link, _process} = data, state) do
    state = [data | state]

    IO.inspect(data, label: ":start_link data")
    IO.inspect(state, label: ":start_link state")

    {:noreply, state}
  end

  def handle_info({:init, _process} = data, state) do
    state = [data | state]

    IO.inspect(data, label: ":init data")
    IO.inspect(state, label: ":init state")

    {:noreply, state}
  end

  def handle_info({:close, _process} = data, state) do
    state = [data | state]

    IO.inspect(data, label: ":close data")
    IO.inspect(state, label: ":close state")

    {:noreply, state}
  end

  def handle_call(:state, from, state) do
    IO.inspect(from, label: "handle_call/2 from")
    {:reply, state, state}
  end

end
