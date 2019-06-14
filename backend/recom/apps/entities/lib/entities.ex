defmodule Recom.Entities do
  defmodule Product do
    defstruct start: nil, end: nil

    def new() do
      __struct__()
    end
  end
end
