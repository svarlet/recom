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

  defp http_request(with_payload: payload), do: conn(:post, "/create_product", payload)

  describe "invalid json payload" do
    setup do
      stub(CreateProductPayloadScanner.Stub, :scan, fn _ -> %ScanningError{} end)
      stub(CreateProductPresenter.Stub, :present, fn _ -> "details about the scanning error" end)

      invalid_payload = %{irrelevant_field: 0}

      %{
        response:
          http_request(with_payload: invalid_payload)
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
      assert context.response.resp_body == "details about the scanning error"
    end
  end

  describe "payload for an original product" do
    setup do
      payload = %{
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
      expect(CreateProduct.Mock, :create, fn ^product -> :ok end)
      stub(CreateProductPresenter.Stub, :present, fn _ -> "empty body" end)

      [
        response:
          http_request(with_payload: payload)
          |> CreateProductController.create_product(
            with_scanner: CreateProductPayloadScanner.Stub,
            with_usecase: CreateProduct.Mock,
            with_presenter: CreateProductPresenter.Stub
          )
      ]
    end

    test "it sets the response status to 201", context do
      assert context.response.status == 201
    end

    test "it delegates the creation of the response body to the presenter", context do
      assert context.response.resp_body == "empty body"
    end
  end

  describe "payload of a duplicate product" do
    setup do
      payload = %{
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
      stub(CreateProduct.Mock, :create, fn _product -> :duplicate_product end)
      stub(CreateProductPresenter.Stub, :present, fn _ -> nil end)

      response =
        http_request(with_payload: payload)
        |> CreateProductController.create_product(
          with_scanner: CreateProductPayloadScanner.Stub,
          with_usecase: CreateProduct.Mock,
          with_presenter: CreateProductPresenter.Stub
        )

      [response: response]
    end

    test "it responds with a 422 status", context do
      assert context.response.status == 422
    end
  end

  describe "gateway error" do
  end

  describe "semantic error" do
  end
end
