defmodule Recom.SmokeTests.RejectNonJsonRequestsTest do
  use ExUnit.Case, async: false

  @moduletag :smoke

  test "it rejects a requests with a malformed json body" do
    {:ok, response} =
      HTTPoison.post(
        "https://localhost:4001/irrelevant_path",
        "{",
        [
          {"content-type", "application/json"}
        ],
        hackney: [:insecure]
      )

    assert response.status_code == 400
    assert {"content-type", "application/json"} in response.headers
    assert Jason.decode!(response.body) == %{"message" => "Malformed JSON"}
  end
end
