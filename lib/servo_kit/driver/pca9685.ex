defmodule ServoKit.PCA9685 do
  @moduledoc """
  Controls the PCA9685 PWM Servo Driver.
  See [PCA9685 datasheet](https://cdn-shop.adafrut.com/datasheets/PCA9685.pdf).
  """

  use Bitwise, only_operators: true
  require Logger
  import ServoKit.PCA9685.Util
  alias ServoKit.I2C, as: SerialBus

  @behaviour ServoKit.Driver

  @general_call_address 0x00
  @software_reset 0x06

  # REGISTER ADDRESSES
  @pca9685_mode1 0x00
  # @pca9685_mode2 0x01
  @pca9685_led0_on_l 0x06
  @pca9685_led0_on_h 0x07
  @pca9685_led0_off_l 0x08
  @pca9685_led0_off_h 0x09
  @pca9685_all_led_on_l 0xFA
  @pca9685_all_led_on_h 0xFB
  @pca9685_all_led_off_l 0xFC
  @pca9685_all_led_off_h 0xFD
  @pca9685_prescale 0xFE

  # MODE1 bits
  # @mode1_allcall 0x01
  # @mode1_sub3 0x02
  # @mode1_sub2 0x04
  # @mode1_sub1 0x08
  @mode1_sleep 0x10
  @mode1_auto_increment 0x20
  # @mode1_extclk 0x40
  @mode1_restart 0x80

  # MODE2 bits
  # @mode2_outne1 0x01
  # @mode2_outne2 0x02
  # @mode2_outdrv 0x04
  # @mode2_och 0x08
  # @mode2_invrt 0x10

  @default_i2c_bus "i2c-1"
  @default_pca9685_address 0x40
  # The internal oscillator is 25 MHz. The external clock input, 50 MHz at most.
  @default_reference_clock_speed 25_000_000
  @default_frequency 50

  defstruct(
    i2c_ref: nil,
    pca9685_address: nil,
    reference_clock_speed: nil,
    mode1: 0x11,
    prescale: nil,
    # Duty cycles per channel.
    duty_cycles: List.duplicate(0, 16)
  )

  @typedoc """
  Configuration options for this module.
  """
  @type t :: %__MODULE__{
          i2c_ref: reference(),
          pca9685_address: pos_integer(),
          reference_clock_speed: pos_integer(),
          mode1: pos_integer(),
          prescale: pos_integer(),
          duty_cycles: list()
        }

  @impl true
  def new(config \\ %{}) do
    {:ok, i2c_ref} = SerialBus.open(config[:i2c_bus] || @default_i2c_bus)
    pca9685_address = config[:pca9685_address] || @default_pca9685_address
    reference_clock_speed = config[:reference_clock_speed] || @default_reference_clock_speed
    frequency = config[:frequency] || @default_frequency

    __struct__(
      i2c_ref: i2c_ref,
      pca9685_address: pca9685_address,
      reference_clock_speed: reference_clock_speed
    )
    |> set_pwm_frequency(frequency)
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def set_pwm_frequency(%{reference_clock_speed: reference_clock_speed} = state, freq_hz) when is_integer(freq_hz) do
    prescale = prescale_from_frequecy(freq_hz, reference_clock_speed)
    Logger.debug("Set frequency to #{freq_hz}Hz (prescale: #{prescale})")

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
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def set_pwm_duty_cycle(%{duty_cycles: duty_cycles} = state, ch, percent)
      when ch in 0..15 and percent >= 0.0 and percent <= 100.0 do
    pulse_width = pulse_range_from_duty_cycle(percent)
    Logger.debug("Set duty cycle to #{percent}% #{inspect(pulse_width)} for channel #{ch}")
    # Keep record in memory and write to the device.

    %{state | duty_cycles: List.replace_at(duty_cycles, ch, percent)}
    |> write_pulse_range(ch, pulse_width)
  rescue
    e -> {:error, e.message}
  end

  def set_pwm_duty_cycle(state, :all, percent) when percent >= 0.0 and percent <= 100.0 do
    pulse_width = pulse_range_from_duty_cycle(percent)
    Logger.debug("Duty cycle #{percent}% #{inspect(pulse_width)} for all channels")
    # Keep record in memory and write to the device.

    %{state | duty_cycles: List.duplicate(percent, 16)}
    |> write_pulse_range(:all, pulse_width)
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Performs the software reset.
  See [PCA9685 Datasheet](https://cdn-shop.adafrut.com/datasheets/PCA9685.pdf) 7.1.4 and 7.6.

      ServoKit.PCA9685.reset(state)
  """
  def reset(%{i2c_ref: i2c_ref} = state) do
    :ok = SerialBus.write(i2c_ref, @general_call_address, <<@software_reset>>)
    state
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Puts the board into the sleep mode.

      ServoKit.PCA9685.sleep(state)
  """
  def sleep(state) do
    state |> assign_mode1(@mode1_sleep, true) |> write_mode1() |> delay(5)
  rescue
    e -> {:error, e.message}
  end

  @doc """
  Wakes the board from the sleep mode.

      ServoKit.PCA9685.wake_up(state)
  """
  def wake_up(state) do
    state |> assign_mode1(@mode1_sleep, false) |> write_mode1()
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
    state |> assign_prescale(prescale) |> write_prescale()
  end

  ##
  ## Assigners for the state in memory
  ##

  defp assign_mode1(state, flag, enabled), do: assign_mode(state, :mode1, flag, enabled)

  # defp assign_mode2(state, flag, enabled), do: assign_mode(state, :mode2, flag, enabled)

  defp assign_mode(state, mode_key, flag, enabled) when is_integer(flag) and is_boolean(enabled) do
    prev = Map.fetch!(state, mode_key)
    new_value = if(enabled, do: prev ||| flag, else: prev &&& ~~~flag)
    Map.put(state, mode_key, new_value)
  end

  defp assign_prescale(state, prescale), do: Map.put(state, :prescale, prescale)

  ##
  ## Writers that send data to the PCA9685 device
  ##

  # Sets a single PWM channel or all PWM channels by specifying when to switch on and when to switch off in a period.
  # These values must be between 0 and 4095.
  @spec write_pulse_range(ServoKit.PCA9685.t(), :all | byte, {char, char}) :: %ServoKit.PCA9685{}
  defp write_pulse_range(state, ch, {from, until}) when ch in 0..15 and from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@pca9685_led0_on_l + 4 * ch, on_l_byte)
    |> i2c_write(@pca9685_led0_on_h + 4 * ch, on_h_byte)
    |> i2c_write(@pca9685_led0_off_l + 4 * ch, off_l_byte)
    |> i2c_write(@pca9685_led0_off_h + 4 * ch, off_h_byte)
  end

  defp write_pulse_range(state, :all, {from, until}) when from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@pca9685_all_led_on_l, on_l_byte)
    |> i2c_write(@pca9685_all_led_on_h, on_h_byte)
    |> i2c_write(@pca9685_all_led_off_l, off_l_byte)
    |> i2c_write(@pca9685_all_led_off_h, off_h_byte)
  end

  defp write_mode1(%{mode1: mode1} = state), do: i2c_write(state, @pca9685_mode1, mode1)

  # defp write_mode2(%{mode2: mode2} = state), do: i2c_write(state, @pca9685_mode2, mode2)

  defp write_prescale(%{prescale: prescale} = state), do: i2c_write(state, @pca9685_prescale, prescale)

  # Writes data to the device.
  defp i2c_write(state, register, data) when register in 0..255 and data in 0..255 do
    %{i2c_ref: i2c_ref, pca9685_address: pca9685_address} = state
    # hex = fn val -> inspect(val, base: :hex) end
    # Logger.debug("Wrote #{hex.(data)} to register #{hex.(register)} at address #{hex.(pca9685_address)}")
    :ok = SerialBus.write(i2c_ref, pca9685_address, <<register, data>>)
    state
  end

  defp delay(state, milliseconds) do
    with :ok <- Process.sleep(milliseconds), do: state
  end
end
