defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  use Timex
  use Exceptional

  alias Recom.Entities.Product

  defmodule ScanningError do
    defexception ~w{message reason}a
  end

  def scan(nil) do
    %ScanningError{message: "Nil payload."}
  end

  def scan(payload) do
    payload
    |> check_name()
    ~> check_price()
    ~> to_product()
  end

  defp check_name(payload) do
    case payload do
      %{"name" => name} = payload when is_binary(name) ->
        payload

      %{"name" => _} ->
        %ScanningError{
          message: "Invalid payload.",
          reason: %{name: "Invalid type, expected a string."}
        }

      _ ->
        %ScanningError{message: "Invalid payload.", reason: %{name: "Missing."}}
    end
  end

  defp check_price(%{"price" => price} = payload) when is_integer(price) do
    payload
  end

  defp check_price(%{"price" => _}) do
    %ScanningError{
      message: "Invalid payload.",
      reason: %{price: "Invalid type, expected an integer."}
    }
  end

  defp check_price(_) do
    %ScanningError{message: "Invalid payload.", reason: %{price: "Missing."}}
  end

  defp to_product(payload) do
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

defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner
  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError

  @valid_payload %{
    "name" => "Orange Juice 2L",
    "price" => 589,
    "quantity" => 1_000,
    "from" => "2019-01-01T14:00:00.000000Z",
    "end" => "2019-01-09T14:00:00.000000Z"
  }

  @valid_product %Product{
    name: "Orange Juice 2L",
    price: 589,
    quantity: 1_000,
    time_span:
      Interval.new(
        from: ~U[2019-01-01 14:00:00.000000Z],
        until: [days: 8]
      )
  }

  test "payload is nil" do
    assert %ScanningError{message: "Nil payload.", reason: nil} == ProductScanner.scan(nil)
  end

  test "payload with all fields of valid type" do
    assert Product.equals?(@valid_product, ProductScanner.scan(@valid_payload))
  end

  test "name with an invalid type" do
    payload = Map.put(@valid_payload, "name", 0)

    assert %ScanningError{
             message: "Invalid payload.",
             reason: %{name: "Invalid type, expected a string."}
           } = ProductScanner.scan(payload)
  end

  test "name is missing" do
    payload = Map.delete(@valid_payload, "name")

    assert %ScanningError{
             message: "Invalid payload.",
             reason: %{name: "Missing."}
           } = ProductScanner.scan(payload)
  end

  test "price has an invalid type" do
    payload = Map.put(@valid_payload, "price", "not an integer")

    assert %ScanningError{
             message: "Invalid payload.",
             reason: %{price: "Invalid type, expected an integer."}
           } = ProductScanner.scan(payload)
  end

  test "price is missing" do
    payload = Map.delete(@valid_payload, "price")

    assert %ScanningError{
             message: "Invalid payload.",
             reason: %{price: "Missing."}
           } = ProductScanner.scan(payload)
  end
end
