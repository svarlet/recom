defmodule Recom.Storage.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:name, :string)
    field(:start, :utc_datetime_usec)
    field(:end, :utc_datetime_usec)
    field(:price, :integer)
    field(:quantity, :integer)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(product, params \\ %{}) do
    product
    |> cast(params, ~w(name start end price quantity)a)
    |> unique_constraint(:name, name: :unique_product_name_index)
  end
end
