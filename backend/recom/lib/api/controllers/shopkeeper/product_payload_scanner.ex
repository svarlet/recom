defmodule Recom.Api.Shopkeeper.ProductPayloadScanner do
  use Ecto.Schema
  use Timex

  import Ecto.Changeset

  alias Recom.Entities.Product

  @behaviour Recom.Api.Shopkeeper.PayloadScannerPlug

  embedded_schema do
    field(:name, :string)
    field(:price, :integer)
    field(:quantity, :integer)
    field(:from, :utc_datetime_usec)
    field(:end, :utc_datetime_usec)
  end

  def scan(payload) do
    changeset = changeset(%__MODULE__{}, payload)

    if changeset.valid? do
      {:ok, apply_changes(changeset) |> to_product()}
    else
      {:error, "This payload does not represent a valid product."}
    end
  end

  defp changeset(schema, params) do
    schema
    |> cast(params, ~w{name price quantity from end}a)
    |> validate_required(~w{name price quantity from end}a)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_daterange()
  end

  def validate_daterange(changeset) do
    validate_change(changeset, :end, fn _, _ ->
      with {:ok, from} <- Map.fetch(changeset.changes, :from),
           {:ok, the_end} <- Map.fetch(changeset.changes, :end) do
        case Timex.Interval.new(from: from, until: the_end) do
          {:error, :invalid_until} ->
            [end: "must succeed to 'from'"]

          _valid_interval ->
            []
        end
      else
        :error -> [end: "or its counterpart is missing"]
      end
    end)
  end

  defp to_product(payload) do
    %Product{
      name: payload.name,
      price: payload.price,
      quantity: payload.quantity,
      time_span: Interval.new(from: payload.from, until: payload.end)
    }
  end
end
