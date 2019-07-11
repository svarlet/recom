defmodule Recom.Middlewares.RequireJsonTest do
  use ExUnit.Case, async: true

  import Plug.Conn, only: [put_req_header: 3, get_req_header: 2]

  alias Recom.Middlewares

  test "a request with a JSON syntax error" do
    response =
      Plug.Test.conn(:get, "/irrelevant", "{")
      |> put_req_header("content-type", "application/json")
      |> Middlewares.RequireJson.call(nil)

    assert response.state == :sent
    assert response.status == 400
    assert ["application/json"] == get_req_header(response, "content-type")

    assert Jason.decode!(response.resp_body) == %{
             "message" => "JSON parsing error"
           }
  end

  test "a request with a well formed JSON" do
    conn =
      Plug.Test.conn(:get, "/irrelevant", ~S"""
      {
        "name": "Victor Hugo",
        "profession": "Writer"
      }
      """)
      |> put_req_header("content-type", "application/json")

    conn = Middlewares.RequireJson.call(conn, nil)

    assert conn.body_params["name"] == "Victor Hugo"
    assert conn.body_params["profession"] == "Writer"
  end
end
