defmodule Recom.Api.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias Recom.CompositionRoot

  @malformed_json_error ~S"""
  {
    "message": "Malformed JSON"
  }
  """

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)

  plug(:dispatch)

  get("/purchasables", to: CompositionRoot.Shopper.ListPurchasablesController)

  match _ do
    send_resp(conn, 404, "oops, not found")
  end

  def handle_errors(conn, %{reason: %Plug.Parsers.ParseError{exception: %Jason.DecodeError{}}}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(400, @malformed_json_error)
  end
end
