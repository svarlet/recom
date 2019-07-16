defmodule Recom.Api.Shopkeeper.PayloadScannerPlugTest do
  use ExUnit.Case, async: true
  use Timex

  import Plug.Test, only: [conn: 3]

  alias Recom.Api.Shopkeeper.PayloadScannerPlug
  alias Recom.Entities.Product

  defmodule Scanner.AlwaysFailing do
    @behaviour Recom.Api.Shopkeeper.PayloadScannerPlug

    def scan(_payload), do: {:error, "Invalid payload schema"}
  end

  describe "given a request, when the payload is not successfully scanned" do
    setup do
      [
        response:
          conn(:post, "/irrelevant_path", %{"bad" => "schema"})
          |> PayloadScannerPlug.call(scanner: Scanner.AlwaysFailing)
      ]
    end

    test "it sends a response", context do
      assert context.response.state == :sent
    end

    test "it sets the status of the reponse to 422", context do
      assert context.response.state == :sent
    end

    test "it sets the content-type to application/json", context do
      assert Plug.Conn.get_resp_header(context.response, "content-type") == ["application/json"]
    end

    # SMELL "and" in a test may mean multiple responsibilities and is an invitation to refactor. Here we could extract a module to hold the responsibility of formatting errors into json
    test "it converts the error provided by the scanner into a json document and sets the response body with it",
         context do
      assert context.response.resp_body == ~S[{"message":"Invalid payload schema"}]
    end
  end

  defmodule Scanner.AlwaysSucceeding do
    alias Recom.Entities.Product

    @behaviour Recom.Api.Shopkeeper.PayloadScannerPlug

    def payload() do
      %{
        "name" => "Orange Juice 2L",
        "price" => 1200,
        "quantity" => 100_000,
        "from" => ~U[2019-12-12 14:00:00.000000Z],
        "end" => ~U[2019-12-14 14:00:00.000000Z]
      }
    end

    def result() do
      %Product{
        name: "Orange Juice 2L",
        price: 1200,
        quantity: 100_000,
        time_span:
          Interval.new(
            from: ~U[2019-12-12 14:00:00.000000Z],
            until: ~U[2019-12-14 14:00:00.000000Z]
          )
      }
    end

    def scan(_payload), do: {:ok, result()}
  end

  describe "given a request, when the payload matches the schema" do
    setup do
      [
        conn:
          conn(:post, "/irrelevant_path", Scanner.AlwaysSucceeding.payload())
          |> PayloadScannerPlug.call(scanner: Scanner.AlwaysSucceeding)
      ]
    end

    test "it doesn't send the response", context do
      assert context.conn.state != :sent
    end

    test "it saves the scanner result into conn.private", context do
      assert context.conn.private.scanner.result == Scanner.AlwaysSucceeding.result()
    end
  end
end
