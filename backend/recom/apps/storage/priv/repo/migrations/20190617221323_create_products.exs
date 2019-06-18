defmodule Storage.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :start, :utc_datetime_usec
      add :end, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:products, [:name], name: "unique_product_name_index")
  end
end
