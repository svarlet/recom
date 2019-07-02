defmodule Recom.Usecases.Shopkeeper.CreateProduct do
  defmodule Request do
    defstruct ~w(name interval price quantity)a
  end

  def create(_, _) do
    {:error, {:validation, :negative_price}}
  end
end
