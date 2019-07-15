defmodule Recom.Api.Shopkeeper.CreateProductControllerTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Plug.Test, only: [conn: 3]
  import Plug.Conn, only: [get_resp_header: 2]

  setup :verify_on_exit!

  alias Recom.Api.Shopkeeper.CreateProductController
  alias Recom.Api.Shopkeeper.CreateProductPresenter
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner.ScanningError
  alias Recom.Usecases.Shopkeeper.CreateProduct
  alias Recom.Entities.Product

  defmock(CreateProductPayloadScanner.Stub, for: CreateProductPayloadScanner)
  defmock(CreateProductPresenter.Stub, for: CreateProductPresenter)
  defmock(CreateProduct.Mock, for: CreateProduct.Behaviour)

  describe "invalid json payload" do
    setup do
      stub(CreateProductPayloadScanner.Stub, :scan, fn _ -> %ScanningError{} end)
      stub(CreateProductPresenter.Stub, :present, fn _ -> "the body" end)

      invalid_payload = %{irrelevant_field: 0}

      %{
        response:
          :post
          |> conn("/create_product", invalid_payload)
          |> CreateProductController.create_product(
            with_scanner: CreateProductPayloadScanner.Stub,
            with_usecase: nil,
            with_presenter: CreateProductPresenter.Stub
          )
      }
    end

    test "it sets the status to 422", context do
      assert context.response.status == 422
    end

    test "it sets the response content-type to application/json", context do
      assert ["application/json"] ==
               get_resp_header(context.response, "content-type")
    end

    test "it delegates the creation of the response body to the presenter", context do
      assert context.response.resp_body == "the body"
    end
  end

  describe "payload for an original product" do
    test "it delegates the creation of the product to the usecase" do
      new_product_payload = %{
        "name" => "irrelevant",
        "price" => 1,
        "quantity" => 1,
        "from" => "2019-01-31T13:00:00.000000Z",
        "end" => "2019-02-01T13:00:00.000000Z"
      }

      product = %Product{
        name: "irrelevant",
        price: 1,
        quantity: 1,
        time_span: Interval.new(from: ~U[2019-01-31 13:00:00.000000Z], until: [days: 1])
      }

      stub(CreateProductPayloadScanner.Stub, :scan, fn _ -> product end)
      expect(CreateProduct.Mock, :create, fn ^product -> {:ok, product} end)
      stub(CreateProductPresenter.Stub, :present, fn _ -> "irrelevant body" end)

      :post
      |> conn("/create_product", new_product_payload)
      |> CreateProductController.create_product(
        with_scanner: CreateProductPayloadScanner.Stub,
        with_usecase: CreateProduct.Mock,
        with_presenter: CreateProductPresenter.Stub
      )
    end
  end
end
