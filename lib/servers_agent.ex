defmodule UdpServer.ServersAgent do
  @moduledoc """
  # UDP Servers Agent

  An Agent to track:
  * Active and inactive UDP servers as per %UdpServer{}
  * Packets uids received as per %UdpServerTrackPacket{}

  Meant to be used for monitoring and tracking usage in production.
  """

  use Agent
  alias UdpServer.ServersAgent

  defstruct [
    servers: %{},
    tracked_packets: %{},
  ]


  ### SERVER ###

  @doc """
  The Agent should be safe to use as a distributed Agent, once it's started with
  the module name instead of an anonymous function, but hasn't been tested yet
  for real on this scenario.

  @link https://hexdocs.pm/elixir/main/Agent.html#module-a-word-on-distributed-agents
  """
  def start_link(args) do
    Agent.start_link(__MODULE__, :initial_state, [args], name: __MODULE__)
  end

  def initial_state(_args) do
    case GenServer.whereis(UdpServer) do
      nil ->
        %ServersAgent{}

      _pid_or_name_and_node ->
        server = GenServer.call(UdpServer, :state)
        %ServersAgent{servers: %{"#{server.uid}" => server}}
    end
  end

  @doc """
  Only use in emergency situations, like when the Agent is hogging all memory or
  CPU due to some unforeseen reason, or because it has accumulate millions of
  tracked packets that cause the memory to grow to dangerous values.

  Once it's a supervised Agent it will restart. During the restart will recover
  part of it's state. This is achieved by calling in `initial_state/1` the
  UdpServer to retrieve the current active server, thus loosing the state for
  all inactive servers and tracked packets.

  **NOTE:** - After implementing periodic persistence of :tracked_packets the
    Agent shouldn't cause any memory or cpu issues.
  """
  def emergency_stop(reason) do
    # @TODO:UdpServer.ServersAgent - Persist tracked packets and remove it from :tracked_packets
    Agent.stop(__MODULE__, reason)
  end


  ### CLIENT ###

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def servers() do
    Agent.get(__MODULE__, fn state -> state.servers end)
  end

  def active() do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.filter(state.servers, fn {_server_uid, server} -> server.active == true end)
      end
    )
  end

  def inactive() do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.filter(state.servers, fn {_server_uid, server} -> server.active == false end)
      end
    )
  end

  def tracked_packets() do
    Agent.get(__MODULE__, fn state -> state.tracked_packets end)
  end

  def tracked_packets(server_uid) when is_binary(server_uid) do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.filter(state.tracked_packets, fn {uid, _tracked_packets} -> server_uid == uid end)
      end
    )
  end


  ### CALLBACKS ###

  def event_boot_udp_server(%UdpServer{} = event) do
    Agent.update(__MODULE__, fn state -> _add_or_update_server(state, event) end)
  end

  def event_track_packets(%UdpServerTrackPacket{} = packet) do
    Agent.update(
      __MODULE__,
      fn state ->
        {_old_state, updated_state } = Map.get_and_update(
            state, :tracked_packets,
            fn tracked_packets -> {tracked_packets, _update_tracked_packets_by_server(tracked_packets, packet)} end
        )

        updated_state
      end
    )
    # @TODO:UdpServer.ServersAgent - Persist :tracked_packets when length > x.
  end

  def event_close_udp_server(%UdpServer{} = event) do
    Agent.update(__MODULE__, fn state -> _add_or_update_server(state, event) end)
    # @TODO:UdpServer.ServersAgent - Persist tracked packets and remove it from :tracked_packets
  end

  defp _add_or_update_server(state, event) do
    {_old_state, updated_state } = Map.get_and_update(state, :servers, fn servers -> {servers, Map.put(servers, event.uid, event)} end)
    updated_state
  end

  defp _update_tracked_packets_by_server(tracked_packets, packet) do
    {_old_state, updated_state } =
      Map.get_and_update(
        tracked_packets,
        packet.server_uid,
        fn
          nil -> {[packet], [packet]}
          packets -> {packets, [packet | packets]}
        end
      )
    updated_state
  end

end
