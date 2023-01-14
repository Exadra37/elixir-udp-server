defmodule UdpServer do
  # Our module is going to use the DSL (Domain Specific Language) for Gen(eric) Servers
  use GenServer

  defstruct [
    opts: %{port: 2052, pubsub: nil, agent: nil},
    pid: nil,
    socket: nil,
    packets: [],
    closed_from: nil,
  ]

  # We need a factory method to create our server process
  # it takes a single parameter `port` which defaults to `2052`
  # This runs in the caller's context
  def start_link(%{pubsub: pubsub, agent: agent} = opts) do
    {:ok, pid} = process = GenServer.start_link(__MODULE__, opts, name: __MODULE__) # Start 'er up

    event = %UdpServer{opts: opts, pid: pid}

    unless is_nil(agent), do: Kernel.apply(agent, :event_start_udp_server, [event])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_start_udp_server, [event])

    process
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  @impl true
  def init(%{port: port, pubsub: pubsub, agent: agent} = opts) do
    IO.inspect(port, label: "PORT")
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    IO.inspect(socket, label: "SOCKET")

    event = %UdpServer{opts: opts, pid: self(), socket: socket}

    unless is_nil(agent), do: Kernel.apply(agent, :event_init_udp_server, [event])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_init_udp_server, [event])

    # to get the pid updated
    unless is_nil(agent), do: Kernel.apply(agent, :event_start_udp_server, [event])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_start_udp_server, [event])

    {:ok, event}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  @impl true
  def handle_info(
    {:udp, _socket, _address, _port, packet},
    %{opts: %{agent: agent, pubsub: pubsub}} = state
  ) do

    IO.inspect(state, label: "STATE")
    # IO.inspect(socket, label: "SOCKET")

    unless is_nil(agent), do: Kernel.apply(agent, :event_udp_packet, [packet])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_udp_packet, [packet])

    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, state}
  end

  @impl true
  def handle_call(
    :stop,
    from,
    %{opts: %{agent: agent, pubsub: pubsub}, socket: socket} = state = %UdpServer{}
  ) do

    # close the socket
    :gen_udp.close(socket)

    state = Map.put(state, :closed_from, from)

    unless is_nil(agent), do: Kernel.apply(agent, :event_close_udp_server, [state])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_close_udp_server, [state])

    # GenServer will understand this to mean we want to stop the server
    # action: :stop
    # reason: :normal
    # new_state: nil, it doesn't matter since we're shutting down :(
    {:stop, :normal, nil}
  end

end
