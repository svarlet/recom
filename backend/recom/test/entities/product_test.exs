defmodule Recom.Entities.ProductTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Entities.Product

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
    setup do
      now = Timex.now()

      product_sooner =
        Product.new(
          name: "irrelevant",
          time_span:
            Timex.Interval.new(
              from: now,
              until: [days: 1]
            )
        )

      product_later =
        Product.new(
          name: "irrelevant",
          time_span:
            Timex.Interval.new(
              from: Timex.shift(now, hours: 2),
              until: [days: 1]
            )
        )

      %{product_sooner: product_sooner, product_later: product_later}
    end

    test "returns false for 2 identical products", context do
      refute Product.before?(context.product_sooner, context.product_sooner)
    end

    test "returns true when the first product starts before the second product", context do
      assert Product.before?(context.product_sooner, context.product_later)
    end

    test "returns false when the first product starts after the second product", context do
      refute Product.before?(context.product_later, context.product_sooner)
    end
  end

  describe "equals?/2" do
    setup context do
      product = %Product{
        name: "name",
        quantity: 1,
        price: 2,
        time_span: Interval.new(from: Timex.now(), until: [days: 1])
      }

      overrides = Map.take(context, ~w{name quantity price time_span}a)

      different_product = Map.merge(product, overrides)

      %{product: product, different_product: different_product}
    end

    test "when either is nil, return true", context do
      refute Product.equals?(nil, context.product)
      refute Product.equals?(context.product, nil)
    end

    @tag name: "different name"
    test "when names differ, return false", context do
      refute Product.equals?(context.product, context.different_product)
      refute Product.equals?(context.different_product, context.product)
    end

    @tag price: 45
    test "when prices differ, return false", context do
      refute Product.equals?(context.product, context.different_product)
      refute Product.equals?(context.different_product, context.product)
    end

    @tag quantity: 14
    test "when quantities differ, return false", context do
      refute Product.equals?(context.product, context.different_product)
      refute Product.equals?(context.different_product, context.product)
    end

    test "when intervals differ, return false", context do
      different_product = %Product{
        context.product
        | time_span: Interval.new(from: Timex.shift(Timex.now(), days: 1), until: [days: 1])
      }

      refute Product.equals?(context.product, different_product)
      refute Product.equals?(different_product, context.product)
    end

    test "when prices, quantities, names and intervals are equal, return true", context do
      assert Product.equals?(context.product, context.product)
    end
  end
end
