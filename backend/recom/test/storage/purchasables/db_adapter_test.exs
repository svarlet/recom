defmodule Recom.Storage.PurchasablesGatewayTest_ProductsAtVariousTimes do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Repo
  alias Recom.Entities
  alias Recom.Storage.Product
  alias Recom.Storage.PurchasablesGateway.DbAdapter

  describe "all/1" do
    test "given some products, when some expire after the instant, it returns them in an ok tuple" do
      instant = Timex.now()

      [%Product{
          name: "Pass for a product which expired 2 days ago",
          start: Timex.shift(instant, days: -5),
          end: Timex.shift(instant, days: -2)},
       %Product{
         name: "Future Pass starting in 3 years from now and lasting 2 days",
         start: Timex.shift(instant, years: 3),
         end: Timex.shift(instant, years: 3, days: 2)}]
         |> Enum.each(&Repo.insert!/1)

      future_product_as_entity = Entities.Product.new(
        name: "Future Pass starting in 3 years from now and lasting 2 days",
        time_span: Interval.new(
          from: Timex.shift(instant, years: 3),
          until: [days: 2]
        ))

      assert {:ok, [^future_product_as_entity]} = DbAdapter.all(instant)
    end

    test "given some products, when some start exactly at the instant, it returns them in an ok tuple" do
      instant = Timex.now()

      %Product{
        name: "Product starting exactly at the instant",
        start: instant,
        end: Timex.shift(instant, days: 2)}
        |> Repo.insert()

      product_as_entity = Entities.Product.new(
        name: "Product starting exactly at the instant",
        time_span: Interval.new(
          from: instant,
          until: [days: 2]
        ))

      assert {:ok, [^product_as_entity]} = DbAdapter.all(instant)
    end

    test "given a product which ends exactly at the instant, it returns {:ok, []}" do
      instant = Timex.now()

      %Product{
        name: "Product which ends at the instant",
        start: Timex.shift(instant, hours: -1),
        end: instant
      }
      |> Repo.insert!()

      assert {:ok, []} == DbAdapter.all(instant)
    end

    test "given a product which started before the instant and terminates later, it returns it as an ok tuple" do
      instant = Timex.now()

      %Product{
        name: "Product which started before the instant and finishes after",
        start: Timex.shift(instant, hours: -1),
        end: Timex.shift(instant, hours: 1)
      }
      |> Repo.insert!()

      expected_product = Entities.Product.new(
        name: "Product which started before the instant and finishes after",
        time_span: Interval.new(
          from: Timex.shift(instant, hours: -1),
          until: Timex.shift(instant, hours: 1)
        )
      )

      assert {:ok, [^expected_product]} = DbAdapter.all(instant)
    end
  end
end
