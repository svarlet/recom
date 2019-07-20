defmodule Recom.Api.Shopkeeper.CreateProduct.Payload do
  use Ecto.Schema
  use Timex

  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:price, :integer)
    field(:quantity, :integer)
    field(:from, :utc_datetime_usec)
    field(:end, :utc_datetime_usec)
  end

  def changeset(schema, params) do
    schema
    |> cast(params, ~w{name price quantity from end}a)
    |> validate_required(~w{name price quantity from end}a)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_daterange()
  end

  defp validate_daterange(changeset) do
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
end
