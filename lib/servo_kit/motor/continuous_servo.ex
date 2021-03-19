defmodule ServoKit.ContinuousServo do
  @moduledoc """
  The abstraction of the continuous servo.
  """

  import ServoKit.MotorCalc

  @behaviour ServoKit.MotorContract

  @default_duty_cycle_minmax {2.5, 12.5}

  defstruct(
    driver: nil,
    duty_cycle_minmax: nil,
    duty_cycle_mid: nil
  )

  @typedoc """
  The internal state.
  """
  @type t :: %__MODULE__{
          driver: struct(),
          duty_cycle_mid: number(),
          duty_cycle_minmax: {number(), number()}
        }

  @typedoc """
  The configuration options.

  - `duty_cycle_minmax`: A tuple of duty cycle min and max in percent.
  - `duty_cycle_mid`: A duty cycle in percent at which the servo stops its movement.
  """
  @type options :: %{
          optional(:duty_cycle_minmax) => {number, number},
          optional(:duty_cycle_mid) => number()
        }

  @impl true
  @spec init(struct(), options()) :: {:ok, t()} | {:error, any()}
  def init(driver, opts \\ %{}) when is_struct(driver) and is_map(opts) do
    duty_cycle_minmax = opts[:duty_cycle_minmax] || @default_duty_cycle_minmax

    motor =
      __struct__(
        driver: driver,
        duty_cycle_minmax: duty_cycle_minmax,
        duty_cycle_mid: opts[:duty_cycle_mid] || calculate_mid_value(duty_cycle_minmax)
      )

    {:ok, motor}
  rescue
    e -> {:error, e.message}
  end

  defp calculate_mid_value({min, max}), do: (min + max) / 2

  @impl true
  def call(state, {:set_throttle, channel, value}), do: set_throttle(state, channel, value)
  def call(_display, command), do: {:error, "Unsupported command: #{inspect(command)}"}

  @doc """
  Change the motor movement, ranging from -1.0 (full speed reverse) to 1.0 (full speed forward).

      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, 1.0)   # Full throttle forward
      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, -1.0)  # Full throttle reverse
      {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 8, 0.0)   # Stop the movement
  """
  def set_throttle(%{driver: driver} = state, ch, throttle)
      when is_integer(ch) and ch in 0..15 and
             is_number(throttle) and throttle >= -1.0 and throttle <= 1.0 do
    with driver_module <- driver.__struct__,
         duty_cycle <- duty_cycle_from_throttle(throttle, Map.take(state, [:duty_cycle_minmax, :duty_cycle_mid])),
         driver <- apply(driver_module, :set_pwm_duty_cycle, [driver, ch, duty_cycle]) do
      {:ok, %{state | driver: driver}}
    end
  rescue
    e -> {:error, e.message}
  end
end
