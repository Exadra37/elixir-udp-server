# Elixir UDP Server Example

A very simple UDP server example for Elixir that uses the code borrowed from [this gist](https://gist.github.com/joshnuss/08603e11615ee0de65724be4d6335475).


## Usage

Start an iex session with:

```console
iex -S mix
```

Now, send messages to the UDP server from another terminal:

```console
echo "hello world" | nc -u -w0 0.0.0.0 2052
```

Now, try to send a quit message:

```console
echo "quit" | nc -u -w0 0.0.0.0 2052
```

The output:

```text
Erlang/OTP 25 [erts-13.1.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

Compiling 1 file (.ex)
init/0: {:ok, #Port<0.6>}
start_link/1: {:ok, #PID<0.164.0>}
Interactive Elixir (1.14.2) - press Ctrl+C to exit (type h() ENTER for help)

iex(1)> Received: hello world
Received: quit. Closing down...
init/0: {:ok, #Port<0.7>}
start_link/1: {:ok, #PID<0.167.0>}
```

Has you can see the UDP server it's closing down, but once it's being supervised the BEAM restarts it again, thus you have a fault-tolerant UDP server without needing to write logic to make it so, instead you just need to configure it to be supervised in `mix.exs` and `lib/udp_server/application.ex`.
