defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper.CreateProduct

  setup :verify_on_exit!

  defmock(CreateProduct.ValidatorMock, for: CreateProduct.ValidatorBehaviour)

  # test "it validates the request" do
  #   request = %CreateProduct.Request{
  #     name: "irrelevant",
  #     price: 20,
  #     quantity: 100,
  #     interval: Interval.new(from: Timex.now(), until: [hours: 2])
  #   }

  #   expect(CreateProduct.ValidatorMock, :validate, fn ^request -> {:validation, []} end)

  #   CreateProduct.create(request, with_validator: CreateProduct.ValidatorMock)
  # end

  describe "empty catalog" do
    @tag :skip
    test "it creates the product"

    @tag :skip
    test "it dispatches a notification"
  end

  describe "original product" do
    @tag :skip
    test "it creates the product"

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
      stub(CreateProduct.ValidatorMock, :validate, fn :invalid_request ->
        {:validation, name: [:empty]}
      end)

      result = CreateProduct.create(:invalid_request, with_validator: CreateProduct.ValidatorMock)

      assert {:error, {:validation, name: [:empty]}} == result
    end
  end
end
