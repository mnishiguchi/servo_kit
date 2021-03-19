defmodule ServoKitTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  # Any process can consume mocks and stubs defined in your tests.
  setup :set_mox_from_context

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    Mox.stub_with(ServoKit.MockTransport, ServoKit.TransportStub)
    :ok
  end

  test "start_link" do
    # Passing no options
    assert {:ok, pid} = ServoKit.start_link()

    # Passing some options
    assert {:ok, pid} =
             ServoKit.start_link(
               name: :test_server,
               motor_module: ServoKit.StandardServo,
               motor_options: %{},
               driver_options: %{}
             )

    # Run a motor command
    assert {:error, "Unsupported command: :hello"} == ServoKit.execute(pid, :hello)
    assert {:error, "Unsupported command: :world"} == ServoKit.execute(:test_server, :world)
  end
end
