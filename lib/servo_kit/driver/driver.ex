defmodule ServoKit.Driver do
  @moduledoc """
  Defines a behaviour required for a servo driver.
  """

  @doc """
  Initializes the servo driver and returns the initial state.

  ## Examples

      iex> ServoKit.PCA9685.new(%{i2c_bus: "i2c-1"})
  """
  @callback new(map()) :: struct() | :no_return

  @doc """
  Sets the PWM frequency to the provided value in hertz. The PWM frequency is shared by all the channels.

  ## Examples

      iex> ServoKit.PCA9685.set_pwm_frequency(state, 50)
  """
  @callback set_pwm_frequency(map(), pos_integer()) :: struct() | :no_return

  @doc """
  Sets a single PWM channel or all PWM channels by specifying the duty cycle in percent.

  ## Examples

      iex> ServoKit.PCA9685.set_pwm_duty_cycle(state, 0, 50.0)
      iex> ServoKit.PCA9685.set_pwm_duty_cycle(state, :all, 50.0)
  """
  @callback set_pwm_duty_cycle(map(), 0..15 | :all, 0..100) :: struct() | :no_return
end
