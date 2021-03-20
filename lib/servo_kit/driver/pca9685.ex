defmodule ServoKit.PCA9685 do
  @moduledoc """
  Controls the PCA9685 PWM Servo Driver.
  See [PCA9685 datasheet](https://cdn-shop.adafrut.com/datasheets/PCA9685.pdf).
  """

  use Bitwise, only_operators: true
  require Logger
  import ServoKit.PCA9685Calc

  @behaviour ServoKit.DriverContract

  @general_call_address 0x00
  @reg_reset 0x06

  @reg_mode1 0x00
  # @reg_mode2 0x01
  @reg_led0_on_l 0x06
  @reg_led0_on_h 0x07
  @reg_led0_off_l 0x08
  @reg_led0_off_h 0x09
  @reg_all_led_on_l 0xFA
  @reg_all_led_on_h 0xFB
  @reg_all_led_off_l 0xFC
  @reg_all_led_off_h 0xFD
  @reg_prescale 0xFE

  # @mode1_allcall 0x01
  # @mode1_sub3 0x02
  # @mode1_sub2 0x04
  # @mode1_sub1 0x08
  @mode1_sleep 0x10
  @mode1_auto_increment 0x20
  # @mode1_extclk 0x40
  @mode1_restart 0x80

  # @mode2_outne1 0x01
  # @mode2_outne2 0x02
  # @mode2_outdrv 0x04
  # @mode2_och 0x08
  # @mode2_invrt 0x10

  @default_bus_name "i2c-1"
  @default_address 0x40
  # The internal oscillator is 25 MHz. The external clock input, 50 MHz at most.
  @default_reference_clock_speed 25_000_000
  @default_frequency 50

  defstruct(
    i2c_ref: nil,
    i2c_address: nil,
    reference_clock_speed: nil,
    mode1: 0x11,
    prescale: nil,
    # Duty cycles per channel.
    duty_cycles: {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  )

  @type frequency :: 24..1526
  @type duty_cycles ::
          {number, number, number, number, number, number, number, number, number, number, number,
           number, number, number, number, number}

  @typedoc """
  The driver state.
  """
  @type t :: %__MODULE__{
          i2c_ref: ServoKit.Transport.bus(),
          i2c_address: ServoKit.Transport.address(),
          reference_clock_speed: pos_integer(),
          mode1: pos_integer(),
          prescale: pos_integer(),
          duty_cycles: duty_cycles
        }

  @typedoc """
  The configuration options.
  """
  @type options :: [
          bus_name: ServoKit.Transport.bus_name(),
          address: ServoKit.Transport.address(),
          reference_clock_speed: pos_integer(),
          frequency: frequency()
        ]

  @impl true
  @spec init(options()) :: {:ok, t()} | {:error, any()}
  def init(opts \\ []) do
    {:ok, i2c_ref} = ServoKit.Transport.open(opts[:bus_name] || @default_bus_name)
    i2c_address = opts[:address] || @default_address
    reference_clock_speed = opts[:reference_clock_speed] || @default_reference_clock_speed
    frequency = opts[:frequency] || @default_frequency

    initial_state =
      __struct__(
        i2c_ref: i2c_ref,
        i2c_address: i2c_address,
        reference_clock_speed: reference_clock_speed
      )

    with {:ok, state} <- reset(initial_state),
         {:ok, state} <- set_pwm_frequency(state, frequency),
         do: {:ok, state}
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def set_pwm_frequency(%{reference_clock_speed: reference_clock_speed} = state, freq_hz)
      when is_integer(freq_hz) do
    prescale = prescale_from_frequecy(freq_hz, reference_clock_speed)
    Logger.debug("Set frequency to #{freq_hz}Hz (prescale: #{prescale})")

    new_state =
      state
      # go to sleep, turn off internal oscillator
      |> update_mode1([
        {@mode1_restart, false},
        {@mode1_sleep, true}
      ])
      |> update_prescale(prescale)
      |> delay(5)
      # This sets the MODE1 register to turn on auto increment.
      |> update_mode1([
        {@mode1_restart, true},
        {@mode1_sleep, false},
        {@mode1_auto_increment, true}
      ])

    {:ok, new_state}
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def set_pwm_duty_cycle(%{duty_cycles: duty_cycles} = state, percent, ch: :all)
      when is_number(percent) and percent >= 0.0 and percent <= 100.0 do
    pulse_width = pulse_range_from_percentage(percent)
    Logger.debug("Set duty cycle to #{percent}% #{inspect(pulse_width)} for all channels")

    duty_cycles =
      0..(tuple_size(duty_cycles) - 1)
      |> Enum.reduce(duty_cycles, fn ch, acc -> put_elem(acc, ch, percent) end)

    # Keep record in memory and write to the device.
    new_state =
      %{state | duty_cycles: duty_cycles}
      |> write_pulse_range(:all, pulse_width)

    {:ok, new_state}
  rescue
    e -> {:error, e.message}
  end

  def set_pwm_duty_cycle(%{duty_cycles: duty_cycles} = state, percent, ch: ch)
      when ch in 0..15 and is_number(percent) and percent >= 0.0 and percent <= 100.0 do
    pulse_width = pulse_range_from_percentage(percent)
    Logger.debug("Set duty cycle to #{percent}% #{inspect(pulse_width)} for channel #{ch}")

    # Keep record in memory and write to the device.
    new_state =
      %{state | duty_cycles: put_elem(duty_cycles, ch, percent)}
      |> write_pulse_range(ch, pulse_width)

    {:ok, new_state}
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Performs the software reset.
  See [PCA9685 Datasheet](https://cdn-shop.adafrut.com/datasheets/PCA9685.pdf) 7.1.4 and 7.6.
  """
  def reset(%{i2c_ref: i2c_ref} = state) do
    :ok = ServoKit.Transport.write(i2c_ref, @general_call_address, <<@reg_reset>>)
    :timer.sleep(10)
    {:ok, state}
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Puts the board into the sleep mode.
  """
  def sleep(state) do
    new_state =
      state
      |> assign_mode1(@mode1_sleep, true)
      |> write_mode1()
      |> delay(5)

    {:ok, new_state}
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Wakes the board from the sleep mode.
  """
  def wake_up(state) do
    new_state =
      state
      |> assign_mode1(@mode1_sleep, false)
      |> write_mode1()

    {:ok, new_state}
  rescue
    e -> {:error, e.message}
  end

  # See [Datasheet 7.3.1](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf).
  defp update_mode1(state, flags) when is_list(flags) do
    Enum.reduce(flags, state, fn {flag, enabled}, state -> assign_mode1(state, flag, enabled) end)
    |> write_mode1()
  end

  # def update_mode2(state, flags) when is_list(flags) do
  #   Enum.reduce(flags, state, fn {flag, enabled}, state -> assign_mode2(state, flag, enabled) end)
  #   |> write_mode1()
  # end

  defp update_prescale(state, prescale) do
    state
    |> assign_prescale(prescale)
    |> write_prescale()
  end

  ##
  ## assigners that updates the in-memory state
  ##

  defp assign_mode1(state, flag, enabled), do: assign_mode(state, :mode1, flag, enabled)

  # defp assign_mode2(state, flag, enabled), do: assign_mode(state, :mode2, flag, enabled)

  defp assign_mode(state, mode_key, flag, enabled)
       when is_integer(flag) and is_boolean(enabled) do
    prev = Map.fetch!(state, mode_key)
    new_value = if(enabled, do: prev ||| flag, else: prev &&& ~~~flag)
    %{state | mode_key => new_value}
  end

  defp assign_prescale(state, prescale), do: Map.put(state, :prescale, prescale)

  ##
  ## low-level writers that send data to the PCA9685 device
  ##

  @doc """
  Sets a single PWM channel or all PWM channels by specifying when to switch on and when to switch
  off in a period. These values must be between 0 and 4095.
  """
  @spec write_pulse_range(ServoKit.PCA9685.t(), :all | byte, {char, char}) :: t()
  def write_pulse_range(state, ch, {from, until})
      when ch in 0..15 and from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@reg_led0_on_l + 4 * ch, on_l_byte)
    |> i2c_write(@reg_led0_on_h + 4 * ch, on_h_byte)
    |> i2c_write(@reg_led0_off_l + 4 * ch, off_l_byte)
    |> i2c_write(@reg_led0_off_h + 4 * ch, off_h_byte)
  end

  def write_pulse_range(state, :all, {from, until})
      when from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@reg_all_led_on_l, on_l_byte)
    |> i2c_write(@reg_all_led_on_h, on_h_byte)
    |> i2c_write(@reg_all_led_off_l, off_l_byte)
    |> i2c_write(@reg_all_led_off_h, off_h_byte)
  end

  defp write_mode1(%{mode1: mode1} = state), do: i2c_write(state, @reg_mode1, mode1)

  # defp write_mode2(%{mode2: mode2} = state), do: i2c_write(state, @reg_mode2, mode2)

  defp write_prescale(%{prescale: prescale} = state) do
    i2c_write(state, @reg_prescale, prescale)
  end

  # Writes data to the PCA9685 device.
  defp i2c_write(%{i2c_ref: i2c_ref, i2c_address: i2c_address} = state, register, data) do
    :ok = ServoKit.Transport.write(i2c_ref, i2c_address, <<register, data>>)
    state
  end

  defp delay(state, milliseconds) do
    :ok = Process.sleep(milliseconds)
    state
  end
end
