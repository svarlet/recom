ExUnit.start()

defmodule Recom.Mocks do
  import Mox

  alias Recom.Api.Shopkeeper.CreateProduct.Presenter
  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner
  alias Recom.Usecases.Shopkeeper.CreateProduct

  defmock(PayloadScanner.Stub, for: PayloadScanner.Behaviour)
  defmock(Presenter.Stub, for: Presenter)
  defmock(CreateProduct.Double, for: CreateProduct.Behaviour)
end
