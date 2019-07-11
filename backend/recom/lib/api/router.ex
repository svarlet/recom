defmodule Recom.Api.Router do
  use Plug.Router

  alias Recom.CompositionRoot

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(:match)
  plug(:dispatch)

  get("/purchasables", to: CompositionRoot.Shopper.ListPurchasablesController)

  match _ do
    send_resp(conn, 404, "oops, not found")
  end
end
