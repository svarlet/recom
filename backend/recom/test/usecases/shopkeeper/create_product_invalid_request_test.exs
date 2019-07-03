defmodule Recom.Usecases.Shopkeeper.CreateProduct_InvalidRequest_Test do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Usecases.Shopkeeper.CreateProduct

  setup do
    %{
      notification_service: nil,
      products_gateway: nil,
      request: %CreateProduct.Request{
        price: 100,
        interval: Interval.new(from: Timex.now(), until: [days: 1]),
        quantity: 45,
        name: "irrelevant"
      }
    }
  end

  test "given a negative price, it returns {:error, {:validation, :negative_price}}", context do
    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{context.request | price: -100},
        notification_service: context.notification_service,
        products_gateway: context.products_gateway
      )

    assert_negative_price_reported(validation_errors)
  end

  test "given a negative quantity, it returns {:error, {:validation, :negative_quantity}}",
       context do
    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{context.request | quantity: -1},
        notification_service: context.notification_service,
        products_gateway: context.products_gateway
      )

    assert_negative_quantity_reported(validation_errors)
  end

  test "given a negative price and a negative quantity, it returns both errors", context do
    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{context.request | quantity: -2, price: -24},
        notification_service: context.notification_service,
        products_gateway: context.products_gateway
      )

    assert_negative_price_reported(validation_errors)
    assert_negative_quantity_reported(validation_errors)
  end

  test "given an empty name, it returns an error", context do
    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{context.request | name: ""},
        notification_service: context.notification_service,
        products_gateway: context.products_gateway
      )

    assert_empty_name_reported(validation_errors)
  end

  test "if after trimming the name is empty, it returns an error", context do
    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{context.request | name: "    \n  \t \r"},
        notification_service: context.notification_service,
        products_gateway: context.products_gateway)

    assert_empty_name_reported(validation_errors)
  end

  defp assert_negative_quantity_reported(errors) do
    assert {:quantity, [:negative]} in errors
  end

  defp assert_negative_price_reported(errors) do
    assert {:price, [:negative]} in errors
  end

  defp assert_empty_name_reported(errors) do
    assert {:name, [:empty]} in errors
  end
end
