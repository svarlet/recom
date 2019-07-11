defmodule Recom.Middlewares.RequireJson do
  @behaviour Plug

  import Plug.Conn, only: [send_resp: 3]

  def init(_) do
    nil
  end

  def call(conn, _) do
    send_resp(conn, 400, ~s"""
    {
      "message": "JSON parsing error"
    }
    """)
  end
end
