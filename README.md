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
    {:servo_kit, "~> 0.0.7"}
  ]
end
```

## Examples

### Dimming an LED

```elixir
# Initialize a driver.
driver = ServoKit.PCA9685.new(%{i2c_bus_name: "i2c-1", frequency: 50})

# Set the duty cycle to 66.6% for Channel 15.
ServoKit.PCA9685.set_pwm_duty_cycle(driver, 15, 66.6)
```
### Controling a standard servo

```elixir
# Initialize a standard servo controller.
pid = ServoKit.init_standard_servo(%{
  duty_cycle_minmax: {2.5, 12.5},
  angle_max: 180
})

# Set the angle to 180 degrees for Channel 0.
ServoKit.set_angle(pid, 0, 180)
```

### Controling a continuous servo

```elixir
# Initialize a continuous servo controller.
pid = ServoKit.init_continuous_servo(%{
  duty_cycle_minmax: {2.5, 12.5},
  # A duty cycle in percent at which the servo stops its movement.
  duty_cycle_mid: 8.0
})

# Throttle full forward for Channel 8.
ServoKit.set_throttle(pid, 8, 1)
# Throttle full reverse for Channel 8.
ServoKit.set_throttle(pid, 8, -1)
# Stop the movement for Channel 8.
ServoKit.set_throttle(pid, 8, 0)
```

## Links

- [PCA9685 Overview](https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685)
- [PCA9685 Datasheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
