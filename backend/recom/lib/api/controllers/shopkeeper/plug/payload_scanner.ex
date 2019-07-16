defmodule Recom.Api.Shopkeeper.Plug.PayloadScanner do
  @behaviour Plug

  import Plug.Conn

  alias Recom.Entities.Product

  @callback scan(map()) :: {:ok, term} | {:error, String.t()}

  def init(scanner: product_scanner), do: [scanner: product_scanner]

  def call(conn, scanner: product_scanner) do
    case product_scanner.scan(conn.params) do
      %Product{} = product ->
        conn
        |> put_private(:scanner, %{result: product})

      {:error, reason} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(422, ~s"""
        {
          "message": "#{reason}"
        }
        """)
    end
  end
end
