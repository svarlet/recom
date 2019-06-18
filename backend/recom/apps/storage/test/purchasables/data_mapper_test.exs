defmodule Storage.PurchasablesGateway.DataMapperTest do
  use ExUnit.Case, async: true
  use Timex

  alias Storage.PurchasablesGateway.DataMapper

  test "converts a Product schema into a Product entity" do
    start = Timex.now()
    the_end = Timex.shift(start, hours: 1)
    schema = %Storage.Product{name: "the name", start: start, end: the_end}
    entity = %Entities.Product{name: "the name", time_span: Interval.new(from: start, until: the_end)}
    assert entity == DataMapper.convert(schema)
  end
end
