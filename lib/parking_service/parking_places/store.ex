defmodule ParkingService.ParkingPlaces.Store do
  @moduledoc false

  alias ParkingService.Resource

  @doc false
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {Eternal, :start_link, [__MODULE__, [:set, {:read_concurrency, true}]]}
    }
  end

  @doc """
  Lists all stored resources
  """
  @spec list() :: [Resource.t()]
  def list() do
    __MODULE__
    |> :ets.tab2list()
    |> Enum.map(&from_ets/1)
    |> Enum.sort_by(& &1.id)
  end

  @doc """
  Lists all stored resources that needs to be refreshed
  """
  @spec list_for_refreshing(integer()) :: [Resource.t()]
  def list_for_refreshing(timestamp) when is_integer(timestamp) do
    __MODULE__
    |> :ets.select([
      {{:_, :_, :"$1"}, [{:<, :"$1", timestamp}], [:"$_"]}
    ])
    |> Enum.map(&from_ets/1)
    |> Enum.sort_by(& &1.id)
  end

  @doc """
  Add/Update resource in the store
  """
  @spec put(Resource.t()) :: :ok
  def put(%Resource{} = resource) do
    :ets.insert(__MODULE__, to_ets(resource))
    :ok
  end

  @doc """
  Returns the resource with the specified id
  """
  @spec get(Resource.id()) :: {:ok, Resource.t()} | {:error, :not_found}
  def get(resource_id) do
    case :ets.lookup(__MODULE__, resource_id) do
      [entry] -> {:ok, from_ets(entry)}
      _ -> {:error, :not_found}
    end
  end

  defp to_ets(%Resource{} = resource) do
    {resource.id, resource, determine_next_refresh(resource)}
  end

  defp determine_next_refresh(%{last_refresh_at: nil}) do
    DateTime.utc_now()
    |> DateTime.to_unix()
  end

  defp determine_next_refresh(resource) do
    last_refreshed = DateTime.to_unix(resource.last_refresh_at)
    last_refreshed + resource.refresh_period * 60
  end

  @spec from_ets({Resource.id(), Resource.t(), DateTime.t()}) :: Resource.t()
  defp from_ets({_id, resource, _next_refresh_at}) do
    resource
  end
end
