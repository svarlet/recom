defmodule Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator do
  defmodule ValidationError do
    defexception ~w{message reason}a
  end

  def validate(product) do
    cond do
      String.trim(product.name) == "" ->
        %ValidationError{message: "Invalid product.", reason: %{name: "The value is blank."}}

      product.price < 0 ->
        %ValidationError{message: "Invalid product.", reason: %{price: "The price is negative."}}

      product.quantity < 0 ->
        %ValidationError{
          message: "Invalid product.",
          reason: %{quantity: "The quantity is negative."}
        }

      true ->
        product
    end
  end
end
