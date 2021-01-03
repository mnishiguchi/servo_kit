defmodule ServoKit.ContinuousServo do
  @moduledoc """
  The abstraction of the continuous servo.
  """

  import ServoKit.ServoUtil

  @behaviour ServoKit.Servo

  @default_duty_cycle_minmax {2.5, 12.5}
  @default_duty_cycle_mid 7.5

  defstruct(
    driver: nil,
    duty_cycle_minmax: nil,
    duty_cycle_mid: nil
  )

  @typedoc """
  Configuration options for this module.

  - `driver`: A driver struct.
  - `duty_cycle_minmax`: A tuple of duty cycle min and max in percent.
  - `duty_cycle_mid`: A duty cycle in percent at which the servo stops its movement.
  """
  @type t :: %__MODULE__{
          driver: struct(),
          duty_cycle_mid: float(),
          duty_cycle_minmax: {float(), float()}
        }

  @impl true
  def new(driver, config \\ %{}) when is_struct(driver) and is_map(config) do
    __struct__(
      driver: driver,
      duty_cycle_minmax: config[:duty_cycle_minmax] || @default_duty_cycle_minmax,
      duty_cycle_mid: config[:duty_cycle_mid] || @default_duty_cycle_mid
    )
  end

  @impl true
  def call(state, {:set_throttle, [channel, value]}), do: set_throttle(state, channel, value)
  def call(_display, command), do: {:error, "Unsupported command: #{inspect(command)}"}

  @doc """
  Change the motor movement, ranging from -1.0 (full throttle reverse) to 1.0 (full throttle forward).

      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, 1.0)   # Full throttle forward
      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, -1.0)  # Full throttle reverse
      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, 0.0)   # Stop the movement
  """
  def set_throttle(%{driver: driver} = state, ch, throttle)
      when ch in 0..15 and throttle >= -1.0 and throttle <= 1.0 do
    with driver_module <- driver.__struct__,
         duty_cycle <- duty_cycle_from_throttle(throttle, state),
         driver <- apply(driver_module, :set_pwm_duty_cycle, [driver, ch, duty_cycle]) do
      {:ok, %{state | driver: driver}}
    end
  end
end
