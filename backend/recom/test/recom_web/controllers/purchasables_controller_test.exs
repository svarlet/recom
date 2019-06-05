defmodule RecomWeb.PurchasableControllerTest do
  use RecomWeb.ConnCase

  describe "a request to list the purchasables" do
    test "responds with a JSON document", %{conn: conn} do
      response =
        conn
        |> get(Routes.purchasables_path(conn, :list, "m2020eu19"))
      assert json_response(response, 200)
    end
  end
end
