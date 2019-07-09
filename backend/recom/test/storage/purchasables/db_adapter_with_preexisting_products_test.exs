defmodule Recom.Storage.PurchasablesGateway_WithPreexistingProductsTest do
  use Recom.Storage.DataCase
  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.{DataMapper, DbAdapter}
  alias Recom.Entities

  describe "store/1" do
    setup do
      start = Timex.now()
      the_end = Timex.shift(start, days: 2)

      product = %Storage.Product{
        name: "preexisting product",
        price: 123,
        quantity: 232,
        start: start,
        end: the_end
      }

      Repo.insert(product)

      %{preexisting_product_record: product, start: start, end: the_end}
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

      assert {:ok, product} = DbAdapter.store(product_to_save)
      assert Entities.Product.equals?(product, product_to_save)
    end

    test "given a duplicate, it returns an error", context do
      assert {:error, :duplicate_product} ==
               context.preexisting_product_record
               |> DataMapper.convert()
               |> DbAdapter.store()
    end
  end
end
