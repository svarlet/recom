defmodule Recom.Storage.PurchasablesGateway.DataMapper do
  use Timex

  alias Recom.{Entities, Storage}

  def convert(%Storage.Product{
        name: name,
        start: start,
        end: the_end,
        price: price,
        quantity: quantity
      }) do
    Entities.Product.new(
      name: name,
      price: price,
      quantity: quantity,
      time_span: Interval.new(from: start, until: the_end)
    )
  end
end
