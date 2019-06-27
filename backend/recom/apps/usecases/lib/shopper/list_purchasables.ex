defmodule Usecases.Shopper do
  defmodule PurchasablesGateway do
    alias Entities.Product

    @callback all(instant :: DateTime.t) :: {:ok, list(Product.t)} | {:error, term}
  end

  defmodule ListPurchasables do
    def list_purchasables(instant, purchasables_gateway) do
      case purchasables_gateway.all(instant) do
        {:ok, purchasables} ->
          purchasables_sorted_by_start_date =
            purchasables
            |> Enum.sort_by(fn p -> p.time_span.from end, &Timex.before?/2)
          {:ok, purchasables_sorted_by_start_date}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
