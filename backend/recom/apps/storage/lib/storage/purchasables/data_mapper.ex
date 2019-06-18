defmodule Storage.PurchasablesGateway.DataMapper do
  use Timex

  def convert(%Storage.Product{name: name, start: start, end: the_end}) do
    Entities.Product.new(
      name: name,
      time_span: Interval.new(from: start, until: the_end))
  end
end
