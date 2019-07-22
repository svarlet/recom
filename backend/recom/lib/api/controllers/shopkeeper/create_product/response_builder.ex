defmodule Recom.Api.Shopkeeper.CreateProduct.ResponseBuilder do
  import Plug.Conn

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError
  alias Recom.Usecases.Shopkeeper.CreateProduct.GatewayError
  alias Recom.Usecases.Shopkeeper.CreateProduct.DuplicateProductError
  alias Recom.Usecases.Shopkeeper.CreateProduct.ProductValidator.ValidationError
  alias Recom.Entities.Product

  def build(%Product{}, conn) do
    send_resp(conn, 201, "")
  end

  def build(error, conn) do
    status =
      case error do
        %ScanningError{} -> 422
        %ValidationError{} -> 422
        %DuplicateProductError{} -> 422
        %GatewayError{} -> 500
      end

    {:ok, body} = Jason.encode(error)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, body)
  end
end
