defmodule Entities do
  defmodule Product do
    use Timex

    defstruct name: "", time_span: nil

    def new(fields \\ []) do
      __struct__(fields)
    end

    def before?(_, _) do
      false
    end
  end
end
