defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  use Timex
  use Exceptional

  alias Recom.Entities.Product

  defmodule ScanningError do
    defexception ~w{message reason}a
  end

  def scan(payload) do
    payload
    |> check_payload_type()
    ~> check_name()
    ~> check_price()
    ~> check_quantity()
    ~> check_from()
    ~> check_end()
    ~> check_order_of_dates()
    ~> to_product()
  end

  defp check_payload_type(payload) do
    if is_map(payload) do
      payload
    else
      %ScanningError{message: "Cannot scan this payload."}
    end
  end

  defp check_name(payload) do
    check(payload, "name", &is_binary/1, "Invalid type, expected a string.")
  end

  defp check_price(payload) do
    check(payload, "price", &is_integer/1, "Invalid type, expected an integer.")
  end

  defp check_quantity(payload) do
    check(payload, "quantity", &is_integer/1, "Invalid type, expected an integer.")
  end

  defp check(payload, field, checker, message) do
    if Map.has_key?(payload, field) do
      if checker.(payload[field]) do
        payload
      else
        %ScanningError{message: "Invalid payload.", reason: %{String.to_atom(field) => message}}
      end
    else
      %ScanningError{message: "Invalid payload.", reason: %{String.to_atom(field) => "Missing."}}
    end
  end

  defp check_from(payload) do
    check(payload, "from", &is_datetime?/1, "Invalid type, expected a datetime.")
  end

  defp is_datetime?(value) do
    case Timex.parse(value, "{ISO:Extended:Z}") do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp check_end(payload) do
    check(payload, "end", &is_datetime?/1, "Invalid type, expected a datetime.")
  end

  defp check_order_of_dates(payload) do
    from = parse_date(payload["from"])
    the_end = parse_date(payload["end"])

    if Timex.before?(from, the_end) do
      payload
    else
      %ScanningError{
        message: "Invalid payload.",
        reason: %{end: "The end value should not precede the from value."}
      }
    end
  end

  defp parse_date(date) do
    Timex.parse!(date, "{ISO:Extended:Z}")
  end

  defp to_product(payload) do
    %Product{
      name: payload["name"],
      price: payload["price"],
      quantity: payload["quantity"],
      time_span:
        Interval.new(
          from: Timex.parse!(payload["from"], "{ISO:Extended:Z}"),
          # TODO Fix this, it shouldn't always be 8
          until: Timex.parse!(payload["end"], "{ISO:Extended:Z}")
        )
    }
  end
end
