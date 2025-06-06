defmodule PollutiondbPhx.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations) do
          add :name, :string
          add :lon, :float
          add :lat, :float
    end

    #unique names
    create unique_index(:stations, [:name])

    #unique coordinates
    create unique_index(:stations, [:lon, :lat])
  end
end
