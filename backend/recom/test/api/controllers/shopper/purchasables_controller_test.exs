defmodule Recom.Api.Shopper.PurchasablesControllerTest do
  use ExUnit.Case, async: true
  use Timex

  import Timex, only: [shift: 2]
  import Mox

  alias Recom.Api.Shopper.PurchasablesController
  alias Recom.Usecases.Shopper.ListPurchasables
  alias Recom.Entities.Product

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
    setup context do
      products = context[:products] || []
      stub(ListPurchasables.Mock, :list_purchasables, fn _ -> {:ok, products} end)
      context
    end

    defp get_purchasables(conn) do
      conn
      |> PurchasablesController.list(at: @instant, with_usecase: ListPurchasables.Mock)
      |> Map.get(:resp_body)
      |> Jason.decode!(keys: :atoms)
    end

    test "it adds the instant to the response body", context do
      assert get_purchasables(context.conn).instant == "2019-02-15T15:07:39Z"
    end

    test "when the list is empty then it sets the purchasables key to []", context do
      assert get_purchasables(context.conn).purchasables == []
    end

    @tag products: [
      Product.new(name: "carrots", time_span: Interval.new(from: shift(@instant, days: -2), until: [days: 12])),
      Product.new(name: "apples", time_span: Interval.new(from: shift(@instant, days: -1), until: [days: 7]))
    ]
    test "when the list is not empty then the order is conserved", context do
      assert get_purchasables(context.conn).purchasables == [
        %{name: "carrots", time_span: %{from: "2019-02-13T15:07:39Z", until: "2019-02-25T15:07:39Z"}},
        %{name: "apples", time_span: %{from: "2019-02-14T15:07:39Z", until: "2019-02-21T15:07:39Z"}}
      ]
    end

    test "it sends a response with the status set to 200", context do
      response = PurchasablesController.list(context.conn, at: @instant, with_usecase: ListPurchasables.Mock)
      assert %Plug.Conn{status: 200, state: :sent} = response
    end

    test "it sets the content-type header to application/json", context do
      assert ["application/json"] ==
        context.conn
        |> PurchasablesController.list(at: @instant, with_usecase: ListPurchasables.Mock)
        |> Plug.Conn.get_resp_header("content-type")
    end
  end

  describe "given the usecase returns an error" do
    test "it responds with a 500", context do
      stub(ListPurchasables.Mock, :list_purchasables, fn _ -> :error end)
      response = PurchasablesController.list(context.conn, at: @instant, with_usecase: ListPurchasables.Mock)
      assert %Plug.Conn{state: :sent, status: 500} = response
    end
  end
end
