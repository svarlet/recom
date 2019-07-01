defmodule Recom.Usecases.Shopper do
  defmodule PurchasablesGateway do
    alias Recom.Entities.Product

    @doc ~s"""
    Fetches all products which expire after the provided instant.

    Returns the matching products wrapped in an ok-tuple or :error when
    this operation cannot be performed successfully.

    Errors may happen for a variety of reasons, yet none could be caused
    by the user. For this reason, we push the responsibility to handle
    this error accordingly (such as logging) back to the implementation.
    Returning :error still enables the caller to gracefully report an error
    to the client.
    """
    @callback all(instant :: DateTime.t) :: {:ok, list(Product.t)} | :error
  end

  defmodule ListPurchasables do
    alias Recom.Entities.Product

    defmodule Behaviour do
      @callback list_purchasables(instant :: DateTime.t) :: {:ok, list(Product.t)} | :error
    end

    def list_purchasables(instant, purchasables_gateway) do
      case purchasables_gateway.all(instant) do
        {:ok, purchasables} ->
          {:ok, Enum.sort(purchasables, &Product.before?/2)}

        :error ->
          :error
      end
    end
  end
end
