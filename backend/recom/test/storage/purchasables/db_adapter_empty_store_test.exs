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
    setup do
      %{
        product:
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
      }
    end

    test "it saves the product into the database", context do
      DbAdapter.store(context.product)

      saved_product = Repo.one(Storage.Product)
      assert saved_product.name == "apples"
      assert saved_product.price == 145
      assert saved_product.quantity == 1_000
      saved_time_span = Interval.new(from: saved_product.start, until: saved_product.end)
      assert_equal_interval(saved_time_span, context.product.time_span)
    end

    defp assert_equal_interval(interval1, interval2) do
      assert Interval.contains?(interval1, interval2)
      assert Interval.contains?(interval2, interval1)
    end

    test "it returns a product entity", context do
      assert {:ok, %Entities.Product{} = product} = DbAdapter.store(context.product)
      assert Entities.Product.equals?(product, context.product)
    end
  end
end
