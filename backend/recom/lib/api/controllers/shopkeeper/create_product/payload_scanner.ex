defmodule Recom.Api.Shopkeeper.CreateProduct.PayloadScanner do
  @callback scan(map()) :: ScanningError.t() | Product.t()

  defmodule ScanningError do
    defstruct [:message, :errors]
  end
end
