defmodule Recom.Storage.PurchasablesGateway.DataMapperTest do
  use ExUnit.Case, async: true
  use Timex

  alias Recom.Storage.PurchasablesGateway.DataMapper
  alias Recom.{Storage, Entities}

  test "converts a Product schema into a Product entity" do
    start = Timex.now()
    the_end = Timex.shift(start, hours: 1)

    schema = %Storage.Product{
      name: "the name",
      start: start,
      end: the_end,
      price: 123,
      quantity: 345
    }

    entity = %Entities.Product{
      name: "the name",
      time_span: Interval.new(from: start, until: the_end),
      price: 123,
      quantity: 345
    }

    assert entity == DataMapper.convert(schema)
  end
end
