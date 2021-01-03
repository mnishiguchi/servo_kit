defmodule ServoKit do
  @moduledoc """
  A collection of convenience functions to use this library.
  """

  @doc """
  Initializes a standard servo. For options, see `ServoKit.StandardServo` documentation.

      pid = ServoKit.init_standard_servo()
  """
  def init_standard_servo(servo_options \\ %{}) do
    _pid =
      ServoKit.init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: servo_options
      )
  end

  @doc """
  Initializes a continuous servo. For options, see `ServoKit.ContinuousServo` documentation.

      pid = ServoKit.init_continuous_servo()
  """
  def init_continuous_servo(servo_options \\ %{}) do
    _pid =
      ServoKit.init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.ContinuousServo,
        servo_options: servo_options
      )
  end

  @doc """
  Initializes a `ServoController`.

      pid = ServoKit.init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: %{}
      )
  """
  def init_servo_controller([driver_module: _, driver_options: _, servo_module: _, servo_options: _] = args) do
    _pid = ServoKit.ServoSupervisor.servo_controller(args)
  end

  ##
  ## Servo commands
  ##

  @doc """
  Change the angle for a starndard servo.

      # Set the angle to 90 degrees for Channel 0.
      ServoKit.set_angle(pid, 0, 90)
  """
  def set_angle(pid, channel, angle) when is_pid(pid) and channel in 0..15 and is_integer(angle) do
    ServoKit.ServoController.run_command(pid, {:set_angle, [channel, angle]})
  end

  @doc """
  Change the throttle for a continuous servo.

      # Set the throttle to full speed reverse for Channel 8.
      ServoKit.set_throttle(pid, 8, -1)
  """
  def set_throttle(pid, channel, throttle)
      when is_pid(pid) and channel in 0..15 and throttle >= -1.0 and throttle <= 1.0 do
    ServoKit.ServoController.run_command(pid, {:set_throttle, [channel, throttle]})
  end

  ##
  ## DEMO programs
  ##

  @doc """
  Runs a quick-test program for the LED brightness.

      ServoKit.hello_led(15)
  """
  def hello_led(channel) do
    driver = %{i2c_bus_name: "i2c-1", frequency: 50} |> ServoKit.PCA9685.new()
    increments = 1..10 |> Enum.to_list() |> Enum.map(&(&1 * 10))
    decrements = 9..0 |> Enum.to_list() |> Enum.map(&(&1 * 10))

    (increments ++ decrements)
    |> Enum.each(fn duty_cycle ->
      ServoKit.PCA9685.set_pwm_duty_cycle(driver, channel, duty_cycle)
      Process.sleep(222)
    end)
  end

  @doc """
  Runs a quick-test program for the Standard Servo.

      ServoKit.hello_standard_servo(0)
  """
  def hello_standard_servo(channel) do
    pid =
      init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: %{}
      )

    set_angle(pid, 0, 180)
    Process.sleep(1234)

    [0, 45, 90, 135, 180, 135, 90, 45, 0]
    |> Enum.each(fn deg ->
      set_angle(pid, channel, deg)
      Process.sleep(555)
    end)
  end

  @doc """
  Runs a quick-test program for the Continuous Servo.

      ServoKit.hello_continuous_servo(8)
  """
  def hello_continuous_servo(channel) do
    pid =
      init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.ContinuousServo,
        servo_options: %{}
      )

    [-1, 0, 1, 0]
    |> Enum.each(fn throttle ->
      set_throttle(pid, channel, throttle)
      Process.sleep(2000)
    end)
  end
end
