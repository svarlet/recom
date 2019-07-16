defmodule Recom.Api.Shopkeeper.ProductPayloadScannerTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Api.Shopkeeper.ProductPayloadScanner

  @valid_payload %{
    "name" => "Orange juice 2L",
    "price" => 100,
    "quantity" => 1_000,
    "from" => "2010-10-10T14:15:00.000000Z",
    "end" => "2020-10-18T13:12:09.000000Z"
  }

  setup context do
    result =
      context
      |> Map.get(:overrides, [])
      |> Enum.reduce(@valid_payload, fn
        {:delete, field}, payload -> Map.delete(payload, field)
        {:blank, field}, payload -> Map.put(payload, field, "     \r   \n \t  ")
        {:not_a_number, field}, payload -> Map.put(payload, field, :not_a_number)
        {:negate, field}, payload -> Map.put(payload, field, -1)
        {:bad_date_format, field}, payload -> Map.put(payload, field, "1999-32-44 26:64:78.0j")
        {:swap_dates, _}, payload -> swap(payload, "from", "end")
        {:zero, field}, payload -> Map.put(payload, field, 0)
        _not_an_override_spec, _payload -> raise "unknown override instruction"
      end)
      |> ProductPayloadScanner.scan()

    [result: result]
  end

  defp swap(map, field1, field2) do
    ex_field1 = Map.fetch!(map, field1)
    ex_field2 = Map.fetch!(map, field2)

    map
    |> Map.put(field1, ex_field2)
    |> Map.put(field2, ex_field1)
  end

  defp assert_scanning_error(result) do
    assert {:error, "This payload does not represent a valid product."} == result
  end

  # INVALID CASES
  @tag overrides: [delete: "name"]
  test "name is missing", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [blank: "name"]
  test "name is blank", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [delete: "price"]
  test "price is missing", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [not_a_number: "price"]
  test "price is not a number", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [negate: "price"]
  test "price is negative", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [delete: "quantity"]
  test "quantity is missing", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [not_a_number: "quantity"]
  test "quantity is not a number", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [negate: "quantity"]
  test "quantity is negative", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [delete: "from"]
  test "from is missing", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [bad_date_format: "from"]
  test "from is not a date with time, microseconds precision and timezone", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [delete: "end"]
  test "end is missing", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [bad_date_format: "end"]
  test "end is not a date with time, microseconds precision and timezone", context do
    assert_scanning_error(context.result)
  end

  @tag overrides: [swap_dates: nil]
  test "from does not precede end", context do
    assert_scanning_error(context.result)
  end

  # VALID CASES
  @tag overrides: [zero: "price"]
  test "price is zero", context do
    assert {:ok, _} = context.result
  end

  @tag overrides: [zero: "quantity"]
  test "quantity is zero", context do
    assert {:ok, _} = context.result
  end

  test "A valid payload is scanned into a Product entity", context do
    assert {:ok, product} = context.result

    assert Product.equals?(product, %Product{
             name: "Orange juice 2L",
             price: 100,
             quantity: 1_000,
             time_span:
               Interval.new(
                 from: ~U[2010-10-10 14:15:00.000000Z],
                 until: ~U[2020-10-18 13:12:09.000000Z]
               )
           })
  end
end
