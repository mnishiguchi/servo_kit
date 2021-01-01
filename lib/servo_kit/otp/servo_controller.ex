defmodule ServoKit.ServoController do
  @moduledoc """
  Wraps a servo module and controls a servo using that module.
  The servo state will be kept in a process.
  """

  use GenServer
  require Logger

  def child_spec(servo_module, [driver, config])
      when is_atom(servo_module) and is_struct(driver) and is_map(config) do
    %{
      id: {__MODULE__, servo_module},
      start: {__MODULE__, :start_link, [servo_module, [driver, config]]}
    }
  end

  defp via_tuple(servo_module) when is_atom(servo_module) do
    ServoKit.ProcessRegistry.via_tuple({__MODULE__, servo_module})
  end

  @doc """
  Discovers a servo process by servo module name.
  """
  def whereis(servo_module) when is_atom(servo_module) do
    case ServoKit.ProcessRegistry.whereis_name({__MODULE__, servo_module}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def unregister(servo_module) do
    ServoKit.ProcessRegistry.unregister({__MODULE__, servo_module})
  end

  @doc """
  Starts a servo driver process and registers the process.

  ## Examples

      driver = ServoKit.PCA9685.new()
      {:ok, pid} = ServoKit.ServoController.start_link(ServoKit.StandardServo, [driver, %{}])
  """
  def start_link(servo_module, [driver, config])
      when is_atom(servo_module) and is_struct(driver) and is_map(config) do
    servo = apply(servo_module, :new, [driver, config])
    GenServer.start_link(__MODULE__, servo, name: via_tuple(servo_module))
  end

  @doc """
  Delegates the specified operation to the servo driver, and updates the state as needed.

  ## Examples

      ServoKit.ServoController.call(pid, {:set_angle, [0, 180]})
  """
  def call(pid, command), do: GenServer.call(pid, command)

  @impl true
  def init(servo), do: {:ok, servo}

  @impl true
  def handle_call(command, _from, servo) do
    Logger.debug(inspect([servo.__struct__, command]))

    case result = control_servo(servo, command) do
      {:ok, updated_servo} -> {:reply, result, updated_servo}
      {:error, _} -> {:reply, result, servo}
    end
  end

  defp control_servo(servo, command) when is_struct(servo) do
    apply(servo.__struct__, :call, [servo, command])
  end
end
