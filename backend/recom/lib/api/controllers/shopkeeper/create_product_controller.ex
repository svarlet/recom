defmodule Recom.Api.Shopkeeper.CreateProductPayloadScanner do
  @callback scan(map()) :: ScanningError.t()

  defmodule ScanningError do
    defstruct [:message, :errors]
  end
end

defmodule Recom.Api.Shopkeeper.CreateProductPresenter do
  @callback present(ScanningError.t()) :: String.t()
end

defmodule Recom.Api.Shopkeeper.CreateProductController do
  import Plug.Conn, only: [send_resp: 3, put_resp_header: 3]

  alias Recom.Api.Shopkeeper.CreateProductPayloadScanner.ScanningError
  alias Recom.Entities.Product

  def create_product(conn, with_scanner: scanner, with_usecase: usecase, with_presenter: presenter) do
    body =
      case scanner.scan(conn.params) do
        %ScanningError{} = error ->
          error

        %Product{} = product ->
          {:ok, saved_product} = usecase.create(product)
          saved_product
      end
      |> presenter.present()

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(422, body)
  end
end
