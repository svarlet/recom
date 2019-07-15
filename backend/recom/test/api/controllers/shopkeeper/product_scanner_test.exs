defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true

  import Plug.Test, only: [conn: 3]

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner

  describe "given a request, when params don't represent a product" do
    test "it sends a response" do
      response =
        conn(:post, "/create_product", %{"wrong" => "field"})
        |> ProductScanner.call(nil)

      assert response.state == :sent
    end
  end
end
