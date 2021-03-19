defmodule ServoKit.StandardServo do
  @moduledoc """
  The abstraction of the standard servo.
  """

  @behaviour ServoKit.MotorContract

  @default_duty_cycle_minmax {2.5, 12.5}

  defstruct(
    driver: nil,
    duty_cycle_minmax: nil
  )

  @typedoc """
  The internal state.
  """
  @type t :: %__MODULE__{
          driver: struct(),
          duty_cycle_minmax: {number(), number()}
        }

  @typedoc """
  The configuration options.

  - `duty_cycle_minmax`: A tuple of duty cycle min and max in percent.
  """
  @type options :: %{
          optional(:duty_cycle_minmax) => {number, number}
        }

  @impl true
  def init(driver, opts \\ %{}) when is_struct(driver) and is_map(opts) do
    motor =
      __struct__(
        driver: driver,
        duty_cycle_minmax: opts[:duty_cycle_minmax] || @default_duty_cycle_minmax
      )

    {:ok, motor}
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def call(state, {:set_pwm_duty_cycle, channel, duty_cycle}), do: set_pwm_duty_cycle(state, channel, duty_cycle)
  def call(_display, command), do: {:error, "Unsupported command: #{inspect(command)}"}

  @doc """
  Moves the actuator by specifying duty cycle.

      {:ok, state} = ServoKit.StandardServo.set_pwm_duty_cycle(state, 0, 7.5)

  """
  def set_pwm_duty_cycle(%{driver: driver} = state, ch, duty_cycle)
      when is_integer(ch) and ch in 0..15 and duty_cycle in 0..100 do
    with driver <- apply(driver.__struct__, :set_pwm_duty_cycle, [driver, ch, duty_cycle]) do
      {:ok, %{state | driver: driver}}
    end
  rescue
    e -> {:error, e.message}
  end
end
