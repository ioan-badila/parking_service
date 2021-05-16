defmodule ParkingService.Crawler do
  @moduledoc false

  defstruct fetch_delay: nil,
            timer_ref: nil,
            url: nil,
            run_count: 0,
            refreshed_resource_count: 0

  use GenServer

  alias ParkingService.ParkingPlaces.Configuration
  alias ParkingService.ParkingPlaces
  alias ParkingService.ApiClient

  @initial_delay :timer.minutes(1)
  @fetch_delay :timer.minutes(1)

  @doc """
  Retrieves statistics about the crawler
  """
  @type stats :: %{
          run_count: non_neg_integer(),
          refreshed_resource_count: non_neg_integer()
        }
  @spec get_stats() :: stats
  def get_stats(), do: GenServer.call(__MODULE__, :get_stats)

  @doc """
  Start the crawler
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  #
  # Server implementation
  #

  @doc false
  def init(opts) do
    initial_delay = Keyword.get(opts, :initial_delay, @initial_delay)
    fetch_delay = Keyword.get(opts, :fetch_delay, @fetch_delay)
    url = Keyword.get(opts, :url, Configuration.get_endpoint())

    %__MODULE__{fetch_delay: fetch_delay, url: url}
    |> schedule_refreshing(initial_delay)
    |> ok()
  end

  @doc false
  def handle_call(:get_stats, _from, state) do
    stats = Map.take(state, [:run_count, :refreshed_resource_count])
    {:reply, stats, state}
  end

  @doc false
  def handle_info(:fetch, state) do
    state
    |> refresh_resources()
    |> increment_run_count()
    |> schedule_refreshing(state.fetch_delay)
    |> no_reply()
  end

  defp refresh_resources(state) do
    resources = ParkingPlaces.get_resources_for_refreshing(DateTime.utc_now())

    for resource <- resources do
      result = ApiClient.fetch_data(state.url, resource.id)
      update_resource(resource, result)
    end

    state
    |> increment_refreshed_resource_count_by(length(resources))
  end

  defp update_resource(resource, {:ok, data}),
    do: ParkingPlaces.update_availability(resource, data.total_places, data.taken_places)

  defp update_resource(resource, {:error, error}),
    do: ParkingPlaces.set_refreshing_error(resource, error)

  defp schedule_refreshing(state, delay) do
    if state.timer_ref, do: Process.cancel_timer(state.timer_ref)
    %{state | timer_ref: Process.send_after(self(), :fetch, delay)}
  end

  defp increment_refreshed_resource_count_by(state, count) do
    %{state | refreshed_resource_count: state.refreshed_resource_count + count}
  end

  defp increment_run_count(state) do
    %{state | run_count: state.run_count + 1}
  end

  defp ok(x), do: {:ok, x}
  defp no_reply(x), do: {:noreply, x}
end
