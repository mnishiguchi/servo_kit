defmodule ServoKit.StandardServo do
  @moduledoc """
  The abstraction of the standard servo.
  """

  import ServoKit.ServoUtil

  @behaviour ServoKit.Servo

  @default_duty_cycle_minmax {2.5, 12.5}
  @default_angle_max 180

  defstruct(
    driver: nil,
    angle_max: 0,
    duty_cycle_minmax: nil
  )

  @typedoc """
  The internal state.
  """
  @type t :: %__MODULE__{
          driver: struct(),
          angle_max: integer(),
          duty_cycle_minmax: {float(), float()}
        }

  @typedoc """
  The configuration options.

  - `duty_cycle_minmax`: A tuple of duty cycle min and max in percent.
  - `angle_max`: A maximum angle that this servo can move to.
  """
  @type config :: %{
          optional(:duty_cycle_minmax) => {float, float},
          optional(:angle_max) => float()
        }

  @impl true
  @spec new(struct(), config()) :: t() | {:error, any()}
  def new(driver, config \\ %{}) when is_struct(driver) and is_map(config) do
    __struct__(
      driver: driver,
      angle_max: config[:angle_max] || @default_angle_max,
      duty_cycle_minmax: config[:duty_cycle_minmax] || @default_duty_cycle_minmax
    )
  rescue
    e -> {:error, e.message}
  end

  @impl true
  def call(state, {:set_angle, [channel, angle]}), do: set_angle(state, channel, angle)
  def call(_display, command), do: {:error, "Unsupported command: #{inspect(command)}"}

  @doc """
  Moves the actuator to the specified angle.

      {:ok, state} = ServoKit.StandardServo.set_angle(state, 0, 90)
  """
  def set_angle(%{driver: driver, angle_max: angle_max} = state, ch, angle) when ch in 0..15 and angle in 0..180 do
    if angle > angle_max do
      raise("Angle #{angle} is out of actuation range #{angle_max}")
    else
      with driver_module <- driver.__struct__,
           duty_cycle <- duty_cycle_from_angle(angle, state),
           driver <- apply(driver_module, :set_pwm_duty_cycle, [driver, ch, duty_cycle]) do
        {:ok, %{state | driver: driver}}
      end
    end
  rescue
    e -> {:error, e.message}
  end
end
