defmodule ServoKit.StandardServoTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    Mox.stub_with(ServoKit.MockDriver, ServoKit.DriverStub)
    :ok
  end

  describe "constructor" do
    test "with blank config" do
      {:ok, motor} = ServoKit.StandardServo.init(fake_driver(), %{})

      assert %ServoKit.StandardServo{
               driver: %ServoKit.PCA9685{},
               duty_cycle_minmax: {2.5, 12.5}
             } = motor
    end

    test "with some config" do
      {:ok, motor} = ServoKit.StandardServo.init(fake_driver(), %{duty_cycle_minmax: {3.3, 13.3}})

      assert %ServoKit.StandardServo{duty_cycle_minmax: {3.3, 13.3}} = motor
    end

    test "driver is a struct" do
      assert _motor = ServoKit.StandardServo.init(%ServoKit.PCA9685{}, %{})
      assert_raise FunctionClauseError, fn -> ServoKit.StandardServo.init(%{}, %{}) end
    end
  end

  test "call" do
    {:ok, motor} = ServoKit.StandardServo.init(fake_driver(), %{})

    assert {:ok, motor} = ServoKit.StandardServo.call(motor, {:set_pwm_duty_cycle, 0, 50})
    assert {:error, "Unsupported command: :hello"} = ServoKit.StandardServo.call(motor, :hello)
  end

  test "set_pwm_duty_cycle" do
    {:ok, motor} = ServoKit.StandardServo.init(fake_driver(), %{})

    assert {:ok, _} = ServoKit.StandardServo.set_pwm_duty_cycle(motor, 0, 50)
  end

  defp fake_driver do
    ServoKit.DriverStub.fake_driver()
  end
end
