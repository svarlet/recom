defmodule Recom.NotificationTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product
  alias Recom.Notification

  describe "send/1" do
    test "given a product, it returns :ok" do
      product =
        Product.new(
          name: "Kitchen Roll x4",
          price: 599,
          quantity: 500,
          time_span: Interval.new(from: ~U[2015-01-01 14:00:00.000000Z], until: [years: 1])
        )

      assert :ok == Notification.send(product)
    end
  end
end
