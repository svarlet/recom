defmodule Recom.Entities.ProductTest do
  use ExUnit.Case, async: true

  alias Recom.Entities.Product

  describe "new/0" do
    test "returns a product with an empty show code" do
      assert %Product{code: ""} = Product.new()
    end
  end
end
