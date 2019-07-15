defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true

  import Plug.Test, only: [conn: 3]

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner

  defmodule AlwaysInvalidProductScanner do
    def scan(_payload), do: :error
  end

  describe "given a request, when params don't represent a product" do
    setup do
      [
        response:
          conn(:post, "/create_product", %{"wrong" => "field"})
          |> ProductScanner.call(scanner: AlwaysInvalidProductScanner)
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

  defmodule AlwaysSuccessfulProductScanner do
    use Timex

    alias Recom.Entities.Product

    def scan(_payload) do
      %Product{
        name: "Orange Juice 2L",
        price: 1200,
        quantity: 100_000,
        time_span:
          Interval.new(
            from: ~U[2019-12-12 14:00:00.000000Z],
            until: ~U[2019-12-14 14:00:00.000000Z]
          )
      }
    end
  end

  describe "given a request, when params represent a product" do
    setup do
      payload = %{
        "name" => "Orange Juice 2L",
        "price" => 1200,
        "quantity" => 100_000,
        "from" => ~U[2019-12-12 14:00:00.000000Z],
        "end" => ~U[2019-12-14 14:00:00.000000Z]
      }

      [
        response:
          conn(:post, "/create_product", payload)
          |> ProductScanner.call(scanner: AlwaysSuccessfulProductScanner)
      ]
    end

    test "it doesn't send the response", context do
      assert context.response.state != :sent
    end
  end
end
