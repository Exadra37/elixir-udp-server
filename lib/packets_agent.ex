defmodule UdpServer.PacketsAgent do
  use Agent
  alias UdpServer.PacketsAgent

  defstruct [
    packets: [],
    first_packet: nil,
  ]

  def start_link(_args) do
    Agent.start_link(fn -> %PacketsAgent{} end, name: __MODULE__)
  end

  ### PUBLIC AGENT API ###

  def length() do
    Agent.get(__MODULE__, fn state -> state.packets |> length() end)
  end

  def last_packet() do
    # The last received packet it's indeed the first packet on the List, and
    # very cheap to fetch, once its the head of the List.
    Agent.get(__MODULE__, fn state -> state.packets |> List.first() end)
  end

  def first_packet() do
    # The state.first_packet its tracked by us on this module.
    # Agent.get(__MODULE__, fn state -> state.first_packet end)

    # Retrieving the first element added to a List, the last element on it, may be
    # very expensive, but it will depends on the size of each element in the list
    # and on the complete list size. On a iex test for 10_000_0000 it looked fast
    # enough, but was possible to feel a slight delay on getting the first element
    # added to the List:
    #   iex> l = 1..10_000_000 |> Enum.reduce([], fn x,acc -> [{x, NaiveDateTime.utc_now, DateTime.utc_now, Date.utc_today, Time.utc_now} | acc] end)
    #   iex> List.last l
    #   {1, ~N[2023-01-17 18:38:24.347001], ~U[2023-01-17 18:38:24.347009Z], ~D[2023-01-17], ~T[18:38:24.347014]}
    #
    # An alternative to Lists may be ordered Erlang trees:
    #   - @link https://www.erlang.org/doc/man/gb_trees.html
    #   - @link https://elixirforum.com/t/map-with-ordered-keys/33503/7
    Agent.get(__MODULE__, fn state -> state.packets |> List.last() end)
  end


  ### DEBUG ####
  # It can be very expensive to use this functions in production when the list
  # of packets is huge and the server is busy or almost at its memory capacity.

  def debug_state(:expensive_call) do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def debug_packets(:expensive_call) do
    Agent.get(__MODULE__, fn state -> state.packets end)
  end


  ### CALLBACKS ###

  def event_udp_packet(event) do
    Agent.update(__MODULE__, fn state -> _add_packet(state, event) end)
  end

  # Returning the first item added to a list it's expensive in a huge list, thus
  # we want to keep track of it in order to make it a cheap operation when
  # calling first_packet/0
  defp _add_packet(%{first_packet: nil} = state, packet) do
    state
    |> Map.put(:first_packet, packet)
    |> _add_packet(packet)
  end

  defp _add_packet(state, packet) do
    {_old_state, new_state } =
      Map.get_and_update(
        state,
        :packets,
        fn packets -> {packets, [packet | packets]} end
      )

    new_state
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
  #       Map.get_and_update(state, :packets, fn [head | tail] = _packets -> {head, tail} end)
  #     end
  #   )
  # end

end
