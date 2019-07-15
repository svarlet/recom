defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true

  import Plug.Test, only: [conn: 3]

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner

  describe "given a request, when params don't represent a product" do
    setup do
      [
        response:
          conn(:post, "/create_product", %{"wrong" => "field"})
          |> ProductScanner.call(nil)
      ]
    end

    test "it sends a response", context do
      assert context.response.state == :sent
    end

    test "it sets the status of the reponse to 422", context do
      assert context.response.state == :sent
    end
  end
end
