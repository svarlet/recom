defmodule Entities do
  defmodule Product do
    use Timex

    defstruct start: nil, end: nil, name: "", time_span: nil

    def new(fields \\ []) do
      __struct__(fields)
    end

    def purchasable?(product, instant) do
      Timex.before?(instant, product.time_span.until)
    end
  end
end
