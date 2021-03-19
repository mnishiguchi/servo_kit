defmodule ServoKit.ContinuousServoTest do
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
      {:ok, motor} = ServoKit.ContinuousServo.init(fake_driver(), %{})

      assert %ServoKit.ContinuousServo{
               driver: %ServoKit.PCA9685{},
               duty_cycle_mid: 7.5,
               duty_cycle_minmax: {2.5, 12.5}
             } = motor
    end

    test "driver is a struct" do
      assert {:ok, _motor} = ServoKit.ContinuousServo.init(%ServoKit.PCA9685{}, %{})
      assert_raise FunctionClauseError, fn -> ServoKit.ContinuousServo.init(%{}, %{}) end
    end
  end

  test "call" do
    {:ok, motor} = ServoKit.ContinuousServo.init(fake_driver(), %{})

    assert {:ok, motor} = ServoKit.ContinuousServo.call(motor, {:set_throttle, 0, -0.5})
    assert {:error, "Unsupported command: :hello"} = ServoKit.ContinuousServo.call(motor, :hello)
  end

  test "set_throttle" do
    {:ok, motor} = ServoKit.ContinuousServo.init(fake_driver(), %{})

    assert {:ok, _} = ServoKit.ContinuousServo.set_throttle(motor, 0, -0.5)
  end

  defp fake_driver do
    ServoKit.DriverStub.fake_driver()
  end
end
