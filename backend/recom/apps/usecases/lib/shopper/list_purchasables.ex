defmodule Usecases.Shopper do
  defmodule PurchasablesGateway do
    alias Entities.Product

    @callback all(instant :: DateTime.t) :: {:ok, list(Product.t)} | {:error, term}
  end

  defmodule ListPurchasables do
    alias Entities.Product

    def list_purchasables(instant, purchasables_gateway) do
      case purchasables_gateway.all(instant) do
        {:ok, purchasables} ->
          {:ok, Enum.sort(purchasables, &Product.before?/2)}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
