defmodule ServoKit.PCA9685Test do
  use ExUnit.Case
  alias ServoKit.PCA9685
  doctest ServoKit.PCA9685

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias ServoKit.PCA9685

  setup do
    Mox.stub_with(ServoKit.MockTransport, ServoKit.I2CStub)
    :ok
  end

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "init" do
    test "no config" do
      assert {:ok,
              %PCA9685{
                i2c_ref: _ref,
                mode1: 0xA1,
                i2c_address: 0x40,
                prescale: 121,
                duty_cycles: _
              }} = PCA9685.init()
    end

    test "blank config" do
      assert {:ok, _state} = PCA9685.init(%{})
    end

    test "some config" do
      assert {:ok, _state} = PCA9685.init(%{i2c_bus: "i2c-1"})
    end
  end

  test "reset" do
    state = fake_driver()
    assert {:ok, %PCA9685{}} = PCA9685.reset(state)
  end

  test "sleep" do
    state = fake_driver()
    assert {:ok, %PCA9685{mode1: 0xB1}} = PCA9685.sleep(state)
  end

  test "wake_up" do
    state = fake_driver()
    assert {:ok, %PCA9685{mode1: 0xA1}} = PCA9685.wake_up(state)
  end

  describe "set_pwm_frequency" do
    test "calculate prescale" do
      state = fake_driver()
      assert {:ok, %PCA9685{prescale: 101}} = PCA9685.set_pwm_frequency(state, 60)
      assert {:ok, %PCA9685{prescale: 86}} = PCA9685.set_pwm_frequency(state, 70)
    end
  end

  describe "set_pwm_duty_cycle" do
    test "one channel" do
      state = fake_driver()
      {:ok, state} = PCA9685.set_pwm_duty_cycle(state, 7.5, ch: 1)

      assert {0, 7.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} == state.duty_cycles
    end

    test "all channels" do
      state = fake_driver()
      {:ok, state} = PCA9685.set_pwm_duty_cycle(state, 7.5, ch: :all)

      assert {7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5} ==
               state.duty_cycles
    end
  end

  defp fake_driver do
    %ServoKit.PCA9685{
      duty_cycles: {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      i2c_ref: make_ref(),
      mode1: 161,
      i2c_address: 64,
      prescale: 121,
      reference_clock_speed: 25_000_000
    }
  end
end
