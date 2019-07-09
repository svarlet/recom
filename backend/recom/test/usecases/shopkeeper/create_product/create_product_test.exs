defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper

  setup :verify_on_exit!

  defmock(Shopkeeper.ProductValidatorDouble, for: Shopkeeper.ProductValidatorBehaviour)
  defmock(Shopkeeper.ProductsGatewayDouble, for: Shopkeeper.ProductsGateway)
  defmock(Shopkeeper.NotifierDouble, for: Shopkeeper.Notifier)

  describe "original product" do
    setup do
      stub(Shopkeeper.ProductValidatorDouble, :validate, fn :__original_product__ ->
        {:validation, []}
      end)

      %{
        deps: [
          with_validator: Shopkeeper.ProductValidatorDouble,
          with_gateway: Shopkeeper.ProductsGatewayDouble,
          with_notifier: Shopkeeper.NotifierDouble
        ]
      }
    end

    test "it stores the product", context do
      expect(Shopkeeper.ProductsGatewayDouble, :store, fn :__original_product__ ->
        {:ok, :__saved_product__}
      end)

      stub(Shopkeeper.NotifierDouble, :notify_of_product_creation, fn _ -> :ok end)

      assert {:ok, :__saved_product__} ==
               Shopkeeper.CreateProduct.create(:__original_product__, context.deps)
    end

    test "it dispatches a notification of product creation", context do
      stub(Shopkeeper.ProductsGatewayDouble, :store, fn :__original_product__ ->
        {:ok, :__saved_product__}
      end)

      expect(Shopkeeper.NotifierDouble, :notify_of_product_creation, fn :__saved_product__ ->
        :ok
      end)

      Shopkeeper.CreateProduct.create(:__original_product__, context.deps)
    end
  end

  describe "duplicate product" do
    test "it returns an error" do
      stub(Shopkeeper.ProductValidatorDouble, :validate, fn :__duplicate_product__ ->
        {:validation, []}
      end)

      expect(Shopkeeper.ProductsGatewayDouble, :store, fn :__duplicate_product__ ->
        {:error, :duplicate_product}
      end)

      assert {:error, :duplicate_product} ==
               Shopkeeper.CreateProduct.create(:__duplicate_product__,
                 with_validator: Shopkeeper.ProductValidatorDouble,
                 with_gateway: Shopkeeper.ProductsGatewayDouble,
                 with_notifier: nil
               )
    end
  end

  describe "semantically invalid product" do
    test "it returns an error" do
      stub(Shopkeeper.ProductValidatorDouble, :validate, fn :__invalid_request__ ->
        {:validation, :__a_validation_error__}
      end)

      result =
        Shopkeeper.CreateProduct.create(:__invalid_request__,
          with_validator: Shopkeeper.ProductValidatorDouble,
          with_gateway: nil,
          with_notifier: nil
        )

      assert {:error, {:validation, :__a_validation_error__}} == result
    end
  end

  describe "handling of a gateway failure" do
    test "it returns an error" do
      stub(Shopkeeper.ProductValidatorDouble, :validate, fn :__valid_product__ ->
        {:validation, []}
      end)

      stub(Shopkeeper.ProductsGatewayDouble, :store, fn :__valid_product__ -> :error end)

      assert :error ==
               Shopkeeper.CreateProduct.create(:__valid_product__,
                 with_validator: Shopkeeper.ProductValidatorDouble,
                 with_gateway: Shopkeeper.ProductsGatewayDouble,
                 with_notifier: nil
               )
    end
  end
end
