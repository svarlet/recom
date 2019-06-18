defmodule Storage.Product do
  use Ecto.Schema

  schema "products" do
    field :name, :string
    field :start, :utc_datetime_usec
    field :end, :utc_datetime_usec

    timestamps type: :utc_datetime_usec
  end
end
