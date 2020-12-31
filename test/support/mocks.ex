# https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements
Mox.defmock(ServoKit.MockI2C, for: ServoKit.I2C.Behaviour)
Mox.defmock(ServoKit.MockDriver, for: ServoKit.Driver)
