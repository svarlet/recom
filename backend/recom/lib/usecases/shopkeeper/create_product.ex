defmodule Recom.Usecases.Shopkeeper.CreateProduct.GatewayError do
  defexception [:message]
end

defmodule Recom.Usecases.Shopkeeper.CreateProduct.DuplicateProductError do
  defexception [:message]
end
