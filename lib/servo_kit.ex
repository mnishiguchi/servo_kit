defmodule ServoKit do
  @moduledoc false

  use GenServer

  @type options() :: [name: GenServer.name()] | ServoKit.PCA9685.options()

  @type state :: ServoKit.PCA9685.t()

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def set_pwm_frequency(pid \\ __MODULE__, freq_hz) do
    GenServer.call(pid, {:set_pwm_frequency, freq_hz})
  end

  def set_pwm_duty_cycle(pid \\ __MODULE__, duty_cycle, ch: ch) do
    GenServer.call(pid, {:set_pwm_duty_cycle, duty_cycle, ch: ch})
  end

  @impl true
  def init(opts) do
    driver_options = Keyword.take(opts, [:bus_name, :address, :reference_clock_speed, :frequency])
    ServoKit.PCA9685.init(driver_options)
  end

  @impl true
  def handle_call({:set_pwm_frequency, freq_hz}, _from, state) do
    case result = ServoKit.PCA9685.set_pwm_frequency(state, freq_hz) do
      {:ok, new_state} ->
        {:reply, result, new_state}

      {:error, _} ->
        {:reply, result, state}
    end
  end

  def handle_call({:set_pwm_duty_cycle, duty_cycle, ch: ch}, _from, state) do
    case result = ServoKit.PCA9685.set_pwm_duty_cycle(state, duty_cycle, ch: ch) do
      {:ok, new_state} ->
        {:reply, result, new_state}

      {:error, _} ->
        {:reply, result, state}
    end
  end
end
