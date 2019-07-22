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
    case payload do
      %{"name" => name} when is_binary(name) ->
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

  defp check_price(payload) do
    case payload do
      %{"price" => price} when is_integer(price) ->
        payload

      %{"price" => _} ->
        %ScanningError{
          message: "Invalid payload.",
          reason: %{price: "Invalid type, expected an integer."}
        }

      _ ->
        %ScanningError{message: "Invalid payload.", reason: %{price: "Missing."}}
    end
  end

  defp check_quantity(payload) do
    case payload do
      %{"quantity" => quantity} when is_integer(quantity) ->
        payload

      %{"quantity" => _} ->
        %ScanningError{
          message: "Invalid payload.",
          reason: %{quantity: "Invalid type, expected an integer."}
        }

      _ ->
        %ScanningError{message: "Invalid payload.", reason: %{quantity: "Missing."}}
    end
  end

  defp check_from(payload) do
    case payload do
      %{"from" => from} ->
        case Timex.parse(from, "{ISO:Extended:Z}") do
          {:ok, _} ->
            payload

          {:error, _} ->
            %ScanningError{
              message: "Invalid payload.",
              reason: %{from: "Invalid type, expected a datetime."}
            }
        end

      _ ->
        %ScanningError{message: "Invalid payload.", reason: %{from: "Missing."}}
    end
  end

  defp check_end(payload) do
    case payload do
      %{"end" => the_end} ->
        case Timex.parse(the_end, "{ISO:Extended:Z}") do
          {:ok, _} ->
            payload

          {:error, _} ->
            %ScanningError{
              message: "Invalid payload.",
              reason: %{end: "Invalid type, expected a datetime."}
            }
        end

      _ ->
        %ScanningError{message: "Invalid payload.", reason: %{end: "Missing."}}
    end
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
