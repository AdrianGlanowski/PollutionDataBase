defmodule PollutiondbPhx.Reading do
  use Ecto.Schema
  require Ecto.Query

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float
    belongs_to :station, PollutiondbPhx.Station
  end

  def count_records() do
    PollutiondbPhx.Repo.aggregate(PollutiondbPhx.Reading, :count, :id)
  end

  def get_all() do
    PollutiondbPhx.Repo.all(PollutiondbPhx.Reading)
  end

  def remove_all() do
    PollutiondbPhx.Station.get_all() |>Enum.map(& PollutiondbPhx.Repo.delete(&1))
  end

  defp changeset(reading, changesmap) do
    reading
    |> Ecto.Changeset.cast(changesmap, [:date, :time, :type, :value, :station_id])
    |> Ecto.Changeset.validate_required([:date, :time, :type, :value, :station_id])
    |> Ecto.Changeset.unique_constraint([:date, :time, :type, :station_id], name: :readings_date_time_type_station_id_index)
    |> Ecto.Changeset.assoc_constraint(:station)
  end

  def add(station_name, date, time, type, value) do
    station = PollutiondbPhx.Station.find_by_name(station_name) |> hd
    %PollutiondbPhx.Reading{}
    |> changeset(%{date: date, time: time, type: type, value: value, station_id: station.id})
    |> PollutiondbPhx.Repo.insert
  end

  def add_now(station_name, type, value) do
    station = PollutiondbPhx.Station.find_by_name(station_name) |> hd
    %PollutiondbPhx.Reading{}
    |> changeset(%{date: Date.utc_today, time: Time.utc_now, type: type, value: value, station_id: station.id})
    |> PollutiondbPhx.Repo.insert
  end

  def find_by_date(date) do
    PollutiondbPhx.Repo.all(
      Ecto.Query.from(r in PollutiondbPhx.Reading,
      where: r.date == ^date,
      order_by: [desc: r.time],
      preload: [:station]))
  end
end