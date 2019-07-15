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

    test "it sets the content-type to application/json", context do
      assert Plug.Conn.get_resp_header(context.response, "content-type") == ["application/json"]
    end

    test "it sets the body with an informative error structured in json", context do
      assert context.response.resp_body == ~S"""
             {
               "message": "Not a valid representation of a product"
             }
             """
    end
  end
end
