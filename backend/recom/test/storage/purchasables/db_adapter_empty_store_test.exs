defmodule Recom.Storage.PurchasablesGateway.DbAdapter_EmptyStoreTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Entities
  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Storage

  describe "all/1" do
    test "given no products, when requesting all purchasables, it returns {:ok, []}" do
      irrelevant_instant = Timex.now()
      assert {:ok, []} == DbAdapter.all(irrelevant_instant)
    end
  end

  describe "store/1" do
    test "it saves the product into the database" do
      product =
        Entities.Product.new(
          name: "apples",
          price: 145,
          quantity: 1_000,
          time_span:
            Interval.new(
              from: Timex.now(),
              until: [days: 1]
            )
        )

      DbAdapter.store(product)

      saved_product = Repo.one(Storage.Product)
      assert saved_product.name == "apples"
      assert saved_product.price == 145
      assert saved_product.quantity == 1_000
      saved_time_span = Interval.new(from: saved_product.start, until: saved_product.end)
      assert Interval.contains?(saved_time_span, product.time_span)
      assert Interval.contains?(product.time_span, saved_time_span)
    end

    @tag :skip
    test "it returns a product entity"
  end
end
