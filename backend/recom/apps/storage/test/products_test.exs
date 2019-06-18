defmodule Storage.PurchasablesGateway_NoProductsTest do
  use Storage.DataCase
  use Timex

  alias Storage.PurchasablesGateway.Adapters.DbGateway, as: PurchasablesGateway

  test "given no products, when requesting all purchasables, it returns {:ok, []}" do
    irrelevant_instant = Timex.now()
    assert {:ok, []} == PurchasablesGateway.all(irrelevant_instant)
  end
end

defmodule Storage.PurchasablesGatewayTest do
  use Storage.DataCase
  use Timex

  alias Storage.Product
  alias Storage.PurchasablesGateway

  test "given some products, when some expire after the instant, it returns those" do
    instant = Timex.now()

    [%Product{
        name: "Pass for a product which expired 2 days ago",
        start: Timex.shift(instant, days: -5),
        end: Timex.shift(instant, days: -2)},
     %Product{
       name: "Future Pass starting in 3 years from now and lasting 2 days",
       start: Timex.shift(instant, years: 3),
       end: Timex.shift(instant, years: 3, days: 2)}]
    |> Enum.each(&Storage.Repo.insert/1)

    future_product_as_entity = Entities.Product.new(
      name: "Future Pass starting in 3 years from now and lasting 2 days",
      time_span: Interval.new(
        from: Timex.shift(instant, years: 3),
        until: [days: 2]
      ))

    assert {:ok, [^future_product_as_entity]} = PurchasablesGateway.Adapters.DbGateway.all(instant)
  end

  test "given some products, when some start exactly at the instant, it returns those" do
    instant = Timex.now()

    %Product{
      name: "Product starting exactly at the instant",
      start: instant,
      end: Timex.shift(instant, days: 2)}
    |> Storage.Repo.insert()

    product_as_entity = Entities.Product.new(
      name: "Product starting exactly at the instant",
      time_span: Interval.new(
        from: instant,
        until: [days: 2]
      ))

    assert {:ok, [^product_as_entity]} = PurchasablesGateway.Adapters.DbGateway.all(instant)
  end
end