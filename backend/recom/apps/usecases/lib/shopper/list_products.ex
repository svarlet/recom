defmodule Usecases.Shopper do
  defprotocol Purchasables do
    @spec all(Purchasables.t, DateTime.t) :: {:ok, list(Product.t)} | {:error, term}
    def all(adapter, instant)
  end

  defmodule ListProducts do
    def list_products(purchasables_adapter, instant) do
      Purchasables.all(purchasables_adapter, instant)
    end
  end
end
