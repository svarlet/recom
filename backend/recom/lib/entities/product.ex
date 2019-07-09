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

  def equals?(nil, _), do: false
  def equals?(_, nil), do: false
  def equals?(%__MODULE__{name: n1}, %__MODULE__{name: n2}) when n1 != n2, do: false
  def equals?(%__MODULE__{price: p1}, %__MODULE__{price: p2}) when p1 != p2, do: false
  def equals?(%__MODULE__{quantity: q1}, %__MODULE__{quantity: q2}) when q1 != q2, do: false

  def equals?(%__MODULE__{time_span: ts1}, %__MODULE__{time_span: ts2}) do
    Interval.contains?(ts1, ts2) && Interval.contains?(ts2, ts1)
  end
end
