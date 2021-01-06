defmodule ServoKit.PCA9685Test do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias ServoKit.PCA9685

  setup do
    setup_i2c_mock()
    :ok
  end

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "start" do
    test "no config" do
      assert %PCA9685{i2c_ref: _ref, mode1: 0xA1, pca9685_address: 0x40, prescale: 121} = PCA9685.new()
    end

    test "blank config" do
      assert _state = PCA9685.new(%{})
    end

    test "some config" do
      assert _state = PCA9685.new(%{i2c_bus: "i2c-1"})
    end
  end

  test "reset" do
    state = PCA9685.new(%{})
    assert %PCA9685{} = PCA9685.reset(state)
  end

  test "sleep" do
    state = PCA9685.new(%{})
    assert %PCA9685{mode1: 0xB1} = PCA9685.sleep(state)
  end

  test "wake_up" do
    state = PCA9685.new(%{})
    assert %PCA9685{mode1: 0xA1} = PCA9685.wake_up(state)
  end

  describe "set_pwm_frequency" do
    test "calculate prescale" do
      state = PCA9685.new(%{})
      assert %PCA9685{prescale: 101} = PCA9685.set_pwm_frequency(state, 60)
      assert %PCA9685{prescale: 86} = PCA9685.set_pwm_frequency(state, 70)
    end
  end

  describe "set_pwm_duty_cycle" do
    test "one channel" do
      state = PCA9685.new(%{})
      state = PCA9685.set_pwm_duty_cycle(state, 1, 60.0)

      assert [
               0,
               60.0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0
             ] == state.duty_cycles
    end

    test "all channels" do
      state = PCA9685.new(%{})
      state = PCA9685.set_pwm_duty_cycle(state, :all, 60.0)

      assert [
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0
             ] == state.duty_cycles
    end
  end

  defp setup_i2c_mock() do
    # https://hexdocs.pm/mox/Mox.html#stub/3
    ServoKit.MockI2C
    |> stub(:open, fn _i2c_bus -> {:ok, Kernel.make_ref()} end)
    |> stub(:write, fn _ref, _address, _data -> :ok end)
  end
end
