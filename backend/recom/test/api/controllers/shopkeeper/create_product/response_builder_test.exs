# REFACTOR rename to ConnectionReducer? (conn + event = new conn). That would certainly compose well with the input of the notifier too.
defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder do
  import Plug.Conn

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError
  alias Recom.Usecases.Shopkeeper.CreateProduct.GatewayError
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator.ValidationError

  def build(conn, error) do
    status =
      case error do
        %ScanningError{} -> 422
        %ValidationError{} -> 422
        %GatewayError{} -> 500
      end

    {:ok, body} = Jason.encode(error)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, body)
  end
end

defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilderTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError
  alias Recom.Usecases.Shopkeeper.CreateProduct.GatewayError
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator.ValidationError
  alias Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder

  defp fake_request_to_create_a_product() do
    irrelevant_payload = %{}
    Plug.Test.conn(:post, "/create_product", irrelevant_payload)
  end

  describe "given a connection and a scanning error" do
    setup do
      conn = fake_request_to_create_a_product()
      result = %ScanningError{message: "the message", reason: %{field: "invalid"}}
      [response: ResponseBuilder.build(conn, result)]
    end

    test "it sends the response", context do
      assert context.response.state == :sent
    end

    test "it sets the response status to 422", context do
      assert context.response.status == 422
    end

    test "it sets the content-type header to application/json", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "it sets the response body with the error properties", context do
      assert Jason.decode!(context.response.resp_body, keys: :atoms) == %{
               message: "the message",
               reason: %{
                 field: "invalid"
               }
             }
    end
  end

  describe "given a connection and a validation errors" do
    setup do
      conn = fake_request_to_create_a_product()
      error = %ValidationError{message: "semantic error", reason: %{field: "is bad"}}
      [response: ResponseBuilder.build(conn, error)]
    end

    test "it sends the response", context do
      assert context.response.state == :sent
    end

    test "it sets the response status to 422", context do
      assert context.response.status == 422
    end

    test "it sets the content-type header to application/json", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "it sets the response body with the error properties", context do
      assert Jason.decode!(context.response.resp_body, keys: :atoms) == %{
               message: "semantic error",
               reason: %{
                 field: "is bad"
               }
             }
    end
  end

  describe "given a connection and a gateway error" do
    setup do
      conn = fake_request_to_create_a_product()
      error = %GatewayError{message: "boom"}
      [response: ResponseBuilder.build(conn, error)]
    end

    test "it sends the response", context do
      assert context.response.state == :sent
    end

    test "it sets the response status to 500", context do
      assert context.response.status == 500
    end

    test "it sets the content-type header to application/json", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "it sets the response body with the error properties", context do
      assert Jason.decode!(context.response.resp_body, keys: :atoms) == %{
               message: "boom"
             }
    end
  end

  describe "given a connection and a duplicate product error" do
    @tag :skip
    test "it sends the response"

    @tag :skip
    test "it sets the response status to 422"

    @tag :skip
    test "it sets the content-type header to application/json"

    @tag :skip
    test "it sets the response body with the error properties"
  end

  describe "given a connection and a successfully saved product" do
    @tag :skip
    test "it sends the response"

    @tag :skip
    test "it sets the response status to 201"

    @tag :skip
    test "it doesn't set the content-type of the response"
  end
end
