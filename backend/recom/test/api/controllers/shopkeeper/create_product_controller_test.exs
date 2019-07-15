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

  setup :verify_on_exit!

  alias Recom.Api.Shopkeeper.CreateProductController
  alias Recom.Api.Shopkeeper.CreateProductPresenter
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner
  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner.ScanningError

  defmock(CreateProductPayloadScanner.Stub, for: CreateProductPayloadScanner)
  defmock(CreateProductPresenter.Stub, for: CreateProductPresenter)

  test "invalid json payload" do
    invalid_payload = %{irrelevant_field: 0}
    request = Plug.Test.conn(:post, "/create_product", invalid_payload)

    scanning_errors = %ScanningError{
      message: :__message__,
      errors: :__errors__
    }

    stub(CreateProductPayloadScanner.Stub, :scan, fn _ -> scanning_errors end)

    body = ~S"""
    {
      "the": "body"
    }
    """

    stub(CreateProductPresenter.Stub, :present, fn ^scanning_errors -> body end)

    {status, headers, actual_body} =
      request
      |> CreateProductController.create_product(
        with_scanner: CreateProductPayloadScanner.Stub,
        with_usecase: nil,
        with_presenter: CreateProductPresenter.Stub
      )
      |> Plug.Test.sent_resp()

    assert status == 422
    assert {"content-type", "application/json"} in headers
    assert actual_body == body
  end
end
