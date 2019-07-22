# REFACTOR rename to ConnectionReducer? (conn + event = new conn)
defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder do
  import Plug.Conn

  def build(conn, error) do
    {:ok, body} = Jason.encode(error)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(422, body)
  end
end

defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilderTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError
  alias Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder

  describe "given a connection and a scanning error" do
    setup do
      irrelevant_payload = %{}
      conn = Plug.Test.conn(:post, "/create_product", irrelevant_payload)
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
    @tag :skip
    test "it sends the response"

    @tag :skip
    test "it sets the response status to 422"

    @tag :skip
    test "it sets the content-type header to application/json"

    @tag :skip
    test "it sets the response body with the error properties"
  end

  describe "given a connection and a gateway error" do
    @tag :skip
    test "it sends the response"

    @tag :skip
    test "it sets the response status to 500"

    @tag :skip
    test "it sets the content-type header to application/json"

    @tag :skip
    test "it sets the response body with the error properties"
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
  end
end
