import Config

# Use the mocks defined in test/support/mocks.ex
# https://hexdocs.pm/mox/Mox.html
config :servo_kit,
  i2c_module: ServoKit.MockTransport,
  driver: ServoKit.MockDriver,
  servo: ServoKit.MockMotor
