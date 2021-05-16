defmodule ParkingService.ParkingPlacesTest do
  @doc false

  use ExUnit.Case, async: false

  import ParkingService.Factories

  alias ParkingService.ParkingPlaces
  alias ParkingService.ParkingPlaces.Store

  setup do
    reset_parking_place_store()
    Supervisor.terminate_child(ParkingPlaces.Supervisor, ParkingPlaces)

    on_exit(fn ->
      reset_parking_place_store()
      Supervisor.restart_child(ParkingPlaces.Supervisor, ParkingPlaces)
    end)
  end

  test "loads configured resources" do
    start_supervised!(ParkingPlaces)
    assert Store.list() |> length() == 7
  end

  describe "get_resource" do
    @res resource(id: 1)

    test "returns resource" do
      Store.put(@res)
      assert {:ok, @res} == ParkingPlaces.get_resource(1)
    end

    test "returns an error when not found" do
      assert {:error, :not_found} = ParkingPlaces.get_resource(3)
    end
  end

  describe "update the resource" do
    @res resource(id: 1)

    setup do
      Store.put(@res)
    end

    test "updates refresh period" do
      start_supervised!(ParkingPlaces)
      assert {:ok, %{refresh_period: 5, last_refresh_at: nil}} = ParkingPlaces.get_resource(1)
      assert :ok = ParkingPlaces.update_refresh_period(@res, 7)

      assert becomes_true(200, fn ->
               match?(
                 {:ok, %{refresh_period: 7, last_refresh_at: nil}},
                 ParkingPlaces.get_resource(1)
               )
             end)
    end

    test "sets last_refresh_at and updates availability" do
      start_supervised!(ParkingPlaces)

      assert {:ok,
              %{
                refreshing_status: :unfetched,
                total_places: nil,
                taken_places: nil,
                last_refresh_at: nil
              }} = ParkingPlaces.get_resource(1)

      assert :ok = ParkingPlaces.update_availability(@res, 10, 5)

      assert becomes_true(200, fn ->
               {:ok, resource} = ParkingPlaces.get_resource(1)

               match?(%{refreshing_status: :ok, total_places: 10, taken_places: 5}, resource) &&
                 not is_nil(resource.last_refresh_at)
             end)
    end

    test "sets last_refresh_at, error and status" do
      start_supervised!(ParkingPlaces)

      assert {:ok, %{refreshing_status: :unfetched, refreshing_error: nil, last_refresh_at: nil}} =
               ParkingPlaces.get_resource(1)

      assert :ok = ParkingPlaces.set_refreshing_error(@res, :boom)

      assert becomes_true(200, fn ->
               {:ok, resource} = ParkingPlaces.get_resource(1)

               match?(%{refreshing_status: :bad_request, refreshing_error: :boom}, resource) &&
                 not is_nil(resource.last_refresh_at)
             end)
    end
  end

  describe "get_resources_for_refreshing" do
    @now DateTime.utc_now()

    @unfetched resource(id: 1, refresh_period: 1, last_refresh_at: nil)
    @stale resource(id: 2, refresh_period: 3, last_refresh_at: DateTime.add(@now, -4 * 60))
    @in_the_future resource(id: 3, refresh_period: 3, last_refresh_at: @now)

    setup do
      Store.put(@unfetched)
      Store.put(@stale)
      Store.put(@in_the_future)
    end

    test "resources that need to be refreshed" do
      assert [@unfetched, @stale] =
               ParkingPlaces.get_resources_for_refreshing(DateTime.add(@now, 60))
    end
  end
end
