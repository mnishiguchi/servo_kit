# Always warning as errors
if Version.match?(System.version(), "~> 1.10") do
  Code.put_compiler_option(:warnings_as_errors, true)
end

# Define dynamic mocks
Mox.defmock(ServoKit.MockTransport, for: ServoKit.Transport)

# Override the config settings
Application.put_env(:servo_kit, :transport_module, ServoKit.MockTransport)

ExUnit.start()
