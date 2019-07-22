defmodule Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator do
  defmodule ValidationError do
    defexception ~w{message reason}a
  end

  def validate(product) do
    if String.trim(product.name) == "" do
      %ValidationError{message: "Invalid product.", reason: %{name: "The value is blank."}}
    else
      if product.price < 0 do
        %ValidationError{message: "Invalid product.", reason: %{price: "The price is negative."}}
      end
    end
  end
end

defmodule Recom.Usecases.Shopkeeper.CreateProduct.ProductValidatorTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator.ValidationError

  test "name is blank" do
    product = %Product{
      name: "    \t \n  \r\n ",
      price: 1,
      quantity: 1,
      time_span:
        Interval.new(
          from: ~U[2018-10-15 14:00:00.000000Z],
          until: [days: 1]
        )
    }

    assert %ValidationError{message: "Invalid product.", reason: %{name: "The value is blank."}} ==
             ProductValidator.validate(product)
  end

  test "price is negative" do
    product = %Product{
      name: "Oranges 2kg",
      price: -1,
      quantity: 1,
      time_span:
        Interval.new(
          from: ~U[2018-10-15 14:00:00.000000Z],
          until: [days: 1]
        )
    }

    assert %ValidationError{
             message: "Invalid product.",
             reason: %{price: "The price is negative."}
           } == ProductValidator.validate(product)
  end

  @tag :skip
  test "quantity is negative"

  @tag :skip
  test "end precedes from"

  @tag :skip
  test "valid product"
end
