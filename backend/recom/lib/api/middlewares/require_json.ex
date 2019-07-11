defmodule Recom.Middlewares.RequireJson do
  @behaviour Plug

  import Plug.Conn, only: [send_resp: 3]

  def init(_) do
    nil
  end

  def call(conn, _) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn),
         {:ok, object} <- Jason.decode(body) do
      %Plug.Conn{conn | body_params: object}
    else
      {:error, _} ->
        send_resp(conn, 400, ~s"""
        {
          "message": "JSON parsing error"
        }
        """)
    end
  end
end
