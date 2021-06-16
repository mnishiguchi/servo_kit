defmodule ServoKit.I2CStub do
  @moduledoc false

  @behaviour ServoKit.Transport

  def open(_bus_name), do: {:ok, Kernel.make_ref()}

  def write(_reference, _bus_address, _data), do: :ok

  def read(_reference, _bus_address, _bytes_to_read), do: {:ok, "stub"}

  def write_read(_reference, _bus_address, _data, _bytes_to_read), do: {:ok, "stub"}
end
