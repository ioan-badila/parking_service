defmodule ParkingService.ApiClient do
  @moduledoc false

  require Logger

  @doc """
  Returns the availability data for the specified resource
  """
  @spec fetch_data(String.t(), non_neg_integer()) :: {:ok, term()} | {:error, term()}
  def fetch_data(url, id) do
    url
    |> generate_url(id)
    |> HTTPoison.get()
    |> handle_response()
  end

  defp generate_url(url, resource_id) do
    url
    |> URI.parse()
    |> add_resource_id_to_path(resource_id)
    |> URI.to_string()
  end

  defp add_resource_id_to_path(%{path: nil} = uri, resource_id) do
    %{uri | path: "/#{resource_id}"}
  end

  defp add_resource_id_to_path(%{path: path} = uri, resource_id) do
    %{uri | path: Path.join(path, "#{resource_id}")}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Jason.decode(body) do
      {:ok, decoded} -> to_internal(decoded)
      error -> invalid_format(error)
    end
  end

  defp handle_response(resp) do
    Logger.warn("Failed to fetch resource data: #{inspect(resp)}")
    {:error, :failed_to_fetch}
  end

  defp to_internal(%{
         "properties" => %{"num_of_taken_places" => taken, "total_num_of_places" => total}
       })
       when is_integer(taken) and is_integer(total) do
    {:ok, %{total_places: total, taken_places: taken}}
  end

  defp to_internal(response), do: invalid_format(response)

  defp invalid_format(response) do
    Logger.warn("Invalid response format: #{inspect(response)}")
    {:error, :invalid_response_format}
  end
end
