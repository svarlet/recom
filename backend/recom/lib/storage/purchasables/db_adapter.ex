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

  def save_product(_product) do
    %GatewayError{message: "An unexpected error happened while saving the product."}
  end
end
