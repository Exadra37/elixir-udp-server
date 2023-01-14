defmodule PubSub.Broadcaster do

  def handle_udp_start_link(process) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:start_link, process})
  end

  def handle_udp_init(server) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:init, server})
  end

  def handle_udp_packet(data) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:packet, data})
  end

  def handle_udp_close(from) do
    Phoenix.PubSub.broadcast_from(UdpServer.PubSub, self(), "udp:server", {:close, from})
  end

end
