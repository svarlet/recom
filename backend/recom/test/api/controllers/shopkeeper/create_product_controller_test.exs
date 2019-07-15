defmodule Recom.Api.Shopkeeper.CreateProductPayloadScanner do
  @callback scan(map()) :: ScanningError.t()

  defmodule ScanningError do
    defstruct [:message, :errors]
  end
end

defmodule Recom.Api.Shopkeeper.CreateProductPresenter do
  @callback respond(Conn.t(), ScanningError.t()) :: Conn.t()
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
  defmock(CreateProductPresenter.Mock, for: CreateProductPresenter)

  test "invalid json payload" do
    invalid_payload = %{irrelevant_field: 0}
    request = Plug.Test.conn(:post, "/create_product", invalid_payload)

    scanning_errors = %ScanningError{
      message: :__message__,
      errors: :__errors__
    }

    stub(CreateProductPayloadScanner.Stub, :scan, fn _ -> scanning_errors end)
    expect(CreateProductPresenter.Mock, :respond, fn ^request, ^scanning_errors -> :ok end)

    CreateProductController.create_product(request,
      with_scanner: CreateProductPayloadScanner.Stub,
      with_usecase: nil,
      with_presenter: CreateProductPresenter.Mock
    )
  end
end
