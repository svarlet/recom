defmodule Api.Shopper.PurchasablesController do
  import Plug.Conn, only: [send_resp: 3]

  def list(conn, at: instant, with_usecase: usecase) do
    usecase.list_purchasables(instant)
    send_resp(conn, 200, "")
  end
end
