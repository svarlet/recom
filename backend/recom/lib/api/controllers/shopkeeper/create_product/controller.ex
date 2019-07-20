defmodule Recom.Api.Shopkeeper.CreateProduct.Controller do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.ScanningError
  alias Recom.Entities.Product

  def create_product(conn, with_scanner: scanner, with_usecase: usecase, with_presenter: presenter) do
    with %Product{} = product <- scanner.scan(conn.params),
         :ok <- usecase.create(product),
         body <- presenter.present(:ok) do
      send_resp(conn, 201, body)
    else
      # REFACTOR Create a protocol accepting a struct and the conn for a polymorphic presenter and shrink this code significantly
      %ScanningError{} = error ->
        body = presenter.present(error)

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(422, body)

      error when error in ~w{duplicate_product}a ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(422, presenter.present(error))
    end
  end
end
