defimpl Jason.Encoder, for: Entities.Product do
  require Jason.Helpers

  def encode(product, _opts) do
    product
    |> Jason.Helpers.json_map_take(~w(name time_span)a)
    |> Jason.encode!
  end
end

defimpl Jason.Encoder, for: Timex.Interval do
  require Jason.Helpers

  def encode(%Timex.Interval{from: from, until: until}, _opts) do
    from_as_datetime = Timex.to_datetime(from)
    until_as_datetime = Timex.to_datetime(until)
    Jason.Helpers.json_map(from: from_as_datetime, until: until_as_datetime)
    |> Jason.encode!
  end
end
