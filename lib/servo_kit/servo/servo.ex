defmodule ServoKit.Servo do
  @moduledoc """
  Defines a behaviour required for a servo.
  """

  @type driver :: struct()
  @type config :: map()
  @type servo :: struct()

  @typedoc """
  Type that represents a servo command.
  """
  @type command :: command_name | {command_name, command_args}
  @type command_name :: atom()
  @type command_args :: list()

  @doc """
  Initializes the servo.

      servo =
        %{i2c_bus: "i2c-1"}
        |> ServoKit.PCA9685.new()
        |> ServoKit.StandardServo.new(%{
          angle_max: 180,
          duty_cycle_minmax: {2.5, 12.5}
        })
  """
  @callback new(driver, config) :: servo | {:error, any}

  @doc """
  Executes the specified command and returns the updated state.

      {:ok, servo} = ServoKit.StandardServo.call(servo, {:set_angle, [0, 90]})
  """
  @callback call(servo, command) :: {:ok, servo} | {:error, any}
end
