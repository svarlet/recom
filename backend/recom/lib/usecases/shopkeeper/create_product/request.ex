defmodule Recom.Usecases.Shopkeeper.CreateProduct.Request do
  @type t :: %__MODULE__{name: String.t, price: non_neg_integer(), quantity: non_neg_integer(), interval: Timex.Interval.t}
  defstruct ~w(name interval price quantity)a
end
