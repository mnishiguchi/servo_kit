defmodule ServoKit.StandardServoTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "constructor" do
    test "with blank config" do
      setup_i2c_mock()
      state = ServoKit.PCA9685.new(%{}) |> ServoKit.StandardServo.new(%{})

      assert %ServoKit.StandardServo{
               driver: %ServoKit.PCA9685{
                 duty_cycles: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                 i2c_ref: _,
                 mode1: 161,
                 pca9685_address: 64,
                 prescale: 121,
                 reference_clock_speed: 25_000_000
               },
               angle_max: 180,
               duty_cycle_minmax: {2.5, 12.5}
             } = state
    end

    test "with some config" do
      setup_i2c_mock()

      state =
        ServoKit.PCA9685.new(%{})
        |> ServoKit.StandardServo.new(%{
          angle_max: 177,
          duty_cycle_minmax: {3.3, 13.3}
        })

      assert %ServoKit.StandardServo{
               angle_max: 177,
               duty_cycle_minmax: {3.3, 13.3}
             } = state
    end

    test "driver is a struct" do
      assert _state = ServoKit.StandardServo.new(%ServoKit.PCA9685{}, %{})
      assert_raise FunctionClauseError, fn -> ServoKit.StandardServo.new(%{}, %{}) end
    end
  end

  test "call" do
    setup_i2c_mock()
    state = ServoKit.PCA9685.new(%{}) |> ServoKit.StandardServo.new(%{})

    assert {:ok, state} = ServoKit.StandardServo.call(state, {:set_angle, [0, 90]})
    assert {:error, "Unsupported command: :hello"} = ServoKit.StandardServo.call(state, :hello)
  end

  test "set_angle" do
    setup_i2c_mock()
    state = ServoKit.PCA9685.new(%{}) |> ServoKit.StandardServo.new(%{})

    {:ok, state} = ServoKit.StandardServo.set_angle(state, 0, 90)
  end

  defp setup_i2c_mock() do
    # https://hexdocs.pm/mox/Mox.html#stub/3
    ServoKit.MockI2C
    |> stub(:open, fn _i2c_bus -> {:ok, Kernel.make_ref()} end)
    |> stub(:write, fn _ref, _address, _data -> :ok end)
  end
end
