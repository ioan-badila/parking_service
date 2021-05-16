defmodule ParkingService.ApiClientTest do
  @doc false

  use ExUnit.Case, async: true

  alias ParkingService.ApiClient

  setup do
    bypass = Bypass.open()
    url = "http://localhost:#{bypass.port}/"
    {:ok, bypass: bypass, url: url}
  end

  test "ApiClient return the correct data", %{bypass: bypass, url: url} do
    Bypass.expect_once(bypass, "GET", "/1", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        ~s({"properties" : {"num_of_taken_places" : 5, "total_num_of_places" : 10}})
      )
    end)

    assert {:ok, %{taken_places: 5, total_places: 10}} == ApiClient.fetch_data(url, 1)
  end

  @tag capture_log: true
  test "ApiClient will turn all mismatch formats", %{bypass: bypass, url: url} do
    Bypass.expect_once(bypass, "GET", "/1", fn conn ->
      Plug.Conn.resp(conn, 200, "not_json")
    end)

    assert {:error, :invalid_response_format} == ApiClient.fetch_data(url, 1)
  end

  @tag capture_log: true
  test "ApiClient will turn all other errors to failed_to_fetch", %{bypass: bypass, url: url} do
    Bypass.expect_once(bypass, "GET", "/1", fn conn ->
      Plug.Conn.resp(conn, 400, "error")
    end)

    assert {:error, :failed_to_fetch} == ApiClient.fetch_data(url, 1)
  end
end
