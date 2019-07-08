defmodule Recom.Storage.PurchasablesGateway_PreexistingProductsTest do
  use Recom.Storage.DataCase
  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Entities

  describe "store/1" do
    setup do
      start = Timex.now()
      the_end = Timex.shift(start, days: 2)

      Repo.insert(%Storage.Product{
        name: "preexisting product",
        price: 123,
        quantity: 232,
        start: start,
        end: the_end
      })

      %{start: start, end: the_end}
    end

    test "it saves the product", context do
      product_to_save = %Entities.Product{
        name: "Orange Juice",
        quantity: 232,
        price: 123,
        time_span: Interval.new(from: context.start, until: context.end)
      }

      DbAdapter.store(product_to_save)

      [orange_juice] =
        from(p in Storage.Product, where: p.name == "Orange Juice")
        |> Repo.all()

      assert orange_juice.name == "Orange Juice"
      assert orange_juice.price == 123
      assert orange_juice.quantity == 232
      assert orange_juice.start == context.start
      assert orange_juice.end == context.end
    end

    test "it returns a product entity", context do
      product_to_save = %Entities.Product{
        name: "Pineapple Juice",
        quantity: 232,
        price: 123,
        time_span: Interval.new(from: context.start, until: context.end)
      }

      assert {:ok, %Entities.Product{} = product} = DbAdapter.store(product_to_save)
      assert product.name == product_to_save.name
      assert product.quantity == product_to_save.quantity
      assert product.price == product_to_save.price
      assert_equal_interval(product.time_span, product_to_save.time_span)
    end

    defp assert_equal_interval(interval1, interval2) do
      assert Interval.contains?(interval1, interval2)
      assert Interval.contains?(interval2, interval1)
    end

    @tag :skip
    test "given a duplicate, it returns an error"
  end
end
