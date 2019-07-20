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
      @type result :: :ok | :duplicate_product | :error
      @callback create(Product.t()) :: result
    end

    defmodule DuplicateProductError do
      defstruct message: "This product already exists."
    end

    defmodule ProductCreated do
      defstruct message: "The product was successfully created."
    end

    defmodule GatewayError do
      defstruct message: "The gateway failed to save the product."
    end

    def create(product, deps) do
      gateway = deps[:with_gateway]
      notifier = deps[:with_notifier]

      with {:ok, product} <- gateway.store(product),
           :ok <- notifier.notify_of_product_creation(product) do
        %ProductCreated{}
      else
        {:error, :duplicate_product} -> %DuplicateProductError{}
        :error -> %GatewayError{}
      end
    end
  end
end
