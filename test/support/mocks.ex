# https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements
Mox.defmock(ServoKit.MockTransport, for: ServoKit.TransportContract)
Mox.defmock(ServoKit.MockDriver, for: ServoKit.DriverContract)
