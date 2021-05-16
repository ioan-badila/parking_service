defmodule ParkingServiceWeb.PageControllerTest do
  use ParkingServiceWeb.ConnCase, async: false

  import ParkingService.Factories
  alias ParkingService.ParkingPlaces.Store

  setup do
    reset_parking_place_store()

    on_exit(fn ->
      reset_parking_place_store()
    end)
  end

  describe "show" do
    test "returns resource availability", %{conn: conn} do
      resource(id: 1, refreshing_status: :ok, total_places: 10, taken_places: 5)
      |> Store.put()

      response = get(conn, Routes.parking_path(conn, :show, 1))

      assert json_response(response, 200) == %{"total_places" => 10, "taken_places" => 5}
    end

    test "returns an error when resource is unknown", %{conn: conn} do
      response = get(conn, Routes.parking_path(conn, :show, 1))
      assert response.status == 404
    end

    test "returns an error when provided id is not an integer", %{conn: conn} do
      response = get(conn, Routes.parking_path(conn, :show, "boom"))
      assert response.status == 400
      assert response.resp_body =~ "id is invalid"
    end
  end

  describe "update_refresh_period" do
    test "updates resource refresh_period", %{conn: conn} do
      resource(id: 1, refresh_period: 5)
      |> Store.put()

      response =
        post(conn, Routes.parking_path(conn, :update_refresh_period, 1), refresh_period: 10)

      assert response.status == 200
      assert response.resp_body == "OK"
    end

    test "returns an error when resource is unknown", %{conn: conn} do
      response =
        post(conn, Routes.parking_path(conn, :update_refresh_period, 1), refresh_period: 10)

      assert response.status == 404
    end

    test "returns an error when provided id is not an integer", %{conn: conn} do
      response =
        post(conn, Routes.parking_path(conn, :update_refresh_period, "boom"), refresh_period: 10)

      assert response.status == 400
      assert response.resp_body =~ "id is invalid"
    end

    test "returns an error when provided refresh_period is not an integer", %{conn: conn} do
      response =
        post(conn, Routes.parking_path(conn, :update_refresh_period, 1), refresh_period: "boom")

      assert response.status == 400
      assert response.resp_body =~ "refresh_period is invalid"
    end
  end
end
