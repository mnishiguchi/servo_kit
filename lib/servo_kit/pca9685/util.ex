defmodule ServoKit.PCA9685.Util do
  @doc """
  ## Examples

      iex> ServoKit.PCA9685.Util.pulse_range_from_percent(0)
      {0, 0}
      iex> ServoKit.PCA9685.Util.pulse_range_from_percent(50)
      {0, 2048}
      iex> ServoKit.PCA9685.Util.pulse_range_from_percent(100)
      {0, 4095}
  """
  @spec pulse_range_from_percent(float()) :: {0, 0..0xFFF}
  def pulse_range_from_percent(percent) when percent >= 0.0 and percent <= 100.0 do
    {0, round(4095.0 * percent / 100)}
  end

  @pca9685_prescale_min 3
  @pca9685_prescale_max 255

  # The frequency limit is: 3052 = 50MHz / (4 * 4096)
  @pca9685_frequency_min 1
  @pca9685_frequency_max 3052

  # The frequency the PCA9685 should use for frequency calculations.
  @oscillator_frequency 25_000_000

  @doc """
  Calculates the PWM frequency prescale based on the formula in [Datasheet 7.3.5](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf).

  ```
  prescale_value = round(osc_value / (4096 * update_rate)) - 1
  ```

  ## Examples

      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(1)
      255
      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(23)
      255
      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(50)
      121
      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(100)
      60
      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(1526)
      3
      iex> ServoKit.PCA9685.Util.prescale_value_from_frequecy(2000)
      3
  """
  def prescale_value_from_frequecy(freq_hz) when is_integer(freq_hz) do
    freq_hz = valid_frequency(freq_hz)
    round(@oscillator_frequency / (4096.0 * freq_hz) - 1) |> valid_prescale
  end

  defp valid_frequency(freq_hz) when freq_hz < @pca9685_frequency_min, do: @pca9685_frequency_min
  defp valid_frequency(freq_hz) when freq_hz > @pca9685_frequency_max, do: @pca9685_frequency_max
  defp valid_frequency(freq_hz), do: freq_hz
  defp valid_prescale(val) when val < @pca9685_prescale_min, do: @pca9685_prescale_min
  defp valid_prescale(val) when val > @pca9685_prescale_max, do: @pca9685_prescale_max
  defp valid_prescale(val), do: val
end
