defmodule ServoKit.ProcessRegistry do
  @moduledoc """
  Registers and manages processes.
  """

  require Logger

  def child_spec(_args) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  @doc """
  Returns a standardized via-tuple for this registry.

  ## Examples

      iex> ProcessRegistry.via_tuple({MyController, 20})
      {:via, Registry, {ProcessRegistry, {MyController, 20}}}
  """
  def via_tuple(key) when is_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @doc """
  Returns a PID or :undefined.

  ## Examples

      iex> ProcessRegistry.whereis_name({MyController, 20})
      #PID<0.235.0>
  """
  def whereis_name(key) when is_tuple(key) do
    Registry.whereis_name({__MODULE__, key})
  end

  @doc """
  Starts a unique registry.
  """
  def start_link() do
    Logger.debug("#{__MODULE__} starting")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def unregister(key) do
    Registry.unregister(__MODULE__, key)
  end
end
