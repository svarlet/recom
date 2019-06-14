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

  describe "new/1" do
    test "given a keyword list with a start key then a product with the associated start value is returned" do
      instant = ~N[2017-09-14 13:00:02]
      assert %Product{start: ^instant} = Product.new(start: instant)
    end

    test "given a keyword list with an end key then a product with the associated end value is returned" do
      instant = ~N[2019-01-23 23:00:12]
      assert %Product{end: ^instant} = Product.new(end: instant)
    end

    test "given a keyword list with a name key then a product with the associated name value is returned" do
      name = "irrelevant name"
      assert %Product{name: ^name} = Product.new(name: name)
    end
  end

end
