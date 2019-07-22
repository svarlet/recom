# REFACTOR rename to ConnectionReducer? (conn + event = new conn)
defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder do
  import Plug.Conn

  def build(conn, _error) do
    send_resp(conn, 200, "")
  end
end

defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilderTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError
  alias Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder

  describe "given a connection and a scanning error" do
    test "it sends the response" do
      irrelevant_payload = %{}
      conn = Plug.Test.conn(:post, "/create_product", irrelevant_payload)
      result = %ScanningError{message: "the message", reason: %{field: "invalid"}}
      response = ResponseBuilder.build(conn, result)
      assert response.state == :sent
    end

    @tag :skip
    test "it sets the response status to 422"

    @tag :skip
    test "it sets the content-type header to application/json"

    @tag :skip
    test "it sets the response body with the error properties"
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
