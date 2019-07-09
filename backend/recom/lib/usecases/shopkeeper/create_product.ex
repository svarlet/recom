defmodule Recom.Usecases.Shopkeeper do
  alias Recom.Entities.Product

  defmodule ProductsGateway do
    @callback store(Entities.Product.t()) ::
                {:ok, Entities.Product.t()} | {:error, :duplicate_product} | :error
  end

  defmodule ProductValidatorBehaviour do
    @type error :: {atom, nonempty_list(atom)}
    @type errors :: list(error())

    @callback validate(product :: Product.t()) :: {:validation, errors()}
  end

  defmodule ProductValidator do
    @behaviour ProductValidatorBehaviour

    @impl true
    def validate(product) do
      validation_errors =
        initial_validation_state()
        |> validate_quantity(product)
        |> validate_price(product)
        |> validate_name(product)
        |> validate_time_span(product)

      {:validation, validation_errors}
    end

    defp initial_validation_state(), do: []

    defp validate_price(validation_state, product) do
      if product.price < 0 do
        [{:price, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_quantity(validation_state, product) do
      if product.quantity < 0 do
        [{:quantity, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_name(validation_state, product) do
      if String.trim(product.name) == "" do
        [{:name, [:empty]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_time_span(validation_state, product) do
      if product.time_span == nil do
        [{:time_span, [:blank]} | validation_state]
      else
        validation_state
      end
    end
  end

  defmodule Notifier do
    @callback notify_of_product_creation(Product.t()) :: :ok
  end

  defmodule CreateProduct do
    defmodule Behaviour do
      @type result :: {:ok, Product.t()} | {:error, :duplicate_product} | :error
      @callback create(Product.t()) :: result
    end

    def create(product, with_validator: validator, with_gateway: gateway, with_notifier: notifier) do
      with {:validation, []} <- validator.validate(product),
           {:ok, product} <- gateway.store(product),
           :ok <- notifier.notify_of_product_creation(product) do
        {:ok, product}
      else
        {:validation, errors} -> {:error, {:validation, errors}}
        {:error, :duplicate_product} -> {:error, :duplicate_product}
        :error -> :error
      end
    end
  end
end
