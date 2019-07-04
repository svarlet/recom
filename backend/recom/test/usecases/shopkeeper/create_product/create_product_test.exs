defmodule Recom.Usecases.Shopkeeper.CreateProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox

  alias Recom.Usecases.Shopkeeper.CreateProduct

  setup :verify_on_exit!

  defmock(CreateProduct.ValidatorMock, for: CreateProduct.ValidatorBehaviour)

  #
  # Collaboration tests
  #
  test "it validates the request" do
    request = %CreateProduct.Request{
      name: "irrelevant",
      price: 20,
      quantity: 100,
      interval: Interval.new(from: Timex.now(), until: [hours: 2])
    }

    expect(CreateProduct.ValidatorMock, :validate, fn ^request -> {:validation, []} end)

    CreateProduct.create(request, with_validator: CreateProduct.ValidatorMock)
  end

  #
  # Contract tests
  #

  test "when validation fails, it returns a detailed error" do
    request = %CreateProduct.Request{
      name: "",
      price: 10,
      quantity: 10,
      interval: Interval.new(from: Timex.now(), until: [hours: 2])
    }

    stub(CreateProduct.ValidatorMock, :validate, fn _ -> {:validation, name: [:empty]} end)

    assert {:error, {:validation, name: [:empty]}} ==
             CreateProduct.create(request, with_validator: CreateProduct.ValidatorMock)
  end
end
