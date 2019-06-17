defmodule Entities.ProductTest do
  use ExUnit.Case, async: true
  use Timex

  alias Entities.Product

  describe "new/0" do
    test "returns a product with an empty name" do
      assert %Product{name: ""} = Product.new()
    end

    test "returns a product with a nil time span" do
      assert %Product{time_span: nil} = Product.new()
    end
  end

  describe "new/1" do
    test "given a keyword list with a name key then a product with the associated name value is returned" do
      name = "irrelevant name"
      assert %Product{name: ^name} = Product.new(name: name)
    end

    test "given a keyword list with a time_span property then a product with the associated time span is returned" do
      time_span = Interval.new(from: Timex.now(), until: [days: 2])
      assert %Product{time_span: ^time_span} = Product.new(time_span: time_span)
    end
  end

  describe "purchasable?/2" do
    test "given a product and an instant prior to the product time span, it returns true" do
      instant = Timex.now()
      later_time_span = Interval.new(from: Timex.shift(instant, days: 3), until: [days: 1])
      p = Product.new(name: "irrelevant product name", time_span: later_time_span)
      assert Product.purchasable?(p, instant)
    end

    test "given a product with a time span overlapping the instant, it returns true" do
      now = Timex.now()
      overlapping_time_span = Interval.new(
        from: Timex.shift(now, minutes: -10),
        until: Timex.shift(now, minutes: +10))
      live_product = Product.new(name: "irrelevant product name", time_span: overlapping_time_span)
      assert Product.purchasable?(live_product, now)
    end

    test "given a product and an instant after the product time span, it returns false" do
      now = Timex.now()
      past_time_span = Interval.new(
        from: Timex.shift(now, weeks: -2),
        until: Timex.shift(now, weeks: -2, hours: 10))
      past_product = Product.new(name: "irrelevant product name", time_span: past_time_span)
      refute Product.purchasable?(past_product, now)
    end
  end
end
