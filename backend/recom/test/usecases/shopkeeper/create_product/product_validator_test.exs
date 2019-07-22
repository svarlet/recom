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

defmodule Recom.Usecases.Shopkeeper.CreateProduct.ProductValidatorTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator.ValidationError

  @a_valid_product %Product{
    name: "Oranges 2kg",
    price: 1,
    quantity: 1,
    time_span:
      Interval.new(
        from: ~U[2018-10-15 14:00:00.000000Z],
        until: [days: 1]
      )
  }

  setup context do
    a_valid_product = @a_valid_product

    overriden_product =
      if context[:overrides] do
        Enum.reduce(context[:overrides], a_valid_product, fn
          {:blank, field}, product -> Map.put(product, field, "   \r   \t \n   ")
          {:negative, field}, product -> Map.put(product, field, -1)
          _, _ -> raise "Unsupported override instruction."
        end)
      else
        a_valid_product
      end

    [result: ProductValidator.validate(overriden_product)]
  end

  @tag overrides: [blank: :name]
  test "name is blank", context do
    assert %ValidationError{message: "Invalid product.", reason: %{name: "The value is blank."}} ==
             context.result
  end

  @tag overrides: [negative: :price]
  test "price is negative", context do
    assert %ValidationError{
             message: "Invalid product.",
             reason: %{price: "The price is negative."}
           } == context.result
  end

  @tag overrides: [negative: :quantity]
  test "quantity is negative", context do
    assert %ValidationError{
             message: "Invalid product.",
             reason: %{quantity: "The quantity is negative."}
           } == context.result
  end

  @tag :skip
  test "end precedes from"

  test "valid product", context do
    assert context.result == @a_valid_product
  end
end
