defmodule ServoKit do
  @moduledoc """
  Use PCA9685 PWM/Servo Controller in Elixir
  """

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

  @doc """
  Maps a given value in one range to another range.

  ## Examples

      iex> ServoKit.map(0, {0, 180}, {2.5, 12.5})
      2.5

      iex> ServoKit.map(45, {0, 180}, {2.5, 12.5})
      5.0

      iex> ServoKit.map(90, {0, 180}, {2.5, 12.5})
      7.5

      iex> ServoKit.map(180, {0, 180}, {2.5, 12.5})
      12.5

      iex> ServoKit.map(0, {-1.0, 1.0}, {2.5, 12.5})
      7.5

      iex> ServoKit.map(-1, {-1.0, 1.0}, {2.5, 12.5})
      2.5

      iex> ServoKit.map(1, {-1.0, 1.0}, {2.5, 12.5})
      12.5

  """
  @spec map(number, {number, number}, {number, number}) :: float
  def map(x, {in_min, in_max}, {out_min, out_max})
      when is_number(x) and
             is_number(in_min) and is_number(in_max) and in_min < in_max and
             is_number(out_min) and is_number(out_max) and out_min < out_max do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end
end
