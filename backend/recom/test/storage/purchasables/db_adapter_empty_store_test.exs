defmodule Recom.Storage.PurchasablesGateway.DbAdapter_EmptyStoreTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Entities
  alias Recom.Storage.PurchasablesGateway.DbAdapter

  describe "all/1" do
    test "given no products, when requesting all purchasables, it returns {:ok, []}" do
      irrelevant_instant = Timex.now()
      assert {:ok, []} == DbAdapter.all(irrelevant_instant)
    end
  end

  describe "store/1" do
    test "it saves apples into the database" do
      from = Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")

      product =
        Entities.Product.new(
          name: "apples",
          price: 145,
          quantity: 1_000,
          time_span: Interval.new(from: from, until: [days: 1])
        )

      assert {:ok, product} == DbAdapter.store(product)
    end
  end
end
