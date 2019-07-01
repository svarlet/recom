defmodule Recom.Storage.PurchasablesGateway.DbAdapter_ErrorTest do
  use Recom.Storage.DataCase

  alias Recom.Storage

  describe "all/2" do
    test "when Ecto raises an error then it returns :error" do
      assert :error == Storage.PurchasablesGateway.DbAdapter.all("NOT A DATETIME, THAT WILL RAISE")
    end

    test "close tx" do
      # Checkin the transation. That raises a DBConnection.OwnershipError.
      Ecto.Adapters.SQL.Sandbox.checkin(Recom.Repo)
      assert :error == Storage.PurchasablesGateway.DbAdapter.all(DateTime.utc_now())
    end
  end
end
