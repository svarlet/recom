defmodule Recom.Api.Shopkeeper.CreateProductPayloadScanner do
  @callback scan(map()) :: ScanningError.t()

  defmodule ScanningError do
    defstruct [:message, :errors]
  end
end

defmodule Recom.Api.Shopkeeper.CreateProductPresenter do
  @callback present(ScanningError.t()) :: String.t()
end

defmodule Recom.Api.Shopkeeper.CreateProductControllerTest do
  use ExUnit.Case, async: true

  import Mox
  import Plug.Test, only: [conn: 3]
  import Plug.Conn, only: [get_resp_header: 2]

  setup :verify_on_exit!

  alias Recom.Api.Shopkeeper.CreateProductController
  alias Recom.Api.Shopkeeper.CreateProductPresenter
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner.ScanningError

  defmock(CreateProductPayloadScanner.Stub, for: CreateProductPayloadScanner)
  defmock(CreateProductPresenter.Stub, for: CreateProductPresenter)

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
end
