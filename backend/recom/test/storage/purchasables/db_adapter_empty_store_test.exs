defmodule Recom.Storage.PurchasablesGateway.DbAdapter_EmptyStoreTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Storage
  alias Recom.Entities.Product
  alias Recom.Storage.PurchasablesGateway.DbAdapter

  describe "all/1" do
    test "given no products, when requesting all purchasables, it returns {:ok, []}" do
      irrelevant_instant = Timex.now()
      assert {:ok, []} == DbAdapter.all(irrelevant_instant)
    end
  end

  describe "save_product/1" do
    test "saves the product when it's original" do
      product =
        Product.new(
          name: "Apricots x6",
          price: 599,
          quantity: 1_000,
          time_span: Interval.new(from: ~U[2010-07-14 08:00:00.000000Z], until: [days: 7])
        )

      DbAdapter.save_product(product)

      saved_product = Repo.one!(Storage.Product)

      assert saved_product.name == "Apricots x6"
      assert saved_product.price == 599
      assert saved_product.quantity == 1_000

      assert DateTime.compare(
               saved_product.start,
               Timex.to_datetime(product.time_span.from, "Etc/UTC")
             ) == :eq

      assert DateTime.compare(
               saved_product.end,
               Timex.to_datetime(product.time_span.until, "Etc/UTC")
             ) == :eq
    end

    test "returns the saved product as an entity" do
      product =
        Product.new(
          name: "Apricots x6",
          price: 599,
          quantity: 1_000,
          time_span: Interval.new(from: ~U[2010-07-14 08:00:00.000000Z], until: [days: 7])
        )

      assert product == DbAdapter.save_product(product)
    end
  end
end
