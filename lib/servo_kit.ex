defmodule ServoKit do
  @moduledoc false

  use GenServer
  require Logger

  @type options() :: [
          motor_module: ServoKit.StandardServo | ServoKit.ContinuousServo,
          motor_options: ServoKit.StandardServo.options() | ServoKit.ContinuousServo.options(),
          name: GenServer.name(),
          bus_name: ServoKit.Transport.bus_name(),
          bus_address: ServoKit.Transport.address()
        ]

  @doc """
  Starts a servo worker process.

  ## Examples

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

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @doc """
  Delegates the specified operation to the servo driver, and updates the servo state as needed.

  ## Examples

      ServoKit.execute(pid, {:set_pwm_duty_cycle, 0, 7.5})

  """
  def execute(pid, command), do: GenServer.call(pid, command)

  @impl true
  def init(opts) do
    motor_module = opts[:motor_module] || ServoKit.StandardServo
    motor_options = opts[:motor_options] || %{}
    driver_options = opts[:driver_options] || %{}

    {:ok, driver} = ServoKit.PCA9685.init(driver_options)
    {:ok, _motor} = apply(motor_module, :init, [driver, motor_options])
  end

  @impl true
  def handle_call(command, _from, motor) do
    case result = run_motor_command(motor, command) do
      {:ok, updated_motor} -> {:reply, result, updated_motor}
      {:error, _} -> {:reply, result, motor}
    end
  end

  # Delegates the motor operation to one of the motor modules.
  defp run_motor_command(motor, command) do
    apply(motor.__struct__, :call, [motor, command])
  end
end
