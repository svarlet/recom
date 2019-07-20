defmodule Recom.Api.Shopkeeper.CreateProduct.Presenter do
  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner.ScanningError

  @callback present(ScanningError.t()) :: String.t()
end
