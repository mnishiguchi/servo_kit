defmodule ServoKit.Driver do
  @moduledoc """
  Defines a behaviour required for a servo driver.
  """

  @type config :: map()
  @type driver :: struct()
  @type frequency :: pos_integer()
  @type channel_or_all :: 0..15 | :all
  @type percent :: number()

  @doc """
  Initializes the servo driver and returns the initial state.

      driver = ServoKit.PCA9685.new(%{i2c_bus: "i2c-1"})
  """
  @callback new(config()) :: driver() | {:error, any()}

  @doc """
  Sets the PWM frequency to the provided value in hertz. The PWM frequency is shared by all the channels.

      driver = ServoKit.PCA9685.set_pwm_frequency(state, 50)
  """
  @callback set_pwm_frequency(driver(), frequency) :: driver() | {:error, any()}

  @doc """
  Sets a single PWM channel or all PWM channels by specifying the duty cycle in percent.

      driver ServoKit.PCA9685.set_pwm_duty_cycle(driver, 0, 50.0)
      driver ServoKit.PCA9685.set_pwm_duty_cycle(driver, :all, 50.0)
  """
  @callback set_pwm_duty_cycle(driver(), channel_or_all, percent) :: driver() | {:error, any()}
end
