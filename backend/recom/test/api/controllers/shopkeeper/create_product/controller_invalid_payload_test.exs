defmodule Recom.Api.Shopkeeper.CreateProduct.Controller_InvalidPayloadTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Plug.Test, only: [conn: 3]
  import Plug.Conn, only: [get_resp_header: 2]

  setup :verify_on_exit!

  alias Recom.Api.Shopkeeper.CreateProduct.Controller
  alias Recom.Api.Shopkeeper.CreateProduct.Presenter
  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner
  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.ScanningError

  defp http_request(with_payload: payload), do: conn(:post, "/create_product", payload)

  defp assert_json_response(response) do
    assert ["application/json"] == get_resp_header(response, "content-type")
  end

  setup do
    stub(PayloadScanner.Stub, :scan, fn _ -> %ScanningError{} end)
    stub(Presenter.Stub, :present, fn _ -> "details about the scanning error" end)

    response =
      http_request(with_payload: "invalid_payload")
      |> Controller.create_product(
        with_scanner: PayloadScanner.Stub,
        with_usecase: nil,
        with_presenter: Presenter.Stub
      )

    [response: response]
  end

  test "it sends a response", context do
    assert context.response.state == :sent
  end

  test "it sets the status to 422", context do
    assert context.response.status == 422
  end

  test "it sets the response content-type to application/json", context do
    assert_json_response(context.response)
  end

  test "it delegates the creation of the response body to the presenter", context do
    assert context.response.resp_body == "details about the scanning error"
  end
end
