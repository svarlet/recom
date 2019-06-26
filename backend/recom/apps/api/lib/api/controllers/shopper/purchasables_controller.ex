defmodule Api.Shopper.PurchasablesController do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  def list(conn, at: instant, with_usecase: usecase) do
    {:ok, purchasables} = usecase.list_purchasables(instant)

    {:ok, body} = Jason.encode_to_iodata(%{purchasables: purchasables})

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
  end
end
