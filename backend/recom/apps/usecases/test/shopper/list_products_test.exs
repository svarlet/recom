defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true

  import Usecases.Shopper.ListProducts

  alias Entities.Product

  test "it returns [] when no products are available at the specified instant" do
    products = [
      Product.new(name: "M2020 EU 2018 Regular Pass", start: ~N[2018-05-31 09:00:00], end: ~N[2019-06-02 17:00:00]),
      Product.new(name: "M2020 EU 2019 Regular Pass", start: ~N[2019-06-02 09:00:00], end: ~N[2019-06-05 17:00:00]),
      Product.new(name: "M2020 EU 2019 VIP Pass", start: ~N[2019-06-02 09:00:00], end: ~N[2019-06-05 17:00:00])
    ]
    instant_after_last_scheduled_event = ~N[2019-06-05 17:01:00]
    assert [] == list_products(products, instant_after_last_scheduled_event)
  end
end
