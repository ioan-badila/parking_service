defmodule ParkingService.ResourceTest do
  @doc false

  use ExUnit.Case

  alias ParkingService.Resource

  test "new/1 creates a new resource" do
    assert %Resource{
             id: 1,
             refresh_period: 1,
             last_refresh_at: nil,
             total_places: nil,
             taken_places: nil,
             refreshing_error: nil,
             refreshing_status: :unfetched
           } = Resource.new(%{id: 1, refresh_period: 1})
  end
end
