defmodule Usecases.Shopper.ListProducts do
  alias Entities.Product

  def list_products(products, instant) do
    for p <- products, Product.purchasable?(p, instant) do
      p
    end
  end
end
