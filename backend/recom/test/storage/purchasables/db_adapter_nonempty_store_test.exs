defmodule Recom.Storage.DbAdapter_NonEmptyStoreTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Storage
  alias Recom.Entities.Product
  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Usecases.Shopkeeper.CreateProduct.DuplicateProductError

  @a_valid_product Product.new(
                     name: "Apricots x6",
                     price: 599,
                     quantity: 1_000,
                     time_span:
                       Interval.new(from: ~U[2010-07-14 08:00:00.000000Z], until: [days: 7])
                   )

  @another_valid_product Product.new(
                           name: "Oranges 2kg",
                           price: 399,
                           quantity: 4_000,
                           time_span:
                             Interval.new(from: ~U[2010-12-14 08:00:00.000000Z], until: [days: 7])
                         )

  describe "save_product/1" do
    setup do
      DbAdapter.save_product(@another_valid_product)
      :ok
    end

    test "when the product is original, it saves the product" do
      DbAdapter.save_product(@a_valid_product)

      saved_product = Repo.one!(from(p in Storage.Product, where: p.name == "Apricots x6"))

      assert saved_product.name == "Apricots x6"
      assert saved_product.price == 599
      assert saved_product.quantity == 1_000

      assert DateTime.compare(
               saved_product.start,
               Timex.to_datetime(@a_valid_product.time_span.from, "Etc/UTC")
             ) == :eq

      assert DateTime.compare(
               saved_product.end,
               Timex.to_datetime(@a_valid_product.time_span.until, "Etc/UTC")
             ) == :eq
    end

    test "when the product is a duplicate, it returns an error" do
      assert %DuplicateProductError{message: "This product already exists."} ==
               DbAdapter.save_product(@another_valid_product)
    end
  end
end
