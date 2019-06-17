defmodule Entities do
  defmodule Product do
    defstruct start: nil, end: nil, name: "", time_span: nil

    def new(fields \\ []) do
      __struct__(fields)
    end
  end
end
