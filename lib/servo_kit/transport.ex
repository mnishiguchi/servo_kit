defmodule ServoKit.Transport do
  @moduledoc false

  @type bus_name :: binary() | charlist()
  @type bus :: Circuits.I2C.bus()
  @type address :: Circuits.I2C.address()

  @callback open(bus_name()) ::
              {:ok, bus()} | {:error, any}

  @callback write(bus(), address(), iodata()) ::
              :ok | {:error, any}
end
