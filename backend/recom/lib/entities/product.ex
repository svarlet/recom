defmodule Recom.Entities.Product do
  use Timex

  @type t :: %__MODULE__{
          name: String.t(),
          time_span: Timex.Interval.t(),
          price: non_neg_integer(),
          quantity: non_neg_integer()
        }

  defstruct name: "", time_span: nil, price: 0, quantity: 0

  def new(fields \\ []) do
    __struct__(fields)
  end

  def before?(p1, p2) do
    Timex.before?(p1.time_span.from, p2.time_span.from)
  end

  def equal?(nil, _), do: false
  def equal?(_, nil), do: false
  def equal?(%__MODULE__{name: n1}, %__MODULE__{name: n2}) when n1 != n2, do: false
  def equal?(%__MODULE__{price: p1}, %__MODULE__{price: p2}) when p1 != p2, do: false
end
