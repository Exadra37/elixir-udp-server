defmodule UdpServer.PubSub.Broadcaster do

  def event_boot_udp_server(event) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:boot, event})
  end

  # def event_start_udp_server(event) do
  #   Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:start_link, event})
  # end

  # def event_init_udp_server(event) do
  #   Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:init, event})
  # end

  def event_udp_packet(event) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:packet, event})
  end

  def event_close_udp_server(event) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:close, event})
  end

end
