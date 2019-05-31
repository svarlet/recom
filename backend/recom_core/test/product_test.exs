defmodule Recom.ProductTest do
  use ExUnit.Case, async: true

  import Recom.Product

  describe "filter_available_products/1" do
    test "in absence of any product, it returns []" do
      assert [] == filter_available_products([])
    end
  end
end
