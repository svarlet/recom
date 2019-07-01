defmodule Recom.Entities.Product do
  use Timex

  defstruct name: "", time_span: nil

  def new(fields \\ []) do
    __struct__(fields)
  end

  def before?(p1, p2) do
    Timex.before?(p1.time_span.from, p2.time_span.from)
  end
end
