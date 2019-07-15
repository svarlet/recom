defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  @behaviour Plug

  import Plug.Conn

  def init(_), do: nil

  def call(conn, _) do
    conn
    |> send_resp(422, "")
  end
end
