defmodule Storage.Product do
  use Ecto.Schema

  schema "products" do
    field :name, :string
    field :start, :utc_datetime
    field :end, :utc_datetime

    timestamps type: :utc_datetime
  end
end

defmodule Storage.PurchasablesGateway.Adapters.DbGateway do
  @behaviour Usecases.Shopper.PurchasablesGateway

  @impl true
  def all(_instant) do
    {:ok, []}
  end
end
