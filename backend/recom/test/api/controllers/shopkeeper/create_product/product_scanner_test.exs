defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScanner do
  defmodule ScanningError do
    defexception message: "Nil payload."
  end

  def scan(nil) do
    %ScanningError{}
  end
end

defmodule Recom.Api.Shopkeeper.CreateProduct.ProductScannerTest do
  use ExUnit.Case, async: true

  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner
  alias Recom.Api.Shopkeeper.CreateProduct.ProductScanner.ScanningError

  test "payload is nil" do
    assert %ScanningError{message: "Nil payload."} == ProductScanner.scan(nil)
  end
end
