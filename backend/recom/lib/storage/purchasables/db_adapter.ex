defmodule Recom.Storage.PurchasablesGateway.DbAdapter do
  @behaviour Recom.Usecases.Shopper.PurchasablesGateway
  @behaviour Recom.Usecases.Shopkeeper.CreateProduct.ProductsGateway

  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage.Product
  alias Recom.Storage.PurchasablesGateway.DataMapper
  alias Recom.Entities

  @impl true
  def all(instant) do
    try do
      purchasables =
        from(p in Product, where: p.end > ^instant)
        |> Repo.all()
        |> Enum.map(&DataMapper.convert/1)

      {:ok, purchasables}
    rescue
      _ -> :error
    end
  end

  @impl true
  def store(_) do
    from = Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")

    {:ok,
     Entities.Product.new(
       name: "apples",
       price: 145,
       quantity: 1_000,
       time_span: Interval.new(from: from, until: [days: 1])
     )}
  end
end
