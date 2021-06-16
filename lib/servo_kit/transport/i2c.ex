defmodule ServoKit.I2C do
  @moduledoc false

  @behaviour ServoKit.Transport

  @impl true
  def open(bus_name) do
    transport_module().open(bus_name)
  end

  @impl true
  def write(i2c_bus, i2c_address, data) do
    transport_module().write(i2c_bus, i2c_address, data)
  end

  defp transport_module() do
    Application.get_env(:servo_kit, :transport_module, Circuits.I2C)
  end
end
