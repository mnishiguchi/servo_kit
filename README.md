# PCA9685

![CI](https://github.com/mnishiguchi/pca9685/workflows/CI/badge.svg)

Drive PCA9685 PWM/Servo Controller using Elixir

## Installation

You can install this library by adding `pca9685` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pca9685, "~> 0.0.1"}
  ]
end
```

## Examples

```elixir
# Start the LCD driver and get the initial state.
{:ok, state} = PCA9685.Driver.start(%{i2c_bus_name: "i2c-1"})

# Set the frequency to 50Hz (period: 20ms).
PCA9685.Driver.set_pwm_frequency(state, 50)

# Set the duty cycle of Channel 0 to 7.5%.
PCA9685.Driver.set_pwm_duty_cycle(state, 0, 7.5)
```

## Links

- [PCA9685 Datasheet](https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf)
