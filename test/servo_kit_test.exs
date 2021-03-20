defmodule ServoKit.Test do
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

  describe "start_link" do
    test "passing no options" do
      assert {:ok, _pid} = ServoKit.start_link()
      assert {:error, {:already_started, _pid}} = ServoKit.start_link()
    end

    test "passing some options" do
      assert {:ok, _pid} =
               ServoKit.start_link(
                 name: :test_server,
                 bus_name: "i2c-1",
                 address: 0x40,
                 reference_clock_speed: 25_000_000,
                 frequency: 50
               )
    end
  end
end
