defmodule HamMessageParser do

  defstruct [
    software: nil,
    adif_ver: nil,
    programid: nil,
    call: nil,
    gridsquare: nil,
    mode: nil,
    submode: nil,
    rst_sent: nil,
    rst_rcvd: nil,
    qso_date: nil,
    time_on: nil,
    qso_date_off: nil,
    time_off: nil,
    band: nil,
    station_callsign: nil,
    my_gridsquare: nil,
  ]


  def example_message() do
    "����
    WSJT-X3
<adif_ver:5>3.1.0
<programid:6>WSJT-X
<EOH>
<call:5>K9ZIE <gridsquare:4>EN54 <mode:4>MFSK <submode:3>FT4 <rst_sent:3>-13 <rst_rcvd:3>+21 <qso_date:8>20221226 <time_on:6>203811 <qso_date_off:8>20221226 <time_off:6>203811 <band:3>20m <freq:9>14.081200 <station_callsign:6>VE7AJK <my_gridsquare:6>CN88ES <EOR>"
  end

  def parse(message) do
    _parse(message)
  end

  defp _parse(message) when is_binary(message) do
    _parse({message, %HamMessageParser{}, []})
  end

  defp _parse({
    <<"WSJT-X3", message::binary>>,
    %HamMessageParser{} = ham_message,
    control
  }) when length(control) == 0 do
    _parse({
       message,
       Map.put(ham_message, :software, "WSJT-X3"),
       [:software | control]
    })
  end

  defp _parse({
    <<"<adif_ver:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:software] do
    _add(ham_message, :adif_ver, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<adif_ver:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_software, control}
  end

  defp _parse({
    <<"<programid:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:adif_ver, :software] do
    _add(ham_message, :programid, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<programid:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_adif_ver, control}
  end

  defp _parse({
    <<"<EOH>", message::binary>>,
    %HamMessageParser{} = ham_message,
    control
  }) when control == [:programid, :adif_ver, :software] do
    _parse({
       message,
       ham_message,
       [:eoh | control]
    })
  end

  defp _parse({
    <<"<call:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :call, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<call:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_eoh, control}
  end

  defp _parse({
    <<"<gridsquare:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :gridsquare, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<gridsquare:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_call, control}
  end

  defp _parse({
    <<"<mode:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :mode, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<mode:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_gridsquare, control}
  end

  defp _parse({
    <<"<submode:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :submode, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<submode:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_mode, control}
  end

  defp _parse({
    <<"<rst_sent:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :rst_sent, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<rst_sent:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_submode, control}
  end

  defp _parse({
    <<"<rst_rcvd:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :rst_rcvd, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<rst_rcvd:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_rst_sent, control}
  end

  defp _parse({
    <<"<qso_date:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :qso_date, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<qso_date:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_rst_rcvd, control}
  end

  defp _parse({
    <<"<time_on:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :time_on, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<time_on:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_qso_date, control}
  end

  defp _parse({
    <<"<qso_date_off:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:time_on, :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :qso_date_off, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<qso_date_off:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_time_on, control}
  end

  defp _parse({
    <<"<time_off:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:qso_date_off, :time_on, :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :time_off, message, value_length, control)
    |> _parse()
  end

  defp _parse({
    <<"<time_off:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_qso_date_off, control}
  end

  defp _parse({
    <<"<band:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:time_off, :qso_date_off, :time_on, :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :band, message, value_length, control)
    |> _parse()
  end

   defp _parse({
    <<"<band:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_time_off, control}
  end

  defp _parse({
    <<"<station_callsign:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:band, :time_off, :qso_date_off, :time_on, :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :station_callsign, message, value_length, control)
    |> _parse()
  end

   defp _parse({
    <<"<station_callsign:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_band, control}
  end

  defp _parse({
    <<"<my_gridsquare:", value_length::bytes-size(1), ">", message::binary>>,
    %HamMessageParser{} = ham_message, control
  }) when control == [:station_callsign, :band, :time_off, :qso_date_off, :time_on, :qso_date, :rst_rcvd, :rst_sent, :submode, :mode, :gridsquare, :call, :eoh, :programid, :adif_ver, :software] do
    _add(ham_message, :my_gridsquare, message, value_length, control)
    |> _parse()
  end

   defp _parse({
    <<"<my_gridsquare:", _message::binary>>,
    %HamMessageParser{} = _ham_message,
    control
  }) do
    {:error, :no_previous_attribute_station_callsign, control}
  end

  defp _parse({"<EOR>", %HamMessageParser{} = ham_message, control}) do
    {:ok, ham_message, control}
  end

  defp _parse({"", %HamMessageParser{} = _ham_message, control}) do
    {:error, :no_message_termination_eor, control}
  end

  defp _parse({<<_header::bytes-size(1), tail::binary>>, %HamMessageParser{} = ham_message, control}) do
    parse({tail, ham_message, control})
  end

  defp _add(ham_message, attribute_name, message, string_length, control) do
    string_length = String.to_integer(string_length)
    string = String.slice(message, 0, string_length)

    {
       String.slice(message, string_length, String.length(message)),
       Map.put(ham_message, attribute_name, string),
       [attribute_name | control]
    }
  end

end
