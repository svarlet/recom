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
end
