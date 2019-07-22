defmodule Recom.Storage.PurchasablesGateway.DbAdapter do
  @behaviour Recom.Usecases.Shopper.PurchasablesGateway

  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DataMapper
  alias Recom.Usecases.Shopkeeper.CreateProduct.GatewayError

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

  def save_product(product) do
    try do
      record = %Storage.Product{
        name: product.name,
        price: product.price,
        quantity: product.quantity,
        start: Timex.to_datetime(product.time_span.from, "Etc/UTC"),
        end: Timex.to_datetime(product.time_span.until, "Etc/UTC")
      }

      Repo.insert!(record)
    rescue
      _ ->
        %GatewayError{message: "An unexpected error happened while saving the product."}
    end
  end
end
