defmodule Recom.Api.Shopkeeper.CreateProduct.Controller_OriginalProductTest do
  use ExUnit.Case, async: true
  use Timex

  import Mox
  import Plug.Test, only: [conn: 3]

  setup :verify_on_exit!

  alias Recom.Api.Shopkeeper.CreateProduct.Controller
  alias Recom.Api.Shopkeeper.CreateProduct.Presenter
  alias Recom.Api.Shopkeeper.CreateProduct.PayloadScanner
  alias Recom.Usecases.Shopkeeper.CreateProduct
  alias Recom.Entities.Product

  defp http_request(with_payload: payload), do: conn(:post, "/create_product", payload)

  setup do
    payload = %{
      "name" => "irrelevant",
      "price" => 1,
      "quantity" => 1,
      "from" => "2019-01-31T13:00:00.000000Z",
      "end" => "2019-02-01T13:00:00.000000Z"
    }

    product = %Product{
      name: "irrelevant",
      price: 1,
      quantity: 1,
      time_span: Interval.new(from: ~U[2019-01-31 13:00:00.000000Z], until: [days: 1])
    }

    stub(PayloadScanner.Stub, :scan, fn _ -> product end)
    expect(CreateProduct.Double, :create, fn ^product -> :ok end)
    stub(Presenter.Stub, :present, fn _ -> "empty body" end)

    [
      response:
        http_request(with_payload: payload)
        |> Controller.create_product(
          with_scanner: PayloadScanner.Stub,
          with_usecase: CreateProduct.Double,
          with_presenter: Presenter.Stub
        )
    ]
  end

  test "it sends a response", context do
    assert context.response.state == :sent
  end

  test "it sets the response status to 201", context do
    assert context.response.status == 201
  end

  test "it delegates the creation of the response body to the presenter", context do
    assert context.response.resp_body == "empty body"
  end
end
