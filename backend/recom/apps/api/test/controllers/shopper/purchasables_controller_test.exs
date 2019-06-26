defmodule Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true

  alias Api.Shopper.PurchasablesController

  test "it returns a %Plug.Conn{}" do
    defmodule UsecaseMock do
      def list_purchasables(_instant) do
        purchasables = []
        {:ok, purchasables}
      end
    end

    irrelevant_conn = Plug.Test.conn(:get, "/purchasables")
    instant = Timex.now()
    assert %Plug.Conn{} = PurchasablesController.list(irrelevant_conn,
      at: instant,
      with_usecase: UsecaseMock)
  end
end
