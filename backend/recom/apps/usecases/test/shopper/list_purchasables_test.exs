defmodule Usecases.Shopper.ListPurchasablesTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Usecases.Shopper.ListPurchasables

  alias Usecases.Shopper.PurchasablesGateway
  alias Entities.Product

  Mox.defmock PurchasablesGateway.MockAdapter, for: PurchasablesGateway

  setup :verify_on_exit!

  #
  # Collaboration tests
  #

  test "it fetches purchasables via the provided gateway with the supplied instant" do
    instant = Timex.now()
    irrelevant_found_purchasables = []
    Mox.expect(PurchasablesGateway.MockAdapter, :all, fn ^instant -> {:ok, irrelevant_found_purchasables} end)
    list_purchasables(instant, PurchasablesGateway.MockAdapter)
  end

  #
  # Contract tests
  #

  describe "given multiple purchasables are available, when retrieved successfully" do
    setup do
      %{instant: Timex.now()}
    end

    test "on success, returns the found purchasables", context do
      found_purchasables = [
        Product.new(
          name: "irrelevant name 1",
          time_span: Interval.new(from: Timex.shift(context.instant, days: 2), until: [days: 3])),
        Product.new(
          name: "irrelevant name 2",
        time_span: Interval.new(from: Timex.shift(context.instant, months: 1), until: [months: 1, days: 2]))
      ]
      Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> {:ok, found_purchasables} end)
      assert {:ok, found_purchasables} == list_purchasables(context.instant, PurchasablesGateway.MockAdapter)
    end

    test "given multiple purchasables are availalbe when retrieved then they are sorted by start date and returned", context do
      later_purchasable = Product.new(
        name: "irrelevant name 2",
        time_span: Interval.new(from: Timex.shift(context.instant, months: 1), until: [months: 1, days: 2]))

      soon_purchasable = Product.new(
        name: "irrelevant name 1",
        time_span: Interval.new(from: Timex.shift(context.instant, days: 2), until: [days: 3]))

      # purposedly sorted by their start date in descending order!
      found_purchasables = [later_purchasable, soon_purchasable]
      Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> {:ok, found_purchasables} end)
      assert {:ok, [soon_purchasable, later_purchasable]} == list_purchasables(context.instant, PurchasablesGateway.MockAdapter)
    end
  end

  test "on failure, relays the error" do
    irrelevant_instant = Timex.now()
    Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> {:error, :something_failed} end)
    assert {:error, :something_failed} == list_purchasables(irrelevant_instant, PurchasablesGateway.MockAdapter)
  end
end
