defmodule Recom.Usecases.Shopkeeper.CreateProduct do
  alias Recom.Entities.Product

  defmodule Request do
    @type t :: %__MODULE__{
            name: String.t(),
            price: non_neg_integer(),
            quantity: non_neg_integer(),
            interval: Timex.Interval.t()
          }
    defstruct ~w(name interval price quantity)a
  end

  defmodule ValidatorBehaviour do
    @type error :: {atom, nonempty_list(atom)}
    @type errors :: list(error())

    @callback validate(request :: Request.t()) :: {:validation, errors()}
  end

  defmodule ProductsGateway do
    @callback store(Entities.Product.t()) :: {:ok, Entities.Product.t()} | {:error, term}
  end

  defmodule RequestValidator do
    @behaviour ValidatorBehaviour

    @impl true
    def validate(request) do
      validation_errors =
        []
        |> validate_request_quantity(request)
        |> validate_request_price(request)
        |> validate_request_name(request)

      {:validation, validation_errors}
    end

    defp validate_request_price(validation_state, request) do
      if request.price < 0 do
        [{:price, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_request_quantity(validation_state, request) do
      if request.quantity < 0 do
        [{:quantity, [:negative]} | validation_state]
      else
        validation_state
      end
    end

    defp validate_request_name(validation_state, request) do
      if String.trim(request.name) == "" do
        [{:name, [:empty]} | validation_state]
      else
        validation_state
      end
    end
  end

  def create(request, with_validator: validator, with_gateway: gateway) do
    with {:validation, []} <- validator.validate(request) do
      product =
        Product.new(
          name: request.name,
          time_span: request.interval,
          price: request.price,
          quantity: request.quantity
        )

      case gateway.store(product) do
        {:ok, product} -> {:ok, product}
      end
    else
      {:validation, errors} -> {:error, {:validation, errors}}
    end
  end
end
