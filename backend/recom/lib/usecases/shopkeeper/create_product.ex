defmodule Recom.Usecases.Shopkeeper.CreateProduct do
  defmodule Request do
    defstruct ~w(name interval price quantity)a
  end

  def create(request, _) do
    if request.quantity < 0 do
      {:error, {:validation, :negative_quantity}}
    else
      {:error, {:validation, :negative_price}}
    end
  end
end
