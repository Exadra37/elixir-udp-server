defmodule UdpServer.Packet do
  @enforce_keys [:index, :packet]
  defstruct [
    index: nil,
    packet: nil,
  ]
end

defmodule UdpServer.PacketsAgent do
  use Agent
  alias UdpServer.PacketsAgent
  alias UdpServer.Packet

  defstruct [
    current_index: nil,
    oldest_index: nil,
    packets: %{},
    uids: %{},
  ]

  def start_link(_args) do
    Agent.start_link(fn -> {0, %PacketsAgent{}} end, name: __MODULE__)
  end

  ### PUBLIC AGENT API ###

  def total_packets() do
    Agent.get(__MODULE__, fn {_index, %{packets: packets}} -> packets |> map_size() end)
  end

  def last_received_packet() do
    Agent.get(
      __MODULE__,
      fn {_next_index, %{current_index: index, packets: packets}} ->
        %Packet{index: index, packet: packets |> Map.get(index)}
      end
    )
  end

  def first_received_packet() do
    Agent.get(
      __MODULE__,
      fn {_index, %{oldest_index: index, packets: packets}} ->
        # %{index => packets |> Map.get(index)}
        %Packet{index: index, packet: packets |> Map.get(index)}
      end
    )
  end


  ### DEBUG ####
  # It can be very expensive to use this functions in production when the map
  # of packets is huge and the server is busy or almost at its memory capacity.

  def debug_state(:expensive_call) do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def debug_packets(:expensive_call) do
    Agent.get(__MODULE__, fn state -> state.packets end)
  end


  ### CALLBACKS ###

  def event_udp_packet(packet) do
    Agent.update(__MODULE__, fn acc -> _add_packet(packet, acc) end)
  end

  defp _add_packet(packet, {0, %{current_index: nil, oldest_index: nil, packets: packets, uids: uids}}) do
    packets = Map.put(packets, 0, packet)
    uids = Map.put(uids, packet.uid, 0)

    {1, %PacketsAgent{current_index: 0, oldest_index: 0, packets: packets, uids: uids}}
  end

  defp _add_packet(packet, {current_index, %{current_index: _, oldest_index: oldest_index, packets: packets, uids: uids}}) do
    packets = Map.put(packets, current_index, packet)
    uids = Map.put(uids, packet.uid, current_index)

    next_index = current_index + 1

    {
      next_index,
      %PacketsAgent{
        current_index: current_index,
        oldest_index: oldest_index,
        packets: packets,
        uids: uids
      }
    }
  end

  # @TODO:UdpServer.PacketsAgent - Write logic to persist/remove state every x time
  #   elapsed or when a certain length it's reached on the packets list.
  # defp _pop_packet(%{packets: []} = state) do
  #   {[], state}
  # end

  # defp _pop_last_packet() do
  #   Agent.get_and_update(
  #     __MODULE__,
  #     fn state ->
  #       Map.pop()
  #     end
  #   )
  # end

end
