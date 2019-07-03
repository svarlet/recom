defmodule Recom.Usecases.Shopkeeper.CreateProduct.RequestValidator do
  @type error :: {atom, nonempty_list(atom)}
  @type errors :: list(error())

  @spec validate(request :: CreateProduct.Request.t) :: {:validation, errors()}
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
