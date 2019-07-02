defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Usecases.Shopkeeper.CreateProduct

  test "given a negative price, it returns {:error, {:validation, :negative_price}}" do
    unnecessary_notification_service = nil
    unnecessary_products_gateway = nil

    response =
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

    assert {:error, {:validation, :negative_price}} == response
  end
end
