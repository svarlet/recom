defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper.CreateProduct

  setup :verify_on_exit!

  defmock(CreateProduct.ProductValidatorDouble, for: CreateProduct.ProductValidatorBehaviour)
  defmock(CreateProduct.ProductsGatewayMock, for: CreateProduct.ProductsGateway)

  describe "original product" do
    test "it stores the product" do
      stub(CreateProduct.ProductValidatorDouble, :validate, fn :__original_product__ ->
        {:validation, []}
      end)

      expect(CreateProduct.ProductsGatewayMock, :store, fn :__original_product__ ->
        {:ok, :__saved_product__}
      end)

      assert {:ok, :__saved_product__} ==
               CreateProduct.create(:__original_product__,
                 with_validator: CreateProduct.ProductValidatorDouble,
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
      stub(CreateProduct.ProductValidatorDouble, :validate, fn :__invalid_request__ ->
        {:validation, :__a_validation_error__}
      end)

      result =
        CreateProduct.create(:__invalid_request__,
          with_validator: CreateProduct.ProductValidatorDouble,
          with_gateway: nil
        )

      assert {:error, {:validation, :__a_validation_error__}} == result
    end
  end
end
