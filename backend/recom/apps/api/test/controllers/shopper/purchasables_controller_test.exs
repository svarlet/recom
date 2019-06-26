defmodule Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true

  alias Api.Shopper.PurchasablesController

  setup do
    %{conn: Plug.Test.conn(:get, "/purchasables"),
      instant: Timex.now()}
  end

  test "it returns a %Plug.Conn{}", context do
    defmodule UsecaseMock do
      def list_purchasables(_instant) do
        purchasables = []
        {:ok, purchasables}
      end
    end

    assert %Plug.Conn{} = PurchasablesController.list(context.conn,
      at: context.instant,
      with_usecase: UsecaseMock)
  end

  test "the controller request the purchasables for the specified instant", context do
    defmodule UsecaseSpy do
      def list_purchasables(instant) do
        send(self(), {:instant, instant})
        purchasables = []
        {:ok, purchasables}
      end
    end

    PurchasablesController.list(context.conn,
      at: context.instant,
      with_usecase: UsecaseSpy)

    assert_received {:instant, instant}
    assert instant == context.instant
  end

  describe "given that there are no purchasables at the specified instant" do
    test "then it responds with a 200 status", context do
      defmodule UsecaseStub_NoPurchasables do
        def list_purchasables(instant), do: {:ok, []}
      end
      conn = PurchasablesController.list(context.conn,
        at: context.instant,
        with_usecase: UsecaseStub_NoPurchasables)
      assert conn.status == 200
    end
  end
end
