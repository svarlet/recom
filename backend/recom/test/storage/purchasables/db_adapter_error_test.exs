defmodule Recom.Storage.PurchasablesGateway.DbAdapter_ErrorTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Entities.Product
  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Usecases.Shopkeeper.CreateProduct.GatewayError

  describe "all/1" do
    test "when Ecto raises an error then it returns :error" do
      assert :error ==
               DbAdapter.all("NOT A DATETIME, THAT WILL RAISE")
    end

    test "close tx" do
      # Checkin the transation. That raises a DBConnection.OwnershipError.
      Ecto.Adapters.SQL.Sandbox.checkin(Recom.Repo)
      assert :error == DbAdapter.all(DateTime.utc_now())
    end
  end

  describe "save_product/1" do
    test "unexpected gateway error" do
      # Early checkin will cause an exception to be raised when inserting the record
      # Exact error will be a DBConnection.OwnershipError
      Ecto.Adapters.SQL.Sandbox.checkin(Recom.Repo)

      irrelevant_but_valid_product =
        Product.new(
          name: "irrelevant",
          price: 1,
          quantity: 1,
          time_span: Interval.new(from: Timex.now(), until: [days: 1])
        )

      assert %GatewayError{message: "An unexpected error happened while saving the product."} ==
               DbAdapter.save_product(irrelevant_but_valid_product)
    end
  end
end
