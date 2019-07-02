defmodule Recom.Storage.PurchasablesGateway.DbAdapter_EmptyStoreTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Storage.PurchasablesGateway.DbAdapter

  test "given no products, when requesting all purchasables, it returns {:ok, []}" do
    irrelevant_instant = Timex.now()
    assert {:ok, []} == DbAdapter.all(irrelevant_instant)
  end
end