defmodule ExTea5767.Ctrl do
  alias ExTea5767.{ State, Util }

  @addr 0b1100000 # TEA5767 i2c address from datasheet
  @type status() :: %{adc_level: byte, band_limit: 0 | 1, frequency: float, if_counter: byte, ready: 0 | 1, stereo: 0 | 1}

  @spec status :: status()
  def status() do
    { :ok, ref  } = State.ref()
    { :ok, data } = Circuits.I2C.read(ref, @addr, 4)
    Util.unpack data
  end

  @spec mute :: status()
  def mute, do: write %{ mute: 1 }

  @spec unmute :: status()
  def unmute, do: write %{ mute: 0 }

  @spec set_freq(float) :: any
  def set_freq(freq), do: write %{
      mute: 0,
      frequency: Util.freq_to_bits(freq)
    }

  # Private
  defp write( %{} = diff ) do
    data = State.settings diff
    {:ok, ref} = State.ref

    Circuits.I2C.write ref, @addr, Util.pack(data)
    status()
  end
end
