defmodule Recom.Storage.PurchasablesGateway.DbAdapter_ErrorTest do
  use Recom.Storage.DataCase
  use Timex

  alias Recom.Storage.PurchasablesGateway.DbAdapter

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
end
