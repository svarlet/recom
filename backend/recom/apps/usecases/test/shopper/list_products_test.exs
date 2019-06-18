defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Usecases.Shopper.ListProducts

  setup :verify_on_exit!

  alias Usecases.Shopper.PurchasablesGateway

  Mox.defmock PurchasablesGateway.Mock, for: PurchasablesGateway

  test "it fetches purchasables via the provided gateway" do
    instant = Timex.now()
    irrelevant_found_purchasables = []
    Mox.expect(PurchasablesGateway.Mock, :all, fn ^instant -> {:ok, irrelevant_found_purchasables} end)
    list_products(PurchasablesGateway.Mock, instant)
  end

  test "on success, returns the found purchasables" do
    instant = Timex.now()
    Mox.expect(PurchasablesGateway.Mock, :all, fn ^instant -> {:ok, []} end)
    assert {:ok, []} == list_products(PurchasablesGateway.Mock, instant)
  end

  test "on failure, relays the error" do
    instant = Timex.now()
    Mox.expect(PurchasablesGateway.Mock, :all, fn ^instant -> {:error, :something_failed} end)
    assert {:error, :something_failed} == list_products(PurchasablesGateway.Mock, instant)
  end
end
