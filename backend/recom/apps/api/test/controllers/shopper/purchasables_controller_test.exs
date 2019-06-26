defmodule Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true

  alias Api.Shopper.PurchasablesController

  setup_all do
    %{conn: Plug.Test.conn(:get, "/purchasables"),
      instant: Timex.now()}
  end

  # Collaboration tests

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

  # Contract tests

  describe "given that there are no purchasables at the specified instant" do
    defmodule UsecaseStub_NoPurchasables do
      def list_purchasables(_instant), do: {:ok, []}
    end

    setup context do
      response = PurchasablesController.list(context.conn,
        at: context.instant,
        with_usecase: UsecaseStub_NoPurchasables)

      %{response: response}
    end

    test "then it responds with a 200 status", context do
      assert %Plug.Conn{status: 200} = context.response
    end

    test "then it responds with a json content type", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "then it responds with a valid json document", context do
      {:ok, document} = Jason.decode(context.response.resp_body, keys: :atoms)
      assert document.purchasables == []
    end
  end

  describe "given that some purchasables are available at the specified time" do
    defmodule UsecaseStub_SomePurchasables do
      alias Entities.Product

      @tomorrow Timex.shift(Timex.now(), days: 1)
      @next_week Timex.shift(Timex.now(), week: 1)
      @some_purchasables [
        Product.new(name: "Apple Pie", time_span: Timex.Interval.new(from: @tomorrow, until: @next_week)),
        Product.new(name: "Almond milk", time_span: Timex.Interval.new(from: @tomorrow, until: @next_week)),
      ]

      def list_purchasables(_instant), do: {:ok, @some_purchasables}
    end

    setup context do
      response = PurchasablesController.list(context.conn,
        at: context.instant,
        with_usecase: UsecaseStub_SomePurchasables)

      %{response: response}
    end

    test "then it responds with a 200 status", context do
      assert %Plug.Conn{status: 200} = context.response
    end
  end

end
