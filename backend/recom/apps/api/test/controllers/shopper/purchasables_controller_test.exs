defmodule Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true

  import Mox

  alias Api.Shopper.PurchasablesController
  alias Usecases.Shopper.ListPurchasables
  alias Entities.Product

  @instant Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")

  defmock ListPurchasables.Mock, for: ListPurchasables.Behaviour

  setup_all do
    %{conn: Plug.Test.conn(:get, "/purchasables"),
      instant: @instant}
  end

  setup :verify_on_exit!

  #
  # Collaboration tests
  #

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

  #
  # Contract tests
  #

  describe "given the usecase returns a list of purchasables" do
    defp get_purchasables(conn) do
      conn
      |> PurchasablesController.list(at: @instant, with_usecase: ListPurchasables.Mock)
      |> Map.get(:resp_body)
      |> Jason.decode!(keys: :atoms)
    end

    test "it adds the instant to the response body", context do
      stub(ListPurchasables.Mock, :list_purchasables, fn _ -> {:ok, []} end)
      assert get_purchasables(context.conn).instant == "2019-02-15T15:07:39Z"
    end

    test "when the list is empty then it sets the purchasables key to []", context do
      stub(ListPurchasables.Mock, :list_purchasables, fn _ -> {:ok, []} end)
      assert get_purchasables(context.conn).purchasables == []
    end

    test "when the list is not empty then the order is conserved", context do
      products = [
        Product.new(name: "carrots", time_span: Timex.Interval.new(from: Timex.shift(@instant, days: -2), until: [days: 12])),
        Product.new(name: "apples", time_span: Timex.Interval.new(from: Timex.shift(@instant, days: -1), until: [days: 7]))
      ]
      stub(ListPurchasables.Mock, :list_purchasables, fn _ -> {:ok, products} end)
      assert get_purchasables(context.conn).purchasables == [
        %{name: "carrots", time_span: %{from: "2019-02-13T15:07:39Z", until: "2019-02-25T15:07:39Z"}},
        %{name: "apples", time_span: %{from: "2019-02-14T15:07:39Z", until: "2019-02-21T15:07:39Z"}}
      ]
    end

    test "it sends a response with the status set to 200"

    test "it sets the content-type header to application/json"
  end

  describe "given the usecase returns an error" do
    test "it responds with a 500"

    test "it provides information about the error in a json document"
  end

  # describe "given that there are no purchasables at the specified instant" do
  #   defmodule UsecaseStub_NoPurchasables do
  #     def list_purchasables(_instant), do: {:ok, []}
  #   end

  #   setup context do
  #     response = PurchasablesController.list(context.conn,
  #       at: context.instant,
  #       with_usecase: UsecaseStub_NoPurchasables)

  #     %{response: response}
  #   end

  #   test "then it responds with a 200 status", context do
  #     assert %Plug.Conn{status: 200, state: :sent} = context.response
  #   end

  #   test "then it responds with a json content type", context do
  #     assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
  #   end

  #   test "then it responds with a valid json document", context do
  #     {:ok, document} = Jason.decode(context.response.resp_body, keys: :atoms)
  #     assert document.purchasables == []
  #     assert document.instant == "2019-02-15T15:07:39Z"
  #   end
  # end

  # describe "given that some purchasables are available at the specified time" do
  #   defmodule UsecaseStub_SomePurchasables do
  #     @instant Timex.to_datetime(~N[2019-02-15 15:07:39], "Etc/UTC")
  #     @next_day Timex.shift(@instant, days: 1)
  #     @next_week Timex.shift(@instant, weeks: 1)

  #     @some_purchasables [
  #       Product.new(name: "Apple Pie", time_span: Timex.Interval.new(from: @next_day, until: @next_week)),
  #       Product.new(name: "Almond milk", time_span: Timex.Interval.new(from: @next_day, until: @next_week)),
  #     ]

  #     def list_purchasables(_instant), do: {:ok, @some_purchasables}
  #   end

  #   setup context do
  #     response = PurchasablesController.list(context.conn,
  #       at: context.instant,
  #       with_usecase: UsecaseStub_SomePurchasables)

  #     %{response: response}
  #   end

  #   test "then it responds with a 200 status", context do
  #     assert %Plug.Conn{status: 200, state: :sent} = context.response
  #   end

  #   test "then it responds with a json ccontent type", context do
  #     assert ["application/json"] == Plug.Conn.get_resp_header(context.response, "content-type")
  #   end

  #   test "then it responds with a valid json document", context do
  #     {:ok, document} = Jason.decode(context.response.resp_body, keys: :atoms)
  #     assert document.purchasables == [
  #       %{name: "Apple Pie", time_span: %{from: "2019-02-16T15:07:39Z", until: "2019-02-22T15:07:39Z"}},
  #       %{name: "Almond milk", time_span: %{from: "2019-02-16T15:07:39Z", until: "2019-02-22T15:07:39Z"}},
  #     ]
  #     assert document.instant == "2019-02-15T15:07:39Z"
  #   end
  # end
end
