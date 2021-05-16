defmodule ParkingService.Resource do
  @moduledoc """
  Represents a resource.

  Contains information about availability and refreshing state
  """

  @type id :: non_neg_integer()
  @type t :: %__MODULE__{
          id: id,
          total_places: non_neg_integer(),
          taken_places: non_neg_integer(),
          refresh_period: non_neg_integer(),
          last_refresh_at: DateTime.t(),
          refreshing_error: term(),
          refreshing_status: atom()
        }

  @enforce_keys [:id, :refresh_period]
  defstruct id: nil,
            refresh_period: nil,
            last_refresh_at: nil,
            total_places: nil,
            taken_places: nil,
            refreshing_error: nil,
            refreshing_status: :unfetched

  @doc """
  Creates a new resource

  Fields `id` and `refresh_period` are required
  """
  @spec new(struct() | Enum.t()) :: t()
  def new(opts) do
    struct!(__MODULE__, opts)
  end

  @doc """
  Updates resource availability
  """
  @spec update_availability(t(), non_neg_integer(), non_neg_integer()) :: t()
  def update_availability(%__MODULE__{} = resource, total_places, taken_places) do
    %{resource | refreshing_status: :ok, total_places: total_places, taken_places: taken_places}
  end

  @doc """
  Updates resource refresh period
  """
  @spec update_refresh_period(t(), non_neg_integer()) :: t()
  def update_refresh_period(%__MODULE__{} = resource, new_period) do
    %{resource | refresh_period: new_period}
  end

  @doc """
  Sets refreshing error and status for a resource
  """
  @spec set_refreshing_error(t(), term()) :: t()
  def set_refreshing_error(resource, :invalid_response_format) do
    %{resource | refreshing_status: :unprocessable, refreshing_error: :invalid_response_format}
  end

  def set_refreshing_error(resource, refreshing_error) do
    %{resource | refreshing_status: :bad_request, refreshing_error: refreshing_error}
  end
end
