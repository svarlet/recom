defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  use Timex

  alias Recom.Entities.Product

  defmodule ScanningError do
    defexception message: nil, reason: %{name: "Invalid type, expected a string."}
  end

  def scan(payload) do
    case payload do
      nil ->
        %ScanningError{message: "Nil payload."}

      %{"name" => name} when not is_binary(name) ->
        %ScanningError{
          message: "Invalid payload.",
          reason: %{name: "Invalid type, expected a string."}
        }

      payload ->
        %Product{
          name: payload["name"],
          price: payload["price"],
          quantity: payload["quantity"],
          time_span:
            Interval.new(
              from: Timex.parse!(payload["from"], "{ISO:Extended:Z}"),
              until: [days: 8]
            )
        }
    end
  end
end

defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner
  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError

  test "payload is nil" do
    assert %ScanningError{message: "Nil payload."} == ProductScanner.scan(nil)
  end

  test "payload with all fields of valid type" do
    payload = %{
      "name" => "Orange Juice 2L",
      "price" => 589,
      "quantity" => 1_000,
      "from" => "2019-01-01T14:00:00.000000Z",
      "end" => "2019-01-09T14:00:00.000000Z"
    }

    product = %Product{
      name: "Orange Juice 2L",
      price: 589,
      quantity: 1_000,
      time_span:
        Interval.new(
          from: ~U[2019-01-01 14:00:00.000000Z],
          until: [days: 8]
        )
    }

    assert Product.equals?(product, ProductScanner.scan(payload))
  end

  test "name with an invalid type" do
    payload = %{
      "name" => 0,
      "price" => 589,
      "quantity" => 1_000,
      "from" => "2019-01-01T14:00:00.000000Z",
      "end" => "2019-01-09T14:00:00.000000Z"
    }

    assert %ScanningError{
             message: "Invalid payload.",
             reason: %{name: "Invalid type, expected a string."}
           } = ProductScanner.scan(payload)
  end
end
