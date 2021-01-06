defmodule ServoKit.ServoSupervisor do
  @moduledoc """
  Supervises `ServoKit.ServoController` processes.
  """

  # https://hexdocs.pm/elixir/DynamicSupervisor.html
  use DynamicSupervisor

  require Logger

  alias ServoKit.ServoController

  def start_link(_args) do
    Logger.debug("#{__MODULE__} starting")
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Creates a `ServoKit.ServoController` process.

      pid = ServoKit.ServoSupervisor.servo_controller(
        driver_module: ServoKit.PCA9685,
        driver_options: %{},
        servo_module: ServoKit.StandardServo,
        servo_options: %{}
      )
  """
  def servo_controller(
        [
          driver_module: driver_module,
          driver_options: driver_options,
          servo_module: servo_module,
          servo_options: servo_options
        ] = _config
      )
      when is_atom(driver_module) and is_map(driver_options) and is_atom(servo_module) and is_map(servo_options) do
    driver = apply(driver_module, :new, [driver_options])
    servo_controller(servo_module, [driver, servo_options])
  end

  @doc """
  Creates a `ServoKit.ServoController` process.

      driver = ServoKit.PCA9685.new(%{})
      servo_moodule = ServoKit.StandardServo
      servo_options = %{}
      pid = ServoKit.ServoSupervisor.servo_controller(servo_module, [driver, servo_options])
  """
  def servo_controller(servo_module, servo_args) do
    case ServoController.whereis(servo_module) do
      nil ->
        start_child(servo_module, servo_args)

      pid ->
        Logger.info("Recreating the servo controller for #{servo_module}")
        Process.exit(pid, :kill)
        servo_controller(servo_module, servo_args)
    end
  end

  defp start_child(servo_module, servo_args) when is_atom(servo_module) and is_list(servo_args) do
    case DynamicSupervisor.start_child(__MODULE__, ServoController.child_spec(servo_module, servo_args)) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
