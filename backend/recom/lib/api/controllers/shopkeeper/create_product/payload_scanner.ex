defmodule Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.Behaviour do
  @callback scan(map()) :: ScanningError.t() | Product.t()
end

defmodule Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.ScanningError do
  defstruct [:message, :errors]
end

defmodule Recom.Api.Shopkeeper.CreateProduct.PayloadScanner do
  use Timex

  import Ecto.Changeset

  alias Recom.Api.Shopkeeper.CreateProduct.Payload
  alias Recom.Entities.Product

  @behaviour Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.Behaviour

  def scan(payload) do
    changeset = Payload.changeset(%Payload{}, payload)

    if changeset.valid? do
      {:ok, changeset |> apply_changes() |> to_product()}
    else
      {:error, "This payload does not represent a valid product."}
    end
  end

  defp to_product(payload) do
    %Product{
      name: payload.name,
      price: payload.price,
      quantity: payload.quantity,
      time_span: Interval.new(from: payload.from, until: payload.end)
    }
  end
end
