defmodule ServoKit.TransportContract do
  @moduledoc false

  @type bus_name :: binary() | charlist()
  @type bus :: Circuits.I2C.bus()
  @type address :: Circuits.I2C.address()

  @callback open(bus_name()) :: {:ok, bus()} | {:error, any}

  @callback write(bus(), address(), iodata()) :: :ok | {:error, any}
end

defmodule ServoKit.Transport do
  @moduledoc """
  Communication bus.
  """

  @behaviour ServoKit.TransportContract

  @type bus_name :: ServoKit.TransportContract.bus_name()
  @type bus :: ServoKit.TransportContract.bus()
  @type address :: ServoKit.TransportContract.address()

  @impl true
  def open(bus_name) do
    apply(delegate_module(), :open, [bus_name])
  end

  @impl true
  def write(i2c_bus, i2c_address, data) do
    apply(delegate_module(), :write, [i2c_bus, i2c_address, data])
  end

  defp delegate_module() do
    Application.get_env(:servo_kit, :transport, Circuits.I2C)
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
