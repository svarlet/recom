defmodule Recom.Storage.PurchasablesGateway.DbAdapter do
  # TODO: split this module, move store/1 to a ProductGateway otherwise it's confusing
  @behaviour Recom.Usecases.Shopper.PurchasablesGateway
  @behaviour Recom.Usecases.Shopkeeper.ProductsGateway

  use Timex

  import Ecto.Query

  alias Recom.Repo
  alias Recom.Storage
  alias Recom.Storage.PurchasablesGateway.DataMapper

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

    try do
      %Storage.Product{}
      |> Storage.Product.changeset(record_properties)
      |> Repo.insert()
      |> case do
        {:ok, saved_product} ->
          {:ok, DataMapper.convert(saved_product)}

        {:error, changeset} ->
          if unique_constraint_violation?(changeset, on: :name) do
            {:error, :duplicate_product}
          end
      end
    rescue
      _ -> :error
    end
  end

  defp unique_constraint_violation?(changeset, on: key) do
    Enum.any?(changeset.errors, fn {^key, {_, [{:constraint, :unique} | _]}} -> true end)
  end
end
