defmodule Recom.Usecases.Shopkeeper.CreateProduct do
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

  def create(request, with_validator: validator) do
    {:error, validator.validate(request)}
  end
end
