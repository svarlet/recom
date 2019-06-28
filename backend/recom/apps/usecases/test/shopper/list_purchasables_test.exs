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

  describe "given a single purchasable is available, when retrieved successfully" do
    test "it returns the purchasable as {:ok, [purchasable]}" do
      instant = Timex.now()

      purchasable = Product.new(
        name: "irrelevant name 1",
        time_span: Interval.new(from: Timex.shift(instant, days: 2), until: [days: 3]))

      Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> {:ok, [purchasable]} end)

      assert {:ok, [purchasable]} == list_purchasables(instant, PurchasablesGateway.MockAdapter)
    end
  end

  describe "given multiple purchasables are available, when retrieved successfully" do
    setup do
      instant = Timex.now()

      later_purchasable = Product.new(
        name: "irrelevant name 2",
        time_span: Interval.new(from: Timex.shift(instant, months: 1), until: [months: 1, days: 2]))

      soon_purchasable = Product.new(
        name: "irrelevant name 1",
        time_span: Interval.new(from: Timex.shift(instant, days: 2), until: [days: 3]))

      %{instant: instant, soon_purchasable: soon_purchasable, later_purchasable: later_purchasable}
    end

    test "it sorts them by start date and returns them as {:ok, purchasables]}", context do
      # purposedly sorted by their start date in descending order!
      found_purchasables = [context.later_purchasable, context.soon_purchasable]
      Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> {:ok, found_purchasables} end)
      assert {:ok, [context.soon_purchasable, context.later_purchasable]} == list_purchasables(context.instant, PurchasablesGateway.MockAdapter)
    end
  end

  test "on failure, relays the error" do
    irrelevant_instant = Timex.now()
    Mox.stub(PurchasablesGateway.MockAdapter, :all, fn _instant -> :error end)
    assert :error == list_purchasables(irrelevant_instant, PurchasablesGateway.MockAdapter)
  end
end
