defmodule Storage.PurchasablesGateway.DbAdapter do
  @behaviour Usecases.Shopper.PurchasablesGateway

  use Timex

  import Ecto.Query

  alias Storage.Product
  alias Storage.PurchasablesGateway.DataMapper

  @impl true
  def all(instant) do
    purchasables =
      from(p in Product, where: p.end > ^instant)
      |> Storage.Repo.all()
      |> Enum.map(&DataMapper.convert/1)
    {:ok, purchasables}
  end
end
