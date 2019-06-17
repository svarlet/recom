defmodule PurchasablesAdapter do
  defstruct return_value: nil

  defimpl Usecases.Shopper.Purchasables do
    def all(adapter, instant) do
      send(self(), {:delegated, instant: instant})
      {:ok, adapter.return_value}
    end
  end
end

defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true
  use Timex

  import Usecases.Shopper.ListProducts

  alias Entities.Product

  test "delegates to the Purchasables protocol" do
    instant = Timex.now()
    list_products(%PurchasablesAdapter{}, instant)
    assert_receive {:delegated, instant: ^instant}
  end

  test "on successful retrieval of products, it relays the returned product" do
    instant = Timex.now()
    expected_products = [
      Product.new(name: "p1", time_span: Interval.new(from: instant, until: Timex.shift(instant, days: 2))),
      Product.new(name: "p2", time_span: Interval.new(from: instant, until: Timex.shift(instant, days: 3))),
    ]
    adapter = %PurchasablesAdapter{return_value: expected_products}
    assert {:ok, expected_products} == list_products(adapter, instant)
  end
end
