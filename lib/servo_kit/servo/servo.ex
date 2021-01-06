defmodule ServoKit.Servo do
  @moduledoc """
  Defines a behaviour required for a servo.
  """

  @type config :: map()
  @type driver :: struct()
  @type state :: struct()

  @typedoc """
  Type that represents a servo command.
  """
  @type command :: atom | {atom, list}

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
  @callback new(driver, config) :: state | {:error, any}

  @doc """
  Executes the specified command and returns the updated state.
  A command is made up of:
  - a command name atom
  - a list of arguments for the command, typically first one is a channel number

      {:ok, servo} = ServoKit.StandardServo.call(state, {:set_angle, [0, 90]})
  """
  @callback call(state, command) :: {:ok, state} | {:error, any}
end
