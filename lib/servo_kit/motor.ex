defmodule ServoKit.MotorContract do
  @moduledoc """
  Defines a behaviour required for a servo.
  """

  @type driver :: struct()
  @type config :: map()
  @type motor :: struct()

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
          duty_cycle_minmax: {2.5, 12.5}
        })

  """
  @callback init(driver, config) :: {:ok, motor} | {:error, any}

  @doc """
  Executes the specified command and returns the updated state.

      {:ok, motor} = ServoKit.StandardServo.call(motor, {:set_angle, [0, 90]})

  """
  @callback call(motor, command) :: {:ok, motor} | {:error, any}
end

defmodule ServoKit.MotorStub do
  @moduledoc false

  @behaviour ServoKit.MotorContract

  def init(_driver, _config), do: {:ok, fake_motor()}

  def call(_motor, _command), do: {:ok, fake_motor()}

  def fake_motor() do
    %ServoKit.StandardServo{
      driver: ServoKit.DriverStub.fake_driver(),
      duty_cycle_minmax: {2.5, 12.5}
    }
  end
end
