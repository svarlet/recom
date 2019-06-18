defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Usecases.Shopper.ListProducts

  setup :verify_on_exit!

  alias Usecases.Shopper.PurchasablesGateway
  alias Entities.Product

  Mox.defmock PurchasablesGateway.Mock, for: PurchasablesGateway

  test "it fetches purchasables via the provided gateway with the supplied instant" do
    instant = Timex.now()
    irrelevant_found_purchasables = []
    Mox.expect(PurchasablesGateway.Mock, :all, fn ^instant -> {:ok, irrelevant_found_purchasables} end)
    list_products(PurchasablesGateway.Mock, instant)
  end

  test "on success, returns the found purchasables" do
    instant = Timex.now()
    found_purchasables = [
      Product.new(
        name: "irrelevant name 1",
        time_span: Interval.new(from: Timex.shift(instant, days: 2), until: [days: 3])),
      Product.new(
        name: "irrelevant name 2",
      time_span: Interval.new(from: Timex.shift(instant, months: 1), until: [months: 1, days: 2]))
    ]
    Mox.stub(PurchasablesGateway.Mock, :all, fn _instant -> {:ok, found_purchasables} end)
    assert {:ok, found_purchasables} == list_products(PurchasablesGateway.Mock, instant)
  end

  test "on failure, relays the error" do
    irrelevant_instant = Timex.now()
    Mox.stub(PurchasablesGateway.Mock, :all, fn _instant -> {:error, :something_failed} end)
    assert {:error, :something_failed} == list_products(PurchasablesGateway.Mock, irrelevant_instant)
  end
end
