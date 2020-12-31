defmodule ServoKit.ServoUtil do
  @moduledoc """
  A collection of functions that are used for the servo abstractions.
  """

  @doc """
  Calculates duty cycle in percent from an angle in degrees.

  ## Examples

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.duty_cycle_from_angle(driver, 0)
      2.5

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.duty_cycle_from_angle(driver, 90)
      7.5

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.duty_cycle_from_angle(driver, 180)
      12.5
  """
  def duty_cycle_from_angle(%{duty_cycle_minmax: duty_cycle_minmax}, angle)
      when is_tuple(duty_cycle_minmax) and angle in 0..180 do
    map_range(angle, {0, 180}, duty_cycle_minmax)
  end

  @doc """
  Calculates angle in degrees from a duty cycle in percent.

  ## Examples

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.angle_from_duty_cycle(driver, 2.5)
      0

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.angle_from_duty_cycle(driver, 7.5)
      90

      iex> driver = %{actuation_range: 170, duty_cycle_minmax: {2.5, 12.5}}
      ...> ServoKit.ServoUtil.angle_from_duty_cycle(driver, 12.5)
      180
  """
  def angle_from_duty_cycle(%{duty_cycle_minmax: duty_cycle_minmax}, duty_cycle)
      when is_tuple(duty_cycle_minmax) and duty_cycle >= 0.0 and duty_cycle <= 100.0 do
    map_range(duty_cycle, duty_cycle_minmax, {0, 180}) |> round
  end

  defp map_range(x, {in_min, in_max}, {out_min, out_max}) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end
end
