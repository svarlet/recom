defmodule Usecases.Shopper.ListProducts do
  def list_products(products, instant) do
    for p <- products, NaiveDateTime.compare(instant, p.start) == :lt do
      p
    end
  end
end
