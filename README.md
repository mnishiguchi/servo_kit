# ServoKit

[![Hex.pm](https://img.shields.io/hexpm/v/servo_kit.svg)](https://hex.pm/packages/servo_kit)
[![API docs](https://img.shields.io/hexpm/v/servo_kit.svg?label=hexdocs)](https://hexdocs.pm/servo_kit)
![CI](https://github.com/mnishiguchi/pca9685/workflows/CI/badge.svg)

Drive PCA9685 PWM/Servo Controller using Elixir

## Installation

You can install this library by adding `servo_kit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:servo_kit, "~> 0.0.4"}
  ]
end
```

## Examples

```elixir
# Initialize a driver.
{:ok, driver} = ServoKit.PCA9685.new(%{i2c_bus_name: "i2c-1"})

# Set the frequency to 50Hz (period: 20ms).
{:ok, driver}  = ServoKit.PCA9685.set_pwm_frequency(driver, 50)

# Set the duty cycle of Channel 0 to 7.5%.
{:ok, driver}  = ServoKit.PCA9685.set_pwm_duty_cycle(driver, 0, 7.5)
```

## Links

- [PCA9685 Overview](https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685)
- [PCA9685 Datasheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
