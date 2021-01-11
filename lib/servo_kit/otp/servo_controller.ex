defmodule ServoKit.ServoController do
  @moduledoc """
  Wraps a `ServoKit.Servo` implementation and controls a servo using it.
  The servo state will be held in a process.
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
  @spec whereis(atom) :: nil | pid
  def whereis(servo_module) when is_atom(servo_module) do
    case ServoKit.ProcessRegistry.whereis_name({__MODULE__, servo_module}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @doc """
  Starts a servo driver process.

  driver = ServoKit.PCA9685.new()
  {:ok, pid} = ServoKit.ServoController.start_link(ServoKit.StandardServo, [driver, %{}])
  """
  @spec start_link(atom, [map, ...]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(servo_module, [driver, config])
      when is_atom(servo_module) and is_struct(driver) and is_map(config) do
    servo = apply(servo_module, :new, [driver, config])
    GenServer.start_link(__MODULE__, servo, name: via_tuple(servo_module))
  end

  @doc """
  Delegates the specified operation to the servo driver, and updates the servo state as needed.

      ServoKit.ServoController.run_command(pid, {:set_angle, [0, 180]})
  """
  def run_command(pid, command), do: GenServer.call(pid, command)

  @impl true
  def init(servo), do: {:ok, servo}

  @impl true
  def handle_call(command, _from, servo) do
    Logger.debug(inspect([servo.__struct__, command]))

    case result = run_servo_command(servo, command) do
      {:ok, updated_servo} -> {:reply, result, updated_servo}
      {:error, _} -> {:reply, result, servo}
    end
  end

  # Delegates the operation to the servo module.
  defp run_servo_command(servo, command) when is_struct(servo) do
    apply(servo.__struct__, :call, [servo, command])
  end
end
