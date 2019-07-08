defmodule Recom.Usecases.Shopkeeper.CreateProduct.ProductValidatorTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Usecases.Shopkeeper.ProductValidator
  alias Recom.Entities.Product

  setup context do
    valid_product = %Product{
      price: 100,
      time_span: Interval.new(from: Timex.now(), until: [days: 1]),
      quantity: 45,
      name: "irrelevant"
    }

    overrides = Map.take(context, ~w{price quantity name time_span}a)

    {:validation, validation_errors} =
      valid_product
      |> Map.merge(overrides)
      |> ProductValidator.validate()

    %{validation_errors: validation_errors}
  end

  @tag price: -100
  test "given a negative price, it returns {:error, {:validation, :negative_price}}", context do
    assert_negative_price_reported(context.validation_errors)
  end

  @tag quantity: -1
  test "given a negative quantity, it returns {:error, {:validation, :negative_quantity}}",
       context do
    assert_negative_quantity_reported(context.validation_errors)
  end

  @tag quantity: -2
  @tag price: -24
  test "given a negative price and a negative quantity, it returns both errors", context do
    assert_negative_price_reported(context.validation_errors)
    assert_negative_quantity_reported(context.validation_errors)
  end

  @tag name: ""
  test "given an empty name, it returns an error", context do
    assert_empty_name_reported(context.validation_errors)
  end

  @tag name: "    \n  \t \r"
  test "if after trimming the name is empty, it returns an error", context do
    assert_empty_name_reported(context.validation_errors)
  end

  @tag time_span: nil
  test "a product must have a time span", context do
    assert_blank_time_span_reported(context.validation_errors)
  end

  #
  # Custom Assertions
  #

  defp assert_negative_quantity_reported(errors) do
    assert {:quantity, [:negative]} in errors
  end

  defp assert_negative_price_reported(errors) do
    assert {:price, [:negative]} in errors
  end

  defp assert_empty_name_reported(errors) do
    assert {:name, [:empty]} in errors
  end

  defp assert_blank_time_span_reported(errors) do
    assert {:time_span, [:blank]} in errors
  end
end
