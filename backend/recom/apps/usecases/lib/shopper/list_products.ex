defmodule Usecases.Shopper do
  defmodule PurchasablesGateway do
    alias Entities.Product

    @callback all(instant :: DateTime.t) :: {:ok, list(Product.t)} | {:error, term}
  end

  defmodule ListProducts do
    def list_products(purchasables_gateway, instant) do
      purchasables_gateway.all(instant)
    end
  end
end
