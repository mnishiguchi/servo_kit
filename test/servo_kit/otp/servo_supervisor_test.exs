defmodule ServoKit.ServoSupervisorTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias ServoKit.ServoSupervisor

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "should be already started" do
    setup_servo_mock()
    assert {:error, {:already_started, _pid}} = ServoSupervisor.start_link(nil)
  end

  test "servo_controller returns a different pid every call" do
    setup_servo_mock()

    pid1 = ServoSupervisor.servo_controller(ServoKit.StandardServo, [driver_stub(), %{}])
    assert is_pid(pid1)

    pid2 = ServoSupervisor.servo_controller(ServoKit.StandardServo, [driver_stub(), %{}])
    refute Process.alive?(pid1)
  end

  defp setup_servo_mock() do
    # https://hexdocs.pm/mox/Mox.html#stub/3
    stub(ServoKit.MockDriver, :new, fn _opts -> {:ok, servo_stub()} end)
  end

  defp servo_stub() do
    %ServoKit.StandardServo{
      angle_max: 180,
      driver: driver_stub(),
      duty_cycle_minmax: {2.5, 12.5}
    }
  end

  defp driver_stub() do
    %ServoKit.PCA9685{
      duty_cycles: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      i2c_ref: make_ref(),
      mode1: 161,
      pca9685_address: 64,
      prescale: 121,
      reference_clock_speed: 25_000_000
    }
  end
end
