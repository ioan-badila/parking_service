defmodule ParkingService.ParkingPlaces.StoreTest do
  @doc false

  use ExUnit.Case, async: false

  import ParkingService.Factories

  alias ParkingService.ParkingPlaces.Store

  setup do
    reset_parking_place_store()
    on_exit(&reset_parking_place_store/0)
  end

  describe "provides storage for resources" do
    @res1 resource(id: 1)
    @res2 resource(id: 2)

    test "common operation" do
      assert :ok = Store.put(@res1)
      assert :ok = Store.put(@res2)

      assert [@res1, @res2] = Store.list()

      assert {:ok, @res2} = Store.get(2)
      assert {:error, :not_found} = Store.get(3)
    end
  end

  describe "lists resources that need to be refreshed" do
    @now DateTime.utc_now()

    @unfetched resource(id: 1, refresh_period: 1, last_refresh_at: nil)
    @stale resource(id: 2, refresh_period: 3, last_refresh_at: DateTime.add(@now, -6 * 60))
    @in_the_future resource(id: 3, refresh_period: 3, last_refresh_at: @now)

    setup do
      Store.put(@unfetched)
      Store.put(@stale)
      Store.put(@in_the_future)
    end

    test "list_for_refreshing" do
      assert [@unfetched, @stale] =
               @now
               |> DateTime.add(60)
               |> DateTime.to_unix()
               |> Store.list_for_refreshing()
    end
  end
end
