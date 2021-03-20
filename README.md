# ServoKit

[![Hex.pm](https://img.shields.io/hexpm/v/servo_kit.svg)](https://hex.pm/packages/servo_kit)
[![API docs](https://img.shields.io/hexpm/v/servo_kit.svg?label=docs)](https://hexdocs.pm/servo_kit)
![CI](https://github.com/mnishiguchi/pca9685/workflows/CI/badge.svg)

Use PCA9685 PWM/Servo Controller in Elixir

## Examples

### Basic usage

```elixir
{:ok, _pid} = ServoKit.start_link()

# Set the duty cycle to 7.5% for Channel 0
ServoKit.set_pwm_duty_cycle(7.5, ch: 0)
```

### Controling a standard servo

```elixir
ServoKit.start_link()

# Define the mapping between the angle in degrees and duty cycle in percentage
angle_range = {0, 180}
duty_cycle_range = {2.5, 12.5}

# Set the angle to 0 degree for channel 0
0 |> ServoKit.map(angle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)

# Set the angle to 90 degree for channel 0
90 |> ServoKit.map(angle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)

# Set the angle to 180 degree for channel 0
180 |> ServoKit.map(angle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)
```

### Controling a continuous servo

```elixir
ServoKit.start_link()

# Define the mapping between the throttle -1..1 and duty cycle in percentage
throttle_range = {-1.0, 1.0}
duty_cycle_range = {2.5, 12.5}

# Stop the actuator for channel 0
0 |> ServoKit.map(throttle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)

# Throttle full speed forward for channel 0
1.0 |> ServoKit.map(throttle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)

# Throttle full speed reverse for channel 0
-1.0 |> ServoKit.map(throttle_range, duty_cycle_range) |> ServoKit.set_pwm_duty_cycle(ch: 0)
```

## Links

- [PCA9685 Overview](https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685)
- [PCA9685 Data Sheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
