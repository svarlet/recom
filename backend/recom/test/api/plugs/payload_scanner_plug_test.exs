defmodule Recom.Api.PayloadScannerPlugTest do
  use ExUnit.Case, async: true
  use Timex

  import Plug.Test, only: [conn: 3]
  import Mox

  alias Recom.Api.PayloadScannerPlug

  defmock(Scanner.Stub, for: PayloadScannerPlug)

  describe "given a request, when the payload is not successfully scanned" do
    setup do
      stub(Scanner.Stub, :scan, fn _ -> {:error, "Invalid payload schema"} end)

      [
        response:
          conn(:post, "/irrelevant_path", %{"bad" => "schema"})
          |> PayloadScannerPlug.call(scanner: Scanner.Stub)
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

  describe "given a request, when the payload matches the schema" do
    setup do
      valid_payload = %{}
      stub(Scanner.Stub, :scan, fn _ -> {:ok, :__scanned_item__} end)

      [
        conn:
          conn(:post, "/irrelevant_path", valid_payload)
          |> PayloadScannerPlug.call(scanner: Scanner.Stub)
      ]
    end

    test "it doesn't send the response", context do
      assert context.conn.state != :sent
    end

    test "it saves the scanner result into conn.private", context do
      assert context.conn.private.scanner.result == :__scanned_item__
    end
  end
end
