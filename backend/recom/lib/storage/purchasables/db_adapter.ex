defmodule Recom.Storage.PurchasablesGateway.DbAdapter do
  @behaviour Recom.Usecases.Shopper.PurchasablesGateway
  @behaviour Recom.Usecases.Shopkeeper.ProductsGateway

  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DataMapper
  alias Ecto.Changeset

  @impl true
  def all(instant) do
    try do
      purchasables =
        from(p in Storage.Product, where: p.end > ^instant)
        |> Repo.all()
        |> Enum.map(&DataMapper.convert/1)

      {:ok, purchasables}
    rescue
      _ -> :error
    end
  end

  @impl true
  def store(product) do
    record_properties = %{
      name: product.name,
      price: product.price,
      quantity: product.quantity,
      start: Timex.to_datetime(product.time_span.from, "Etc/UTC"),
      end: Timex.to_datetime(product.time_span.until, "Etc/UTC")
    }

    %Storage.Product{}
    |> Storage.Product.changeset(record_properties)
    |> Repo.insert()
    |> case do
      {:ok, saved_product} ->
        {:ok, DataMapper.convert(saved_product)}

      {:error, %Changeset{errors: errors}} ->
        if Enum.any?(errors, fn {:name, {_, [{:constraint, :unique} | _]}} -> true end) do
          {:error, :duplicate_product}
        end
    end
  end
end
