defmodule Recom.Repo.Migrations.AddPriceAndQuantityToProduct do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add(:price, :integer, null: false, default: 0)
      add(:quantity, :integer, null: false, default: 0)
    end
  end
end
