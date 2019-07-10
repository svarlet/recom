defmodule Recom.Storage.ProductTest do
  use Recom.Storage.DataCase

  alias Recom.Storage.Product

  describe "original product" do
    test "an original changeset can be inserted" do
      product = %Product{
        name: "Banana Puree",
        price: 309,
        quantity: 3249,
        start: ~U[2019-08-23 23:14:15.000000Z],
        end: ~U[2019-08-25 23:14:15.000000Z]
      }

      assert {:ok,
              %Product{
                name: "Banana Puree",
                price: 309,
                quantity: 3249,
                start: ~U[2019-08-23 23:14:15.000000Z],
                end: ~U[2019-08-25 23:14:15.000000Z]
              }} = Repo.insert(product)
    end
  end
end
