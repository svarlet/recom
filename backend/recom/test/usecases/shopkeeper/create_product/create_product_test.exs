defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper.CreateProduct
  alias Recom.Entities.Product

  setup :verify_on_exit!

  defmock(CreateProduct.ValidatorDouble, for: CreateProduct.ValidatorBehaviour)
  defmock(CreateProduct.ProductsGatewayMock, for: CreateProduct.ProductsGateway)

  describe "original product" do
    test "it stores the product" do
      request = %CreateProduct.Request{
        name: "irrelevant name",
        interval: Interval.new(from: Timex.now(), until: [days: 1]),
        price: 100,
        quantity: 2_500
      }

      stub(CreateProduct.ValidatorDouble, :validate, fn _valid_request ->
        {:validation, []}
      end)

      expect(CreateProduct.ProductsGatewayMock, :store, fn original_product ->
        {:ok, original_product}
      end)

      expected_product = %Product{
        name: request.name,
        time_span: request.interval,
        price: request.price,
        quantity: request.quantity
      }

      assert {:ok, expected_product} ==
               CreateProduct.create(request,
                 with_validator: CreateProduct.ValidatorDouble,
                 with_gateway: CreateProduct.ProductsGatewayMock
               )
    end

    @tag :skip
    test "it dispatches a notification"
  end

  describe "dupplicate product" do
    @tag :skip
    test "it returns an error"

    @tag :skip
    test "it dispatches a warning notification"
  end

  describe "semantically invalid request" do
    test "it returns an error" do
      stub(CreateProduct.ValidatorDouble, :validate, fn :__invalid_request__ ->
        {:validation, :__a_validation_error__}
      end)

      result =
        CreateProduct.create(:__invalid_request__,
          with_validator: CreateProduct.ValidatorDouble,
          with_gateway: nil
        )

      assert {:error, {:validation, :__a_validation_error__}} == result
    end
  end
end
