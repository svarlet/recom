defmodule Recom.Usecases.Shopkeeper do
  alias Recom.Entities.Product

  defmodule ProductsGateway do
    @callback store(Entities.Product.t()) ::
                {:ok, Entities.Product.t()} | {:error, :duplicate_product} | :error
  end

  defmodule Notifier do
    @callback notify_of_product_creation(Product.t()) :: :ok
  end

  defmodule CreateProduct do
    defmodule Behaviour do
      @type result :: {:ok, Product.t()} | :duplicate_product | :error
      @callback create(Product.t()) :: result
    end

    def create(product, with_gateway: gateway, with_notifier: notifier) do
      with {:ok, product} <- gateway.store(product),
           :ok <- notifier.notify_of_product_creation(product) do
        {:ok, product}
      else
        {:error, :duplicate_product} -> :duplicate_product
        :error -> :error
      end
    end
  end
end
