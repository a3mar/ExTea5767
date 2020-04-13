defmodule ExTea5767.State do
  use GenServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link __MODULE__, [], [{:name, __MODULE__}]
  end

  @impl GenServer
  @spec init(binary | charlist) :: {:ok, %{ref: reference, settings: [{atom, [bits: integer, value: integer]}, ...]}}
  def init(i2c_bus_name) do
    {:ok, ref} = Circuits.I2C.open "i2c-0" #i2c_bus_name
    {:ok, %{
      ref: ref,
      settings: [
        mute:            [ bits: 1,  value: 1 ], # 1 muted, 0 not muted
        search_mode:     [ bits: 1,  value: 0 ], # 1 search mode, 0 not
        frequency:       [ bits: 14, value: 0 ], #
        search_dir:      [ bits: 1,  value: 1 ], # 1 search up, 0 down
        search_stop:     [ bits: 2,  value: 3 ], # 1 low, 2 mid, 3 high
        side_inject:     [ bits: 1,  value: 1 ], # 1 high, 0 low side LO injection
        mono_to_stereo:  [ bits: 1,  value: 0 ], # 1 forced mono, 0 stereo on
        mute_channel:    [ bits: 2,  value: 0 ], # 0 not mute, 1 mute left, 2 mute right, 3 both
        soft_ports:      [ bits: 2,  value: 0 ], # software programmable ports
        standby:         [ bits: 1,  value: 0 ], # 1 standby, 0 not
        band_limits:     [ bits: 1,  value: 0 ], # 1 japanese, 0 europe
        clock_freq:      [ bits: 1,  value: 1 ], # look datasheet
        soft_mute:       [ bits: 1,  value: 0 ], # 1 softmute on, 0 off
        high_cut:        [ bits: 1,  value: 1 ], # High cut control, 1 on, 0 off
        noise_cancel:    [ bits: 1,  value: 1 ], # Stereo noise cancel, 1 on, 0 off
        indicator:       [ bits: 1,  value: 0 ], # look datasheet
        lastbyte:        [ bits: 8,  value: 0 ], # I dont need it
      ]
      }
    }
  end

  def ref do
    GenServer.call __MODULE__, { :get_ref }
  end

  def settings do
    GenServer.call __MODULE__, { :settings }
  end

  @spec settings(map) :: any
  def settings(%{} = settings) do
    GenServer.call __MODULE__, { :settings, settings }
  end

  @impl GenServer
  def handle_call({ :get_ref }, _from, state) do
    { :reply, Map.fetch(state, :ref), state }
  end

  @impl GenServer
  def handle_call({ :settings }, _from, state) do
    { :reply, Map.fetch(state, :settings), state }
  end

  @impl GenServer
  def handle_call({ :settings, diff }, _from, state) do
    new_settings = diff_to_settings(diff, state)

    { :reply, new_settings,
      Map.replace!(state, :settings, new_settings) }
  end

  # private
  defp diff_to_settings( %{} = diff, %{settings: settings} ) do
    List.foldr(settings, [], fn(param, acc) ->
      { name, [ bits: bits, value: orig_val ] } = param

      updated = case Map.fetch(diff, name) do
        {:ok, new_value} -> { name, [bits: bits, value: new_value] }
        :error           -> { name, [bits: bits, value: orig_val ] }
      end

      [ updated | acc ]
    end)
  end
end
