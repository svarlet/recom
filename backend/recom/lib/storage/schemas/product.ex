defmodule Recom.Storage.Product do
  use Ecto.Schema

  schema "products" do
    field(:name, :string)
    field(:start, :utc_datetime_usec)
    field(:end, :utc_datetime_usec)
    field(:price, :integer)
    field(:quantity, :integer)

    timestamps(type: :utc_datetime_usec)
  end
end
