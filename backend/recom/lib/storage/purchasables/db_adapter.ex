defmodule Recom.Storage.PurchasablesGateway.DbAdapter do
  @behaviour Recom.Usecases.Shopper.PurchasablesGateway
  @behaviour Recom.Usecases.Shopkeeper.ProductsGateway

  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DataMapper

  @impl true
  def all(instant) do
    try do
      purchasables =
        from(p in Storage.Product, where: p.end > ^instant)
        |> Repo.all()
        |> Enum.map(&DataMapper.convert/1)

      {:ok, purchasables}
    rescue
      _ -> :error
    end
  end

  @impl true
  def store(product) do
    product_to_save = %Storage.Product{
      name: product.name,
      price: product.price,
      quantity: product.quantity,
      start: Timex.to_datetime(product.time_span.from, "Etc/UTC"),
      end: Timex.to_datetime(product.time_span.until, "Etc/UTC")
    }

    {:ok, saved_product} = Repo.insert(product_to_save)

    {:ok, DataMapper.convert(saved_product)}
  end
end
