defmodule PCA9685.Driver do
  @moduledoc """
  Controls the PCA9685 PWM Servo Driver from Elixir.
  See [PCA9685 Datasheet](https://cdn-shop.adafrut.com/datasheets/PCA9685.pdf)
  """
  use Bitwise
  require Logger

  @general_call_address 0x00
  @software_reset 0x06

  # REGISTER ADDRESSES
  @pca9685_mode1 0x00
  @pca9685_mode2 0x01
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

  @pca9685_prescale_min 3
  @pca9685_prescale_max 255

  # The frequency limit is: 3052 = 50MHz / (4 * 4096)
  # See Datasheet 7.3.5 PWM frequency PRESCALE
  @pca9685_frequency_min 1
  @pca9685_frequency_max 3050

  # The frequency the PCA9685 should use for frequency calculations.
  @oscillator_freq 25_000_000

  @default_config %{
    i2c_bus_name: "i2c-1",
    frequency: 50
  }

  defmodule State do
    defstruct(
      i2c_ref: nil,
      pca9685_address: 0x40,
      mode1: 0x11,
      mode2: 0x04
    )
  end

  @doc """
  Initialize the PCA9685.

      iex> {:ok, state} = PCA9685.Driver.start(%{i2c_bus_name: "i2c-1"})
  """
  def start(config \\ %{}) do
    %{i2c_bus_name: i2c_bus_name, frequency: frequency} = Enum.into(config, @default_config)
    {:ok, i2c_ref} = Circuits.I2C.open(i2c_bus_name)
    state = %PCA9685.Driver.State{i2c_ref: i2c_ref} |> set_pwm_frequency(frequency)
    {:ok, state}
  end

  @doc """
  Performs the software reset. See Datasheet 7.1.4 and 7.6.

      iex> PCA9685.Driver.reset(state)
  """
  def reset(%{i2c_ref: i2c_ref} = state) do
    :ok = Circuits.I2C.write(i2c_ref, @general_call_address, <<@software_reset>>)
    state
  end

  @doc """
  Puts board into sleep mode.

      iex> PCA9685.Driver.sleep(state)
  """
  def sleep(state) do
    state |> assign_mode1(@mode1_sleep, true) |> write_mode1() |> delay(5)
  end

  @doc """
  Wakes board from sleep.

      iex> PCA9685.Driver.wake_up(state)
  """
  def wake_up(state) do
    state |> assign_mode1(@mode1_sleep, false) |> write_mode1()
  end

  @doc """
  Set the PWM frequency to the provided value in hertz.

      iex> PCA9685.Driver.set_pwm_frequency(state, 50)

  """
  def set_pwm_frequency(state, freq_hz) when is_integer(freq_hz) do
    freq_hz = valid_frequency(freq_hz)
    prescale = round(@oscillator_freq / (freq_hz * 4096.0) + 0.5 - 1) |> valid_prescale
    Logger.debug("frequency: #{freq_hz}, prescale: #{prescale}")

    state
    # go to sleep, turn off internal oscillator
    |> assign_mode1(@mode1_restart, false)
    |> assign_mode1(@mode1_sleep, true)
    |> write_mode1()
    |> update_prescale(prescale)
    |> delay(5)
    # This sets the MODE1 register to turn on auto increment.
    |> assign_mode1(@mode1_sleep, false)
    |> assign_mode1(@mode1_restart, true)
    |> assign_mode1(@mode1_auto_increment, true)
    |> write_mode1()
  end

  defp valid_frequency(freq_hz) when freq_hz < @pca9685_frequency_min, do: @pca9685_frequency_min
  defp valid_frequency(freq_hz) when freq_hz > @pca9685_frequency_max, do: @pca9685_frequency_max
  defp valid_frequency(freq_hz), do: freq_hz
  defp valid_prescale(val) when val < @pca9685_prescale_min, do: @pca9685_prescale_min
  defp valid_prescale(val) when val > @pca9685_prescale_max, do: @pca9685_prescale_max
  defp valid_prescale(val), do: val

  @doc """
  Sets a single PWM channel or all PWM channels by specifying the duty cycle in percent.

      iex> PCA9685.Driver.set_pwm_duty_cycle(state, 0, 50.0)
      iex> PCA9685.Driver.set_pwm_duty_cycle(state, :all, 50.0)
  """
  def set_pwm_duty_cycle(state, ch, percent) when ch in 0..15 and percent >= 0.0 and percent <= 100.0 do
    pulse_width = pulse_width_from_percent(percent)
    Logger.debug("Duty cycle #{percent}% #{inspect(pulse_width)}")
    set_pwm(state, ch, pulse_width)
  end

  @doc """
  Sets a single PWM channel or all PWM channels by specifying when to switch on and when to switch off in a period.
  These values must be between 0 and 4095.

      iex> PCA9685.Driver.set_pwm(state, 0, {0, 2000})
      iex> PCA9685.Driver.set_pwm(state, :all, {0, 2000})
  """
  def set_pwm(state, ch, {from, until}) when ch in 0..15 and from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@pca9685_led0_on_l + 4 * ch, on_l_byte)
    |> i2c_write(@pca9685_led0_on_h + 4 * ch, on_h_byte)
    |> i2c_write(@pca9685_led0_off_l + 4 * ch, off_l_byte)
    |> i2c_write(@pca9685_led0_off_h + 4 * ch, off_h_byte)
  end

  def set_pwm(state, :all, {from, until}) when from in 0..0xFFF and until in 0..0xFFF do
    <<on_h_byte::4, on_l_byte::8>> = <<from::size(12)>>
    <<off_h_byte::4, off_l_byte::8>> = <<until::size(12)>>

    state
    |> i2c_write(@pca9685_all_led_on_l, on_l_byte)
    |> i2c_write(@pca9685_all_led_on_h, on_h_byte)
    |> i2c_write(@pca9685_all_led_off_l, off_l_byte)
    |> i2c_write(@pca9685_all_led_off_h, off_h_byte)
  end

  @spec pulse_width_from_percent(float()) :: {0, 0..0xFFF}
  defp pulse_width_from_percent(percent) when percent >= 0.0 and percent <= 100.0 do
    {0, round(4095.0 * percent / 100)}
  end

  defp update_prescale(state, prescale) do
    state |> assign_prescale(prescale) |> write_prescale()
  end

  ##
  ## Assigners for the state fields in memory
  ##

  defp assign_mode1(state, flag, enabled), do: assign_mode(state, :mode1, flag, enabled)
  # defp assign_mode2(state, flag, enabled), do: assign_mode(state, :mode2, flag, enabled)
  defp assign_prescale(state, prescale), do: Map.put(state, :prescale, prescale)

  defp assign_mode(state, mode_key, flag, enabled) when is_integer(flag) and is_boolean(enabled) do
    prev = Map.fetch!(state, mode_key)
    new_value = if(enabled, do: prev ||| flag, else: prev &&& ~~~flag)
    Map.put(state, mode_key, new_value)
  end

  ##
  ## Writers that send value to the PCA9685.
  ##

  defp write_mode1(%{mode1: mode1} = state), do: i2c_write(state, @pca9685_mode1, mode1)
  # defp write_mode2(%{mode2: mode2} = state), do: i2c_write(state, @pca9685_mode2, mode2)
  defp write_prescale(%{prescale: prescale} = state), do: i2c_write(state, @pca9685_prescale, prescale)

  defp i2c_write(state, register, data) when register in 0..255 and data in 0..255 do
    %{i2c_ref: i2c_ref, pca9685_address: pca9685_address} = state
    Logger.debug("Wrote #{hex(data)} to register #{hex(register)} at address #{hex(pca9685_address)}")
    :ok = Circuits.I2C.write(i2c_ref, pca9685_address, <<register, data>>)
    state
  end

  defp delay(state, milliseconds) do
    Process.sleep(milliseconds)
    state
  end

  defp hex(val), do: inspect(val, base: :hex)
end
