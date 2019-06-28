defmodule Storage.PurchasablesGateway.DbAdapter_ErrorTest do
  use Storage.DataCase

  describe "all/2" do
    test "when Ecto raises an error then it returns :error" do
      assert :error == Storage.PurchasablesGateway.DbAdapter.all("NOT A DATETIME, THAT WILL RAISE")
    end
  end
end
