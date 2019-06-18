defmodule Usecases.Shopper do
  defmodule PurchasablesGateway do
    alias Entities.Product

    @callback all(instant :: DateTime.t) :: {:ok, list(Product.t)} | {:error, term}
  end

  defmodule ListPurchasables do
    def list_purchasables(instant, purchasables_gateway) do
      purchasables_gateway.all(instant)
    end
  end
end
