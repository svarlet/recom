defmodule Storage.PurchasablesGatewayTest do
  use ExUnit.Case, async: true
  use Timex

  alias Storage.Product
  alias Storage.PurchasablesGateway

  test "given no products, when requesting all purchasables, it returns {:ok, []}" do
    irrelevant_instant = Timex.now()
    assert {:ok, []} == PurchasablesGateway.Adapters.DbGateway.all(irrelevant_instant)
  end

  test "given some products, when some expire after the instant, it returns those" do
    instant = Timex.now()

    past_product = %Product{
      name: "Pass 2015",
      start: Timex.shift(instant, days: -5),
      end: Timex.shift(instant, days: -2)}

    {:ok, _product} = Storage.Repo.insert(past_product)

    future_product = %Product{
      name: "Future Pass starting in 3 years from now and lasting 2 days",
      start: Timex.shift(instant, years: 3),
      end: Timex.shift(instant, years: 3, days: 2)
    }

    {:ok, _product} = Storage.Repo.insert(future_product)

    future_product_as_entity = Entities.Product.new(
      name: "Future Pass starting in 3 years from now and lasting 2 days",
      time_span: Interval.new(
        from: Timex.shift(instant, years: 3),
        until: [days: 2]
      ))

    assert {:ok, [^future_product_as_entity]} = PurchasablesGateway.Adapters.DbGateway.all(instant)
  end
end
