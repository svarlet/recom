defmodule Storage.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :start, :utc_datetime
      add :end, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:name], name: "unique_product_name_index")
  end
end
