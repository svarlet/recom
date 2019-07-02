defmodule Recom.Usecases.Shopkeeper.CreateProduct do
  defmodule Request do
    defstruct ~w(name interval price quantity)a
  end

  def create(request, _) do
    validation_errors =
      []
      |> validate_request_quantity(request)
      |> validate_request_price(request)

    {:error, {:validation, validation_errors}}
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
end