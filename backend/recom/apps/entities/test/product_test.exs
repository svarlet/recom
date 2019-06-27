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

  describe "before?/2" do
    test "returns false for 2 identical products" do
      product = Product.new(
        name: "irrelevant",
        time_span: Timex.Interval.new(
          from: Timex.now(),
          until: [days: 1]))
      refute Product.before?(product, product)
    end

    test "returns true when the first product starts before the second product" do
      now = Timex.now()
      product_sooner = Product.new(
        name: "irrelevant",
        time_span: Timex.Interval.new(
          from: now,
          until: [days: 1]))
      product_later = Product.new(
        name: "irrelevant",
        time_span: Timex.Interval.new(
          from: Timex.shift(now, hours: 2),
          until: [days: 1]))
      assert Product.before?(product_sooner, product_later)
    end

    test "returns false when the first product starts after the second product" do
      now = Timex.now()
      product_sooner = Product.new(
        name: "irrelevant",
        time_span: Timex.Interval.new(
          from: now,
          until: [days: 1]))
      product_later = Product.new(
        name: "irrelevant",
        time_span: Timex.Interval.new(
          from: Timex.shift(now, hours: 2),
          until: [days: 1]))
      refute Product.before?(product_later, product_sooner)
    end
  end
end
