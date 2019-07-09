defmodule Recom.Storage.PurchasablesGateway.DbAdapter_ErrorTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Storage.PurchasablesGateway.DbAdapter
  alias Recom.Entities

  describe "all/2" do
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

  describe "store/1" do
    test "when Repo raises an error, it returns :error" do
      # By checking in the transaction, an error will be raised when using Repo
      Ecto.Adapters.SQL.Sandbox.checkin(Recom.Repo)

      product =
        Entities.Product.new(
          name: "irrelevant",
          price: 123,
          quantity: 234,
          time_span: Interval.new(from: Timex.now(), until: [days: 1])
        )

      assert :error == DbAdapter.store(product)
    end
  end
end
