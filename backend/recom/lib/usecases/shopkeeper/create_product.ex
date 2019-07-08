defmodule Recom.Usecases.Shopkeeper.CreateProduct do
  alias Recom.Entities.Product

  defmodule ProductsGateway do
    @callback store(Entities.Product.t()) :: {:ok, Entities.Product.t()} | {:error, term}
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
        []
        |> validate_request_quantity(product)
        |> validate_request_price(product)
        |> validate_request_name(product)

      {:validation, validation_errors}
    end

    defp validate_request_price(validation_state, product) do
      if product.price < 0 do
        [{:price, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_request_quantity(validation_state, product) do
      if product.quantity < 0 do
        [{:quantity, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_request_name(validation_state, product) do
      if String.trim(product.name) == "" do
        [{:name, [:empty]} | validation_state]
      else
        validation_state
      end
    end
  end

  def create(product, with_validator: validator, with_gateway: gateway) do
    with {:validation, []} <- validator.validate(product) do
      case gateway.store(product) do
        {:ok, product} -> {:ok, product}
      end
    else
      {:validation, errors} -> {:error, {:validation, errors}}
    end
  end
end
