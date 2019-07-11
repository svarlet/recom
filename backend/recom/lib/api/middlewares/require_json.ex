defmodule Recom.Middlewares.RequireJson do
  @behaviour Plug

  import Plug.Conn, only: [send_resp: 3]

  def init(_) do
    nil
  end

  def call(conn, _) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    case Jason.decode(body) do
      {:ok, object} ->
        %Plug.Conn{conn | body_params: object}

      {:error, _} ->
        send_resp(conn, 400, ~s"""
        {
          "message": "JSON parsing error"
        }
        """)
    end
  end
end
