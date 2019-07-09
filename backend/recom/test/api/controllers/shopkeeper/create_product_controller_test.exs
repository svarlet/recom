defmodule Recom.Api.Shopkeeper.CreateProductController do
  def create_product(conn, _) do
    Plug.Conn.send_resp(conn, 422, "")
  end
end

defmodule Recom.Api.Shopkeeper.CreateProductControllerTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProductController

  describe "http payload fails syntaxic validation" do
    setup context do
      valid_payload = %{
        "name" => "Orange Juice with bits",
        "quantity" => 2_000,
        "price" => 345,
        "start" => "2019-07-08T12:13:03.104019Z",
        "end" => "2019-07-11T12:13:03.104019Z"
      }

      overrides =
        context
        |> Map.take(~w{name quantity price start end}a)
        |> Enum.map(fn {key, value} -> {to_string(key), value} end)
        |> Enum.into(%{})

      invalid_payload = Map.merge(valid_payload, overrides)

      response =
        Plug.Test.conn(:post, "/create_product", invalid_payload)
        |> CreateProductController.create_product(with_usecase: nil)

      %{response: response}
    end

    @tag name: 1
    test "it sends a response", context do
      assert context.response.state == :sent
    end

    @tag name: 1
    test "when the name is not a string, it responds with a 422 status code", context do
      assert context.response.status == 422
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
