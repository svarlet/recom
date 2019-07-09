defmodule Recom.Api.Shopkeeper.CreateProductController do
  def create_product(conn, _) do
    Plug.Conn.send_resp(conn, 422, "")
  end
end

defmodule Recom.Api.Shopkeeper.CreateProductControllerTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProductController

  describe "http payload fails syntaxic validation" do
    test "it sends a response" do
      invalid_payload = %{}

      response =
        Plug.Test.conn(:post, "/create_product", invalid_payload)
        |> CreateProductController.create_product(with_usecase: nil)

      assert response.state == :sent
    end

    test "when the name is not a string, it responds with a 422 status code" do
      invalid_payload = %{
        "name" => 1,
        "quantity" => 2,
        "price" => 3,
        "start" => "2019-07-08T12:13:03.104019Z",
        "end" => "2019-07-10T12:13:03.104019Z"
      }

      response =
        Plug.Test.conn(:post, "/create_product", invalid_payload)
        |> CreateProductController.create_product(with_usecase: nil)

      assert response.status == 422
    end

    @tag :skip
    test "when the name is missing, it responds with a 422 status code"

    @tag :skip
    test "when the quantity is not an integer, it responds with a 422 status code"

    # isn't it optional? wouldn't it default to 0?
    @tag :skip
    test "when the quantity is missing, it responds with a 422 status code"

    @tag :skip
    test "when the price is not an integer, it responds with a 422 status code"

    # isn't it optional? wouldn't it default to 0?
    @tag :skip
    test "when the price is missing, it responds with a 422 status code"

    @tag :skip
    test "when the start date is not a datetime, it responds with a 422 status code"

    @tag :skip
    test "when the start date is missing, it responds with a 422 status code"

    @tag :skip
    test "when the end date is not a datetime, it responds with a 422 status code"

    @tag :skip
    test "when the end date is missing, it responds with a 422 status code"
  end

  describe "http payload fails semantic validation" do
    @tag :skip
    test "it responds with a 422 status code"

    @tag :skip
    test "it sets the content type of the response to application/json"

    @tag :skip
    test "it puts the validation errors in the body of the response as a json document"
  end

  describe "valid request" do
    @tag :skip
    test "it delegates the creation to the usecase"

    @tag :skip
    test "it responds with a 201"
  end

  describe "duplicate product" do
    @tag :skip
    test "it responds with a 409 status code"
  end

  describe "failed creation of the product" do
    @tag :skip
    test "it responds with a 500"
  end
end
