defmodule Entities do
  defmodule Product do
    defstruct start: nil, end: nil, name: ""

    def new(fields \\ []) do
      __struct__(fields)
    end
  end
end
