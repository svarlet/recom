defmodule Usecases.Shopper.ListProductsTest do
  use ExUnit.Case, async: true
  use Timex

  import Usecases.Shopper.ListProducts

  alias Entities.Product

  setup do
    duration = [days: 3, hours: 8]

    p1 = Product.new(name: "M2020 EU 2018 Regular Pass",
      time_span: Interval.new(from: ~N[2018-05-31 09:00:00], until: duration))

    p2 = Product.new(name: "M2020 EU 2019 Regular Pass",
      time_span: Interval.new(from: ~N[2019-06-02 09:00:00], until: duration))

    p3 = Product.new(name: "M2020 EU 2019 VIP Pass",
      time_span: Interval.new(from: ~N[2019-06-02 09:00:00], until: duration))

    p4 = Product.new(name: "M2020 EU 2020 Regular Pass",
      time_span: Interval.new(from: ~N[2020-07-02 09:00:00], until: duration))

    %{products: [p1, p2, p3, p4], p1: p1, p2: p2, p3: p3, p4: p4}
  end

  test "it returns [] when no products are available at the specified instant", context do
    instant_after_last_scheduled_event = ~N[2052-06-05 17:01:00]
    assert [] == list_products(context.products, instant_after_last_scheduled_event)
  end

  test "it returns the products scheduled in the future", context do
    instant_before_some_scheduled_products = ~N[2020-04-14 14:00:00]
    upcoming_products = list_products(context.products, instant_before_some_scheduled_products)
    assert [context.p4] == upcoming_products
  end

  test "it returns the products spanning over the instant", context do
    instant_within_scheduled_products = ~N[2019-06-03 16:00:00]
    upcoming_products = list_products(context.products, instant_within_scheduled_products)
    assert [context.p2, context.p3, context.p4] == upcoming_products
  end
end
