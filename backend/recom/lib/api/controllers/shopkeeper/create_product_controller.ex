defmodule Recom.Api.Shopkeeper.CreateProductController do
  def create_product(conn, with_scanner: scanner, with_usecase: _, with_presenter: presenter) do
    presenter.respond(conn, scanner.scan(conn.params))
  end
end
