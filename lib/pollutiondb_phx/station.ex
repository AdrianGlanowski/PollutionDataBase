defmodule PollutiondbPhx.Station do
  use Ecto.Schema
  require Ecto.Query

  schema "stations" do
      field :name, :string
      field :lon, :float
      field :lat, :float
      has_many :readings, PollutiondbPhx.Reading
  end

  def count_records() do
    PollutiondbPhx.Repo.aggregate(PollutiondbPhx.Station, :count, :id)
  end

  def add(station) do
    PollutiondbPhx.Repo.insert(station)
  end

  def add_all(stations) do
    stations |>
    Enum.map(& add(&1))
  end

  def get_all() do
    PollutiondbPhx.Repo.all(PollutiondbPhx.Station)
  end

  def get_all_with_readings() do
    PollutiondbPhx.Station
    |> PollutiondbPhx.Repo.all()
    |> PollutiondbPhx.Repo.preload(:readings)
  end


  def get_by_id(id) do
    PollutiondbPhx.Repo.get(PollutiondbPhx.Station, id)
  end

  def remove(station) do
    PollutiondbPhx.Repo.delete(station)
  end

  def remove_all() do
    PollutiondbPhx.Station.get_all() |>
    Enum.map(& PollutiondbPhx.Repo.delete(&1))
  end

  def find_by_name(name) do
    PollutiondbPhx.Repo.all(
      Ecto.Query.where(PollutiondbPhx.Station, name: ^name))
      |> PollutiondbPhx.Repo.preload(:readings)
  end

  def find_by_prefix(name) do
    like = "#{name}%"
    PollutiondbPhx.Repo.all(
      Ecto.Query.from(s in PollutiondbPhx.Station,
        where: like(s.name, ^like)))
    |> PollutiondbPhx.Repo.preload(:readings)
  end

  def find_by_location(lon, lat) do
    Ecto.Query.from(s in PollutiondbPhx.Station,
      where: s.lon == ^lon,
      where: s.lat == ^lat)
      |> PollutiondbPhx.Repo.all
  end

  def find_by_location_range(lon_min, lon_max, lat_min, lat_max) do
    Ecto.Query.from(s in PollutiondbPhx.Station,
      where: s.lon >= ^lon_min,
      where: s.lon <= ^lon_max,
      where: s.lat >= ^lat_min,
      where: s.lat <= ^lat_max)
      |> PollutiondbPhx.Repo.all
  end

  defp changeset(station, changesmap) do
    station
    |> Ecto.Changeset.cast(changesmap, [:name, :lon, :lat])  # Przypisuje wartości do odpowiednich pól
    |> Ecto.Changeset.validate_required([:name, :lon, :lat]) # Walidacja, że pola nie mogą być puste
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint([:lon, :lat], name: :stations_lon_lat_index)
    |> Ecto.Changeset.validate_number(:lon, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)  # Współrzędne geograficzne - longitude
    |> Ecto.Changeset.validate_number(:lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)  # Współrzędne geograficzne - latitude
  end

  # Funkcja do aktualizacji nazwy stacji
  def update_name(station, newname) do
    changeset(station, %{name: newname})
    |> PollutiondbPhx.Repo.update
  end

  # Funkcja dodawania nowej stacji
  def add(name, lon, lat) do
    %PollutiondbPhx.Station{}
    |> changeset(%{name: name, lon: lon, lat: lat})  # Użycie wspólnej funkcji changeset
    |> PollutiondbPhx.Repo.insert
  end

end