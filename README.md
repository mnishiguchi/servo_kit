# ServoKit

[![Hex.pm](https://img.shields.io/hexpm/v/servo_kit.svg)](https://hex.pm/packages/servo_kit)
[![API docs](https://img.shields.io/hexpm/v/servo_kit.svg?label=docs)](https://hexdocs.pm/servo_kit)
![CI](https://github.com/mnishiguchi/pca9685/workflows/CI/badge.svg)

Drive PCA9685 PWM/Servo Controller using Elixir

## Installation

You can install this library by adding `servo_kit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:servo_kit, "~> 0.1.0"}
  ]
end
```
## Examples

```elixir
# Initialize a driver.
{:ok, _pid} = ServoKit.start_link()

# Set the duty cycle to 7.5% for Channel 0.
ServoKit.set_pwm_duty_cycle(7.5, ch: 0)
```
## Links

- [PCA9685 Overview](https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685)
- [PCA9685 Datasheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
