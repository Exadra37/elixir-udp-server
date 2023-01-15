defmodule UdpServerOptions do
  defstruct [

    # Feel free to customize for a port of you desire
    port: 2052,

    # Defaults to :md5 for speed and compact uid, no need to use a more secure
    # algorithm here, like sha256, unless you think that in your use case you
    # will run in collisions issues, that :md5 and :sha1 can cause, but the
    # probabilities are low and for this use case I am confident it's not an issue.
    uid_algorithm: :md5,

    # You can customize how the Pubsub broadcast the messages by providing yours.
    pubsub: UdpServer.PubSub.Broadcaster,

    # Customize how the Agent works by providing your own implementation.
    agent: UdpServer.PacketsAgent,
  ]
end

defmodule UdpServerPacket do
  defstruct [
    uid: nil,
    at_nano_seconds: nil,
    server: %{
      uid: nil,
      pid: nil,
      socket: nil,
    },
    ip_address: nil,
    data: nil,
  ]
end

defmodule UdpServer do
  # Our module is going to use the DSL (Domain Specific Language) for Gen(eric) Servers
  use GenServer

  defstruct [
    uid: nil,
    active: nil,
    opts: %UdpServerOptions{},
    pid: nil,
    socket: nil,
    track_packets: [],
    started: %{
      at_nano_seconds: nil,
    },
    closed: %{
      at_nano_seconds: nil,
      from: nil,
    },
  ]

  # This runs in the caller's context
  def start_link(%{pubsub: pubsub, agent: agent} = opts) do
    IO.inspect(opts, label: "START OPTS")
    # {:ok, pid} =
    process = GenServer.start_link(__MODULE__, opts, name: __MODULE__) # Start 'er up

    # event = %UdpServer{opts: opts, pid: pid}

    # unless is_nil(agent), do: Kernel.apply(agent, :event_start_udp_server, [event])
    # unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_start_udp_server, [event])

    process
  end

  # Initialization that runs in the server context (inside the server process right after it boots)
  @impl true
  def init(%{port: port, pubsub: pubsub, agent: agent, uid_algorithm: algorithm} = opts) do
    IO.inspect(port, label: "INIT PORT")
    # Use erlang's `gen_udp` module to open a socket
    # With options:
    #   - binary: request that data be returned as a `String`
    #   - active: gen_udp will handle data reception, and send us a message `{:udp, socket, address, port, data}` when new data arrives on the socket
    # Returns: {:ok, socket}
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    IO.inspect(socket, label: "INIT SOCKET")

    pid = self()

    nano_seconds = :os.system_time(:nano_seconds)

    # uid = :crypto.hash(algorithm, [pid, socket, nano_seconds]) |> Base.encode16
    uid = :crypto.hash(algorithm, "#{pid}#{socket}#{nano_seconds}") |> Base.encode16

    event = %UdpServer{
      uid: "#{to_string(pid)}#{socket}",
      active: true,
      opts: opts,
      pid: pid,
      socket: socket,
      started: %{
        at_nano_seconds: nano_seconds,
      },
    }

    unless is_nil(agent), do: Kernel.apply(agent, :event_boot_udp_server, [event])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_boot_udp_server, [event])

    # to get the pid updated
    # unless is_nil(agent), do: Kernel.apply(agent, :event_start_udp_server, [event])
    # unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_start_udp_server, [event])

    {:ok, event}
  end

  # define a callback handler for when gen_udp sends us a UDP packet
  @impl true
  def handle_info(
    {:udp, _socket, ip_adress, _port, packet},
    %{opts: %{agent: agent, pubsub: pubsub, uid_algorithm: algorithm}} = state
  ) do

    IO.inspect(ip_adress, label: 'ADDRESS')

    nano_seconds = :os.system_time(:nano_seconds)

    uid = :crypto.hash(algorithm, "#{state.uid}#{packet}#{nano_seconds}") |> Base.encode16

    packet = %UdpServerPacket{
      uid: uid,
      at_nano_seconds: nano_seconds,
      server: %{
        uid: state.uid,
        pid: state.pid,
        socket: state.socket,
      },
      ip_address: ip_adress,
      data: packet,
    }

    track_packets = [{uid, nano_seconds} | state.track_packets]
    state = Map.put(state, :track_packets, track_packets)

    IO.inspect(state, label: "STATE")
    # IO.inspect(socket, label: "SOCKET")
    # raise "testing..."
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

    closed = %{
      at_nano_seconds: :os.system_time(:nano_seconds),
      from: from,
    }

    state = Map.put(state, :active, false)
    state = Map.put(state, :closed, closed)

    unless is_nil(agent), do: Kernel.apply(agent, :event_close_udp_server, [state])
    unless is_nil(pubsub), do: Kernel.apply(pubsub, :event_close_udp_server, [state])

    # GenServer will understand this to mean we want to stop the server
    # action: :stop
    # reason: :normal
    # new_state: nil, it doesn't matter since we're shutting down :(
    {:stop, :normal, nil}
  end

end
