defmodule Api.Shopper.PurchasablesController do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  def list(conn, at: instant, with_usecase: usecase) do
    usecase.list_purchasables(instant)
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, "")
  end
end
