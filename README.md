# Elixir UDP Server Example

A very simple UDP server example for Elixir that uses the code borrowed from [this gist](https://gist.github.com/joshnuss/08603e11615ee0de65724be4d6335475).


## Usage

Start an iex session with:

```console
iex -S mix
```

The output:

```text
Erlang/OTP 25 [erts-13.1.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit:ns]

PubSubServer.handle_info/2 data: {:init, {:ok, #Port<0.10>}}
Interactive Elixir (1.14.2) - press Ctrl+C to exit (type h() ENTER for help)
PubSubServer.handle_info/2 state: [{:init, {:ok, #Port<0.10>}} | {}]
PubSubServer.handle_info/2 data: {:start_link, {:ok, #PID<0.246.0>}}
PubSubServer.handle_info/2 state: [{:start_link, {:ok, #PID<0.246.0>}}, {:init, {:ok, #Port<0.10>}} | {}]
```

Now, in another terminal and from the root of this repo send the message at the file `ham_message.txt` to the UDP server:

```console
cat ham_message.txt | nc -u -w0 0.0.0.0 2052
```

The output:

```text
iex(1)> PubSubServer.handle_info/2 {:packet, packet} = data: {:packet,
 "����\n    WSJT-X3\n<adif_ver:5>3.1.0\n<programid:6>WSJT-X\n<EOH>\n<call:5>K9ZIE <gridsquare:4>EN54 <mode:4>MFSK <submode:3>FT4 <rst_sent:3>-13 <rst_rcvd:3>+21 <qso_date:8>20221226 <time_on:6>203811 <qso_date_off:8>20221226 <time_off:6>203811 <band:3>20m <freq:9>14.081200 <station_callsign:6>VE7AJK <my_gridsquare:6>CN88ES <EOR>\n"}
{:ok,
 %HamMessageParser{
   software: "WSJT-X3",
   adif_ver: "3.1.0",
   programid: "WSJT-X",
   call: "K9ZIE",
   gridsquare: "EN54",
   mode: "MFSK",
   submode: "FT4",
   rst_sent: "-13",
   rst_rcvd: "+21",
   qso_date: "20221226",
   time_on: "203811",
   qso_date_off: "20221226",
   time_off: "203811",
   band: "20m",
   station_callsign: "VE7AJK",
   my_gridsquare: "CN88ES"
 },
 [:my_gridsquare, :station_callsign, :band, :time_off, :qso_date_off, :time_on,
  :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh,
  :programid, :adif_ver, :my_gridsquare]}
```

The result has the format {:ok, ham_message, control} or {:error, message, control}. 

The received ham message is parsed only if all the attributes are present and in the correct order as per the returned control list where `:my_gridsquare` is the last attribute processed and `:my_gridsquare` the first.

Now, try to send a quit message:

```console
echo "quit" | nc -u -w0 0.0.0.0 2052
```

The output:

```text
PubSubServer.handle_info/2 data: {:close, "quit"}
PubSubServer.handle_info/2 state: [
  {:close, "quit"},
  {:start_link, {:ok, #PID<0.246.0>}},
  {:init, {:ok, #Port<0.10>}} |
  {}
]
PubSubServer.handle_info/2 data: {:init, {:ok, #Port<0.11>}}
PubSubServer.handle_info/2 state: [
  {:init, {:ok, #Port<0.11>}},
  {:close, "quit"},
  {:start_link, {:ok, #PID<0.246.0>}},
  {:init, {:ok, #Port<0.10>}} |
  {}
]
PubSubServer.handle_info/2 data: {:start_link, {:ok, #PID<0.249.0>}}
PubSubServer.handle_info/2 state: [
  {:start_link, {:ok, #PID<0.249.0>}},
  {:init, {:ok, #Port<0.11>}},
  {:close, "quit"},
  {:start_link, {:ok, #PID<0.246.0>}},
  {:init, {:ok, #Port<0.10>}} |
  {}
]
```

Has you can see the UDP server it's closing down, but once it's being supervised the BEAM restarts it again, thus you have a fault-tolerant UDP server without needing to write logic to make it so, instead you just need to configure it to be supervised in `mix.exs` and `lib/udp_server/application.ex`.
