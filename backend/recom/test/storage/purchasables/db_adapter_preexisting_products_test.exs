defmodule Recom.Storage.PurchasablesGateway_PreexistingProductsTest do
  use Recom.Storage.DataCase
  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Entities

  describe "store/1" do
    test "it saves the product" do
      start = Timex.now()
      the_end = Timex.shift(start, days: 2)

      Repo.insert(%Storage.Product{
        name: "preexisting product",
        price: 123,
        quantity: 232,
        start: start,
        end: the_end
      })

      product_to_save = %Entities.Product{
        name: "Orange Juice",
        quantity: 232,
        price: 123,
        time_span: Interval.new(from: start, until: the_end)
      }

      DbAdapter.store(product_to_save)

      [orange_juice] =
        from(p in Storage.Product, where: p.name == "Orange Juice")
        |> Repo.all()

      assert orange_juice.name == "Orange Juice"
      assert orange_juice.price == 123
      assert orange_juice.quantity == 232
      assert orange_juice.start == start
      assert orange_juice.end == the_end
    end

    @tag :skip
    test "given a duplicate, it returns an error"
  end
end
