defmodule ServoKit.ContinuousServo do
  @moduledoc """
  A standard servo.
  """

  import ServoKit.ServoUtil

  @behaviour ServoKit.Servo

  @default_duty_cycle_minmax {2.5, 12.5}
  @default_duty_cycle_mid 8.0

  defstruct(
    driver: nil,
    duty_cycle_minmax: nil,
    duty_cycle_mid: nil
  )

  @impl true
  def new(driver, config \\ %{}) when is_struct(driver) and is_map(config) do
    __struct__(
      # A driver struct
      driver: driver,
      # A tuple of duty cycle min and max in percent
      duty_cycle_minmax: config[:duty_cycle_minmax] || @default_duty_cycle_minmax,
      # A duty cycle in percent at which the servo stops its movement.
      duty_cycle_mid: config[:duty_cycle_mid] || @default_duty_cycle_mid
    )
  end

  @impl true
  def call(state, {:set_throttle, [channel, value]}), do: set_throttle(state, channel, value)
  def call(_display, command), do: {:error, "Unsupported command: #{inspect(command)}"}

  @doc """
  Change the motor speed, ranging from -1.0 (full speed reverse) to 1.0 (full speed forward).

  ## Examples

      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, 1.0)   # Full speed forward
      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, -1.0)  # Full speed reverse
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
