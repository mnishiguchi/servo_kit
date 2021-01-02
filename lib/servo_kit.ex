defmodule ServoKit do
  @moduledoc false

  @doc """
  Initializes a `ServoController`.

      ServoKit.init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: %{}
      )
  """
  def init_servo_controller([driver_module: _, driver_options: _, servo_module: _, servo_options: _] = args) do
    _pid = ServoKit.ServoSupervisor.servo_controller(args)
  end

  @doc """
  Runs a servo command through a `ServoController`.

      ServoKit.run_servo_command(pid, {:set_angle, [0, 90]})
  """
  def run_servo_command(pid, command) do
    ServoKit.ServoController.run_command(pid, command)
  end

  ##
  ## DEMO programs
  ##

  @doc """
  Runs a quick-test program for the LED brightness.

      ServoKit.hello_led
  """
  def hello_led(channel \\ 15) do
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

      ServoKit.hello_standard_servo
  """
  def hello_standard_servo(channel \\ 0) do
    pid =
      init_servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: %{}
      )

    run_servo_command(pid, {:set_angle, [0, 180]})
    Process.sleep(1234)

    [0, 45, 90, 135, 180, 135, 90, 45, 0]
    |> Enum.each(fn deg ->
      run_servo_command(pid, {:set_angle, [channel, deg]})
      Process.sleep(555)
    end)
  end
end
