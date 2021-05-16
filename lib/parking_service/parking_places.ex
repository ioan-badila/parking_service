defmodule ParkingService.ParkingPlaces do
  @moduledoc """
  This is the context responsible with resource management
  """

  use GenServer

  alias ParkingService.Resource
  alias ParkingService.ParkingPlaces.{Configuration, Store}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns the resource with the specified id
  """
  @spec get_resource(Resource.id()) :: {:ok, Resource.t()} | {:error, :not_found}
  def get_resource(id), do: Store.get(id)

  @doc """
  Updates refresh_period for the specified resource
  """
  @spec update_refresh_period(Resource.t(), non_neg_integer()) :: :ok
  def update_refresh_period(%Resource{} = resource, new_period) do
    updated = Resource.update_refresh_period(resource, new_period)
    GenServer.cast(__MODULE__, {:update, updated})
  end

  @doc """
  Updates availability for the specified resource
  """
  @spec update_availability(Resource.t(), non_neg_integer(), non_neg_integer()) :: :ok
  def update_availability(resource, total_places, taken_places) do
    updated = Resource.update_availability(resource, total_places, taken_places)
    GenServer.cast(__MODULE__, {:set_refresh_and_update, updated})
  end

  @doc """
  Lists all resources that needs to be refreshed
  """
  @spec get_resources_for_refreshing(DateTime.t()) :: [Resource.t()]
  def get_resources_for_refreshing(date_time) do
    date_time
    |> DateTime.to_unix()
    |> Store.list_for_refreshing()
  end

  @doc """
  Sets the error and status for the specified resource
  """
  @spec set_refreshing_error(Resource.t(), atom()) :: :ok
  def set_refreshing_error(resource, error) do
    updated = Resource.set_refreshing_error(resource, error)
    GenServer.cast(__MODULE__, {:set_refresh_and_update, updated})
  end

  #
  # Server implementation
  #

  def init(_opts) do
    {:ok, [], {:continue, :load_configured_resources}}
  end

  @doc false
  def handle_continue(:load_configured_resources, state) do
    for resource <- Configuration.get_resources() do
      :ok = Store.put(resource)
    end

    no_reply(state)
  end

  @doc false
  def handle_cast({:set_refresh_and_update, resource}, state) do
    last_refresh_at = DateTime.utc_now()
    :ok = Store.put(%{resource | last_refresh_at: last_refresh_at})
    no_reply(state)
  end

  @doc false
  def handle_cast({:update, resource}, state) do
    :ok = Store.put(resource)
    no_reply(state)
  end

  defp no_reply(x), do: {:noreply, x}
end
