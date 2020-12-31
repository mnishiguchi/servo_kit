defmodule ServoKit.StandardServo do
  @moduledoc """
  A standard servo.
  """

  import ServoKit.ServoUtil

  @default_angle_max 180
  @default_duty_cycle_minmax {2.5, 12.5}

  defstruct(
    driver: %{},
    angle_max: 0,
    duty_cycle_minmax: {}
  )

  @doc """
  Initializes the servo.

  ## Examples


      {:ok, state} =
        ServoKit.PCA9685.new(%{i2c_bus: "i2c-1"})
        |> ServoKit.StandardServo.new(%{
          angle_max: 180,
          duty_cycle_minmax: {2.5, 12.5}
        })
  """
  def new(driver, config) when is_struct(driver) and is_map(config) do
    {
      :ok,
      %ServoKit.StandardServo{
        driver: driver,
        angle_max: config[:angle_max] || @default_angle_max,
        duty_cycle_minmax: config[:duty_cycle_minmax] || @default_duty_cycle_minmax
      }
    }
  end

  @doc """
  Moves the actuator to the specified position in angle.

  ## Examples

      {:ok, state} = ServoKit.StandardServo.set_angle(state, 0, 90)
  """
  def set_angle(state, ch, angle) when ch in 0..15 and angle in 0..180 do
    %{driver: driver, angle_max: angle_max} = state

    if angle > angle_max do
      raise("Angle #{angle} is out of actuation range #{angle_max}")
    else
      driver_module = driver.__struct__
      driver = apply(driver_module, :set_pwm_duty_cycle, [driver, ch, duty_cycle_from_angle(state, angle)])
      {:ok, %{state | driver: driver}}
    end
  end
end
