defmodule Storage.PurchasablesGatewayTest do
  use ExUnit.Case, async: true

  alias Storage.PurchasablesGateway

  test "given no products, when requesting all purchasables, it returns {:ok, []}" do
    irrelevant_instant = Timex.now()
    assert {:ok, []} == PurchasablesGateway.Adapters.DbGateway.all(irrelevant_instant)
  end
end
