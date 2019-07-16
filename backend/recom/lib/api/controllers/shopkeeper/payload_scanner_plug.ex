defmodule Recom.Api.Shopkeeper.PayloadScannerPlug do
  @behaviour Plug

  import Plug.Conn

  @callback scan(map()) :: {:ok, term} | {:error, String.t()}

  def init(scanner: product_scanner), do: [scanner: product_scanner]

  def call(conn, scanner: product_scanner) do
    case product_scanner.scan(conn.params) do
      {:ok, result} ->
        put_private(conn, :scanner, %{result: result})

      {:error, reason} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(422, Jason.encode!(%{message: reason}))
    end
  end
end
