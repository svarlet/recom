defmodule Recom.Entities do
  defmodule Product do
    defstruct code: "", start: nil

    def new() do
      __struct__()
    end
  end
end
