defmodule RecomWeb.PageController do
  use RecomWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
