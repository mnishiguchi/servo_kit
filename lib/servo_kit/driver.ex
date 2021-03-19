defmodule ServoKit.DriverContract do
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
  """
  @callback init(config()) :: {:ok, driver()} | {:error, any()}

  @doc """
  Sets the PWM frequency to the provided value in hertz. The PWM frequency is shared by all the channels.

      driver = ServoKit.PCA9685.set_pwm_frequency(state, 50)

  """
  @callback set_pwm_frequency(driver(), frequency) :: {:ok, driver()} | {:error, any()}

  @doc """
  Sets a single PWM channel or all PWM channels by specifying the duty cycle in percent.

      driver ServoKit.PCA9685.set_pwm_duty_cycle(driver, 0, 50.0)
      driver ServoKit.PCA9685.set_pwm_duty_cycle(driver, :all, 50.0)

  """
  @callback set_pwm_duty_cycle(driver(), channel_or_all, percent) :: {:ok, driver()} | {:error, any()}
end

defmodule ServoKit.DriverStub do
  @moduledoc false

  @behaviour ServoKit.DriverContract

  def init(_config), do: {:ok, fake_driver()}

  def set_pwm_frequency(_driver, _frequency), do: {:ok, fake_driver()}
  def set_pwm_duty_cycle(_driver, _channel_or_all, _percent), do: {:ok, fake_driver()}

  def fake_driver() do
    %ServoKit.PCA9685{
      duty_cycles: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      i2c_ref: make_ref(),
      mode1: 161,
      i2c_address: 64,
      prescale: 121,
      reference_clock_speed: 25_000_000
    }
  end
end
