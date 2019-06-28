defmodule Api.Shopper.PurchasablesController do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  def list(conn, at: instant, with_usecase: usecase) do
    case usecase.list_purchasables(instant) do
      {:ok, purchasables} ->
        {:ok, body} = Jason.encode_to_iodata(%{purchasables: purchasables, instant: instant})

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, body)

      :error ->
        conn
        |> send_resp(500, "")
    end
  end
end
