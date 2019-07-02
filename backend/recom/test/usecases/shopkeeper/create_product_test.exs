defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Usecases.Shopkeeper.CreateProduct

  test "given a negative price, it returns {:error, {:validation, :negative_price}}" do
    unnecessary_notification_service = nil
    unnecessary_products_gateway = nil

    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{
          price: -100,
          interval: Interval.new(from: Timex.now(), until: [days: 1]),
          quantity: 45,
          name: "irrelevant"
        },
        notification_service: unnecessary_notification_service,
        products_gateway: unnecessary_products_gateway
      )

    assert_negative_price_reported(validation_errors)
  end

  test "given a negative quantity, it returns {:error, {:validation, :negative_quantity}}" do
    unnecessary_notification_service = nil
    unnecessary_products_gateway = nil

    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{
          quantity: -1,
          interval: Interval.new(from: Timex.now(), until: [days: 1]),
          name: "irrelevant",
          price: 100
        },
        notification_service: unnecessary_notification_service,
        products_gateway: unnecessary_products_gateway
      )

    assert_negative_quantity_reported(validation_errors)
  end

  test "given a negative price and a negative quantity, it returns both errors" do
    unnecessary_notification_service = nil
    unnecessary_products_gateway = nil

    {:error, {:validation, validation_errors}} =
      CreateProduct.create(
        %CreateProduct.Request{
          quantity: -2,
          price: -24,
          interval: Interval.new(from: Timex.now(), until: [days: 1]),
          name: "irrelevant"
        },
        notification_service: unnecessary_notification_service,
        products_gateway: unnecessary_products_gateway
      )

    assert_negative_price_reported(validation_errors)
    assert_negative_quantity_reported(validation_errors)
  end

  defp assert_negative_quantity_reported(errors) do
    assert {:quantity, [:negative]} in errors
  end

  defp assert_negative_price_reported(errors) do
    assert {:price, [:negative]} in errors
  end
end
