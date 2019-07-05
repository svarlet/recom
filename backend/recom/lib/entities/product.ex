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
end
