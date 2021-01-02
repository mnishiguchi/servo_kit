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
    {:servo_kit, "~> 0.0.6"}
  ]
end
```

## Examples

### Basic usage

```elixir
# Initialize a driver.
%{i2c_bus_name: "i2c-1", frequency: 50}
|> ServoKit.PCA9685.new()
# Set the duty cycle to 66.6% for Channel 15.
|> ServoKit.PCA9685.set_pwm_duty_cycle(15, 66.6)
```

### Controling a standard servo

```elixir
pid =
  ServoKit.init_servo_controller(
    driver_module: ServoKit.PCA9685,
    driver_options: %{},
    servo_module: ServoKit.StandardServo,
    servo_options: %{}
  )

# Set the angle to 180 degrees for Channel 0.
ServoKit.run_servo_command(pid, {:set_angle, [0, 180]})
```

## Links

- [PCA9685 Overview](https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685)
- [PCA9685 Datasheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
