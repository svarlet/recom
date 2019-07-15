defmodule Recom.Api.Shopkeeper.CreateProductController do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  def create_product(conn, with_scanner: scanner, with_usecase: _, with_presenter: presenter) do
    body =
      conn.params
      |> scanner.scan()
      |> presenter.present()

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(422, body)
  end
end
