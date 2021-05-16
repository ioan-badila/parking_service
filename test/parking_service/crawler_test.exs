defmodule ParkingService.CrawlerTest do
  @doc false

  use ExUnit.Case, async: false

  import ParkingService.Factories

  alias ParkingService
  alias ParkingService.Crawler

  setup do
    Supervisor.terminate_child(ParkingService.Supervisor, Crawler)

    on_exit(fn ->
      Supervisor.restart_child(ParkingService.Supervisor, Crawler)
      :fuse.reset(ParkingService.Crawler)
    end)
  end

  test "can be configured with an initial delay" do
    start_supervised!({Crawler, initial_delay: 10, url: "http://localhost"})
    assert run_count_reaches(_count = 1, _timeout = 50)
  end

  test "can be configured with polling delay" do
    start_supervised!({Crawler, initial_delay: 0, fetch_delay: 10, url: "http://localhost"})
    assert run_count_reaches(_count = 4, _timeout = 100)
  end

  @tag capture_log: true
  test "refreshes all resources waiting for refreshing" do
    last_refresh_at = DateTime.utc_now() |> DateTime.add(-6 * 60)

    for resource_id <- 1..10 do
      resource(id: resource_id, refresh_period: 1, last_refresh_at: last_refresh_at)
      |> ParkingService.ParkingPlaces.Store.put()
    end

    start_supervised!({Crawler, initial_delay: 0, url: "http://localhost"})
    assert processed_resource_count_reaches(_count = 10, _timeout = 500)

    for resource_id <- 1..10 do
      assert {:ok, %{refreshing_status: :bad_request, last_refresh_at: new_last_refresh_at}} =
               ParkingService.ParkingPlaces.get_resource(resource_id)

      assert DateTime.compare(new_last_refresh_at, last_refresh_at) == :gt
    end
  end

  @tag capture_log: true
  test "allows 10 failures" do
    execute_and_fail_for(10)
    assert :fuse.ask(ParkingService.Crawler, :sync) == :ok
  end

  @tag capture_log: true
  test "blows fuses after 10 failures" do
    execute_and_fail_for(11)
    assert :fuse.ask(ParkingService.Crawler, :sync) == :blown
  end

  defp execute_and_fail_for(times) do
    last_refresh_at = DateTime.utc_now() |> DateTime.add(-6 * 60)

    for resource_id <- 1..times do
      resource(id: resource_id, refresh_period: 1, last_refresh_at: last_refresh_at)
      |> ParkingService.ParkingPlaces.Store.put()
    end

    start_supervised!({Crawler, initial_delay: 0, url: "http://localhost"})
    assert processed_resource_count_reaches(_count = times, _timeout = 500)
  end

  defp run_count_reaches(count, timeout) do
    becomes_true(timeout, fn -> Crawler.get_stats()[:run_count] >= count end)
  end

  defp processed_resource_count_reaches(count, timeout) do
    becomes_true(timeout, fn -> Crawler.get_stats()[:refreshed_resource_count] >= count end)
  end
end
