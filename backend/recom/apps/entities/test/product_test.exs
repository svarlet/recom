defmodule Recom.Entities.ProductTest do
  use ExUnit.Case, async: true

  alias Recom.Entities.Product

  describe "new/0" do
    test "returns a product with a nil start" do
      assert %Product{start: nil} = Product.new()
    end

    test "returns a product with a nil end" do
      assert %Product{end: nil} = Product.new()
    end

    test "returns a product with an empty name" do
      assert %Product{name: ""} = Product.new()
    end
  end

end
