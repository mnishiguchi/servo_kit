defmodule ServoKit.ContinuousServoTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "constructor" do
    test "with blank config" do
      setup_i2c_mock()
      state = ServoKit.PCA9685.new(%{}) |> ServoKit.ContinuousServo.new(%{})

      assert %ServoKit.ContinuousServo{
               driver: %ServoKit.PCA9685{
                 duty_cycles: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                 i2c_ref: _,
                 mode1: 161,
                 mode2: 4,
                 pca9685_address: 64,
                 prescale: 121,
                 reference_clock_speed: 25_000_000
               },
               duty_cycle_mid: 8.0,
               duty_cycle_minmax: {2.5, 12.5}
             } = state
    end

    test "driver is a struct" do
      assert _state = ServoKit.ContinuousServo.new(%ServoKit.PCA9685{}, %{})
      assert_raise FunctionClauseError, fn -> ServoKit.ContinuousServo.new(%{}, %{}) end
    end
  end

  test "call" do
    setup_i2c_mock()
    state = ServoKit.PCA9685.new(%{}) |> ServoKit.ContinuousServo.new(%{})

    assert {:ok, state} = ServoKit.ContinuousServo.call(state, {:set_throttle, [0, -0.5]})
    assert {:error, "Unsupported command: :hello"} = ServoKit.ContinuousServo.call(state, :hello)
  end

  test "set_throttle" do
    setup_i2c_mock()
    state = ServoKit.PCA9685.new(%{}) |> ServoKit.ContinuousServo.new(%{})

    {:ok, state} = ServoKit.ContinuousServo.set_throttle(state, 0, -0.5)
  end

  defp setup_i2c_mock() do
    # https://hexdocs.pm/mox/Mox.html#stub/3
    ServoKit.MockI2C
    |> stub(:open, fn _i2c_bus -> {:ok, Kernel.make_ref()} end)
    |> stub(:write, fn _ref, _address, _data -> :ok end)
  end
end
