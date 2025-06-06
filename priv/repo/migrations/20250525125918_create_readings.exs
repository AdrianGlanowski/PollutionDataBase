defmodule PollutiondbPhx.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :date, :date
      add :time, :time
      add :type, :string
      add :value, :float

      add :station_id, references(:stations, on_delete: :delete_all)
    end
    create index(:readings, [:station_id])

    create unique_index(:readings, [:date, :time, :type, :station_id])
  end
end
