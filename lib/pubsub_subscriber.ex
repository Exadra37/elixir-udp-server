defmodule UdpServer.PubSubSubscriber do

  @moduledoc """
  # PubSub Subscriber Example Module

  Use this module as inspiration to write a PubSub Subscriber on your application
  to subscribe to the packets received by the UDP server.
  """

  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Phoenix.PubSub.subscribe(UdpServer.PubSub, "udp:server")
    {:ok, []}
  end

  def handle_info({:packet, packet} = data, state) do
    Logger.debug(%{handle_info_packet: packet})

    state = [data | state]

    {:noreply, state}
  end

  def handle_info({:start_link, _process} = data, state) do
    Logger.debug(%{handle_info_start_link: data})

    state = [data | state]

    {:noreply, state}
  end

  def handle_info({:init, _process} = data, state) do
    Logger.debug(%{handle_info_init: data})

    state = [data | state]

    {:noreply, state}
  end

  def handle_info({:close, _process} = data, state) do
    Logger.debug(%{handle_info_close: data})

    state = [data | state]

    {:noreply, state}
  end

  def handle_call(:state, from, state) do
    Logger.debug(%{handle_call_from: from})
    {:reply, state, state}
  end

end
