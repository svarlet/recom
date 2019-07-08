defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper.CreateProduct

  setup :verify_on_exit!

  defmock(CreateProduct.ProductValidatorDouble, for: CreateProduct.ProductValidatorBehaviour)
  defmock(CreateProduct.ProductsGatewayDouble, for: CreateProduct.ProductsGateway)
  defmock(CreateProduct.NotifierDouble, for: CreateProduct.Notifier)

  describe "original product" do
    test "it stores the product" do
      stub(CreateProduct.ProductValidatorDouble, :validate, fn :__original_product__ ->
        {:validation, []}
      end)

      expect(CreateProduct.ProductsGatewayDouble, :store, fn :__original_product__ ->
        {:ok, :__saved_product__}
      end)

      stub(CreateProduct.NotifierDouble, :notify_of_product_creation, fn _ -> :ok end)

      assert {:ok, :__saved_product__} ==
               CreateProduct.create(:__original_product__,
                 with_validator: CreateProduct.ProductValidatorDouble,
                 with_gateway: CreateProduct.ProductsGatewayDouble,
                 with_notifier: CreateProduct.NotifierDouble
               )
    end

    test "it dispatches a notification of product creation" do
      stub(CreateProduct.ProductValidatorDouble, :validate, fn :__original_product__ ->
        {:validation, []}
      end)

      stub(CreateProduct.ProductsGatewayDouble, :store, fn :__original_product__ ->
        {:ok, :__saved_product__}
      end)

      expect(CreateProduct.NotifierDouble, :notify_of_product_creation, fn :__saved_product__ ->
        :ok
      end)

      CreateProduct.create(:__original_product__,
        with_validator: CreateProduct.ProductValidatorDouble,
        with_gateway: CreateProduct.ProductsGatewayDouble,
        with_notifier: CreateProduct.NotifierDouble
      )
    end
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
          with_gateway: nil,
          with_notifier: nil
        )

      assert {:error, {:validation, :__a_validation_error__}} == result
    end
  end
end
