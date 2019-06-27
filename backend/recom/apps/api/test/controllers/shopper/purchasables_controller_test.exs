defmodule Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true

  alias Api.Shopper.PurchasablesController
  alias Entities.Product


  @instant Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")

  setup_all do
    %{conn: Plug.Test.conn(:get, "/purchasables"),
      instant: @instant}
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
      assert %Plug.Conn{status: 200, state: :sent} = context.response
    end

    test "then it responds with a json content type", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "then it responds with a valid json document", context do
      {:ok, document} = Jason.decode(context.response.resp_body, keys: :atoms)
      assert document.purchasables == []
      assert document.instant == "2019-02-15T15:07:39Z"
    end
  end

  describe "given that some purchasables are available at the specified time" do
    defmodule UsecaseStub_SomePurchasables do
      @instant Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")
      @next_day Timex.shift(@instant, days: 1)
      @next_week Timex.shift(@instant, weeks: 1)

      @some_purchasables [
        Product.new(name: "Apple Pie", time_span: Timex.Interval.new(from: @next_day, until: @next_week)),
        Product.new(name: "Almond milk", time_span: Timex.Interval.new(from: @next_day, until: @next_week)),
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
      assert %Plug.Conn{status: 200, state: :sent} = context.response
    end

    test "then it responds with a json ccontent type", context do
      assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
    end

    test "then it responds with a valid json document", context do
      {:ok, document} = Jason.decode(context.response.resp_body, keys: :atoms)
      assert document.purchasables == [
        %{name: "Apple Pie", time_span: %{from: "2019-02-16T15:07:39Z", until: "2019-02-22T15:07:39Z"}},
        %{name: "Almond milk", time_span: %{from: "2019-02-16T15:07:39Z", until: "2019-02-22T15:07:39Z"}},
      ]
      assert document.instant == "2019-02-15T15:07:39Z"
    end
  end
end
