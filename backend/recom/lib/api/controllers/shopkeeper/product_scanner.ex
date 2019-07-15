defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  @behaviour Plug

  import Plug.Conn

  alias Recom.Entities.Product

  def init(scanner: product_scanner), do: [scanner: product_scanner]

  def call(conn, scanner: product_scanner) do
    case product_scanner.scan(conn.params) do
      %Product{} ->
        conn

      :error ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(422, ~S"""
        {
          "message": "Not a valid representation of a product"
        }
        """)
    end
  end
end
