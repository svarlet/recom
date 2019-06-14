defmodule Recom.Entities do
  defmodule Product do
    defstruct code: ""

    def new() do
      __struct__()
    end
  end
end
