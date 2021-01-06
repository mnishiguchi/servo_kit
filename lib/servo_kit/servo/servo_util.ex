defmodule ServoKit.ServoUtil do
  @moduledoc """
  A collection of pure functions that are used for the servo abstractions.
  """

  @doc """
  Calculates duty cycle percentage from an angle.

      iex> ServoKit.ServoUtil.duty_cycle_from_angle(0, %{angle_max: 180, duty_cycle_minmax: {2.5, 12.5}})
      2.5

      iex> ServoKit.ServoUtil.duty_cycle_from_angle(90, %{angle_max: 180, duty_cycle_minmax: {2.5, 12.5}})
      7.5

      iex> ServoKit.ServoUtil.duty_cycle_from_angle(180, %{angle_max: 180, duty_cycle_minmax: {2.5, 12.5}})
      12.5
  """
  def duty_cycle_from_angle(
        angle,
        %{
          angle_max: angle_max,
          duty_cycle_minmax: {duty_cycle_min, duty_cycle_max}
        } = _config
      )
      when angle in 0..180 and duty_cycle_min < duty_cycle_max do
    map_range(angle, {0, angle_max}, {duty_cycle_min, duty_cycle_max})
  end

  @doc """
  Calculates duty cycle percentage from a throttle value between -1.0 (full speed reverse) and 1.0 (full speed forward) .
  Adjusts the duty cycle range so that the continuous servo is zeroed at `duty_cycle_mid`.

      iex> ServoKit.ServoUtil.duty_cycle_from_throttle(-1.0, %{duty_cycle_minmax: {2.5, 12.5}, duty_cycle_mid: 7.5})
      2.5

      iex> ServoKit.ServoUtil.duty_cycle_from_throttle(1.0, %{duty_cycle_minmax: {2.5, 12.5}, duty_cycle_mid: 7.5})
      12.5

      iex> ServoKit.ServoUtil.duty_cycle_from_throttle(0.0, %{duty_cycle_minmax: {2.5, 12.5}, duty_cycle_mid: 7.5})
      7.5

      iex> ServoKit.ServoUtil.duty_cycle_from_throttle(0.0, %{duty_cycle_minmax: {2.5, 12.5}, duty_cycle_mid: 8.0})
      8.0
  """
  def duty_cycle_from_throttle(
        throttle,
        %{
          duty_cycle_minmax: {duty_cycle_min, duty_cycle_max},
          duty_cycle_mid: duty_cycle_mid
        } = _config
      )
      when throttle >= -1.0 and throttle <= 1.0 and duty_cycle_min < duty_cycle_mid and
             duty_cycle_min < duty_cycle_max do
    throttle_in_percent = (throttle + 1) / 2 * 100.0
    margin = min(abs(duty_cycle_mid - duty_cycle_min), abs(duty_cycle_mid - duty_cycle_max))

    throttle_in_percent
    |> map_range({0, 100}, {duty_cycle_mid - margin, duty_cycle_mid + margin})
  end

  @doc """
  Maps a given value in one range to another range.

      iex> ServoKit.ServoUtil.map_range(25, {0, 100}, {0, 180})
      45.0
      iex> ServoKit.ServoUtil.map_range(50, {0, 100}, {0, 180})
      90.0
  """
  def map_range(x, {in_min, in_max}, {out_min, out_max}) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end
end
