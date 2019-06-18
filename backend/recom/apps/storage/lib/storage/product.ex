defmodule Storage.Product do
  use Ecto.Schema

  schema "products" do
    field :name, :string
    field :start, :utc_datetime_usec
    field :end, :utc_datetime_usec

    timestamps type: :utc_datetime_usec
  end
end

defmodule Storage.PurchasablesGateway.Adapters.DbGateway do
  @behaviour Usecases.Shopper.PurchasablesGateway

  use Timex

  import Ecto.Query

  alias Storage.Product

  @impl true
  def all(instant) do
    purchasables =
      from(p in Product, where: p.start >= ^instant)
      |> Storage.Repo.all()
      |> Enum.map(&to_entity/1)
    {:ok, purchasables}
  end

  defp to_entity(%Product{name: name, start: start, end: the_end}) do
    Entities.Product.new(
      name: name,
      time_span: Interval.new(from: start, until: the_end))
  end
end
