defmodule ServoKit.PCA9685.Util do
  @moduledoc """
  A collection of functions that are used for the PCA9685 driver.
  """

  @doc """
  Calculates 12-bit pulse range from a percentage value.

      iex> ServoKit.PCA9685.Util.pulse_range_from_percentage(0.0)
      {0, 0}
      iex> ServoKit.PCA9685.Util.pulse_range_from_percentage(50.0)
      {0, 2048}
      iex> ServoKit.PCA9685.Util.pulse_range_from_percentage(100.0)
      {0, 4095}
  """
  @spec pulse_range_from_percentage(float()) :: {0, 0..0xFFF}
  def pulse_range_from_percentage(percent) when percent >= 0.0 and percent <= 100.0 do
    {0, round(4095.0 * percent / 100)}
  end

  # The output frequency typically varies from 24 Hz to 1526 Hz.
  # https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685
  @pca9685_frequency_min 24
  @pca9685_frequency_max 1526

  @pca9685_prescale_min 0x03
  @pca9685_prescale_max 0xFF

  @doc """
  Calculates the PWM frequency in Hz based on specified prescale value and reference clock speed.

      iex> ServoKit.PCA9685.Util.frequency_from_prescale(255, 25_000_000)
      24
      iex> ServoKit.PCA9685.Util.frequency_from_prescale(121, 25_000_000)
      50
      iex> ServoKit.PCA9685.Util.frequency_from_prescale(60, 25_000_000)
      102
  """
  @spec frequency_from_prescale(integer(), integer()) :: integer()
  def frequency_from_prescale(prescale, reference_clock_speed) do
    round(reference_clock_speed / 4096.0 / prescale)
  end

  @doc """
  Calculates the PWM frequency prescale based on the formula in [Datasheet 7.3.5](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf).

  ```
  # Formula
  prescale_value = round(osc_value / (4096 * update_rate)) - 1
  ```

      iex> ServoKit.PCA9685.Util.prescale_from_frequecy(24, 25_000_000)
      253
      iex> ServoKit.PCA9685.Util.prescale_from_frequecy(50, 25_000_000)
      121
      iex> ServoKit.PCA9685.Util.prescale_from_frequecy(100, 25_000_000)
      60
      iex> ServoKit.PCA9685.Util.prescale_from_frequecy(1526, 25_000_000)
      3
  """
  @spec prescale_from_frequecy(24..1526, integer()) :: 3..255
  def prescale_from_frequecy(freq_hz, reference_clock_speed)
      when is_integer(freq_hz) and is_integer(reference_clock_speed) do
    freq_hz = valid_frequency(freq_hz)
    prescale = round(reference_clock_speed / (4096.0 * freq_hz)) - 1

    if prescale in @pca9685_prescale_min..@pca9685_prescale_max,
      do: prescale,
      else: raise_frequency_error(freq_hz)
  end

  defp valid_frequency(freq_hz) do
    if freq_hz in @pca9685_frequency_min..@pca9685_frequency_max,
      do: freq_hz,
      else: raise_frequency_error(freq_hz)
  end

  defp raise_frequency_error(freq_hz), do: raise("PCA9685 cannot output at #{freq_hz}Hz")
end
