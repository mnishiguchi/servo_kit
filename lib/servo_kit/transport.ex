defmodule ServoKit.TransportContract do
  @moduledoc false

  @type bus_name :: binary() | charlist()
  @type bus :: Circuits.I2C.bus()
  @type address :: Circuits.I2C.address()

  @callback open(bus_name()) :: {:ok, bus()} | {:error, any}

  @callback write(bus(), address(), iodata()) :: :ok | {:error, any}
end

defmodule ServoKit.Transport do
  @moduledoc false

  @behaviour ServoKit.TransportContract

  @type bus_name :: ServoKit.TransportContract.bus_name()
  @type bus :: ServoKit.TransportContract.bus()
  @type address :: ServoKit.TransportContract.address()

  @impl true
  def open(bus_name) do
    apply(i2c_module(), :open, [bus_name])
  end

  @impl true
  def write(i2c_bus, i2c_address, data) do
    apply(i2c_module(), :write, [i2c_bus, i2c_address, data])
  end

  defp i2c_module() do
    # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
    Application.get_env(:servo_kit, :i2c_module, Circuits.I2C)
  end
end

defmodule ServoKit.TransportStub do
  @moduledoc false

  @behaviour ServoKit.TransportContract

  def open(_bus_name), do: {:ok, Kernel.make_ref()}

  def write(_reference, _bus_address, _data), do: :ok

  def read(_reference, _bus_address, _bytes_to_read), do: {:ok, "stub"}

  def write_read(_reference, _bus_address, _data, _bytes_to_read), do: {:ok, "stub"}
end
