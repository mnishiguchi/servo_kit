defmodule ServoKit.ServoControllerTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias ServoKit.ServoController

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup %{} do
    cleanup_server_controller()
    :ok
  end

  test "start_link" do
    setup_servo_mock()
    assert {:ok, pid} = ServoController.start_link(ServoKit.StandardServo, [driver_stub(), %{}])
    assert {:error, "Unsupported command: :hello"} == ServoController.run_command(pid, :hello)
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
      mode2: 4,
      pca9685_address: 64,
      prescale: 121,
      reference_clock_speed: 25_000_000
    }
  end

  defp cleanup_server_controller do
    case ServoKit.ServoController.whereis(ServoKit.StandardServo) do
      nil -> nil
      pid -> Process.exit(pid, :kill)
    end
  end
end
