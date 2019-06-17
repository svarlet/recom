defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true

  import Usecases.Shopper.ListProducts

  alias Entities.Product

  test "it returns [] when no products are available at the specified instant" do
    products = [
      Product.new(name: "M2020 EU 2018 Regular Pass",
        start: ~N[2018-05-31 09:00:00],
        end: ~N[2018-06-02 17:00:00]),
      Product.new(name: "M2020 EU 2019 Regular Pass",
        start: ~N[2019-06-02 09:00:00],
        end: ~N[2019-06-05 17:00:00]),
      Product.new(name: "M2020 EU 2019 VIP Pass",
        start: ~N[2019-06-02 09:00:00],
        end: ~N[2019-06-05 17:00:00])
    ]
    instant_after_last_scheduled_event = ~N[2019-06-05 17:01:00]
    assert [] == list_products(products, instant_after_last_scheduled_event)
  end

  test "it returns the products scheduled in the future" do
    p1 = Product.new(name: "M2020 EU 2018 Regular Pass",
      start: ~N[2018-05-31 09:00:00],
      end: ~N[2018-06-02 17:00:00])
    p2 = Product.new(name: "M2020 EU 2019 Regular Pass",
      start: ~N[2019-06-02 09:00:00],
      end: ~N[2019-06-05 17:00:00])
    p3 = Product.new(name: "M2020 EU 2019 VIP Pass",
      start: ~N[2019-06-02 09:00:00],
      end: ~N[2019-06-05 17:00:00])
    products = [p1, p2, p3]
    instant_before_some_scheduled_products = ~N[2019-04-14 14:00:00]
    upcoming_products = list_products(products, instant_before_some_scheduled_products)
    assert p2 in upcoming_products
    assert p3 in upcoming_products
  end
end
