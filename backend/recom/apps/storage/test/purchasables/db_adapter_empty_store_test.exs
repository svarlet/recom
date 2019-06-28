defmodule Storage.PurchasablesGateway.DbAdapter_EmptyStoreTest do
  use Storage.DataCase
  use Timex

  alias Storage.PurchasablesGateway.DbAdapter

  test "given no products, when requesting all purchasables, it returns {:ok, []}" do
    irrelevant_instant = Timex.now()
    assert {:ok, []} == DbAdapter.all(irrelevant_instant)
  end
end
