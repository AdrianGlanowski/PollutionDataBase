defmodule PollutiondbPhxWeb.ReadingLive do
  use PollutiondbPhxWeb, :live_view
  require Ecto.Query

  alias PollutiondbPhx.Station
  alias PollutiondbPhx.Reading

  def mount(_params, _session, socket) do
    socket = assign(socket, readings: Reading.find_by_date(Date.utc_today) |> Enum.take(10), stations: Station.get_all(), station_name: "", type: "", value: "", date: Date.utc_today)
    {:ok, socket}
  end


  def recent_readings() do
    Ecto.Query.from(r in PollutiondbPhx.Reading, limit: 10, order_by: [desc: r.date, desc: r.time])
    |> PollutiondbPhx.Repo.all()
    |> PollutiondbPhx.Repo.preload(:station)
  end

  def to_float(number, default) do
    case Float.parse(number) do
      {num, _} -> num
      _ -> default
    end
  end

  def handle_event("insert", %{"station_name" => station_name, "type" => type, "value" => value}, socket) do
    Reading.add_now(station_name, type, to_float(value, 0.0))
    socket = assign(socket, readings: recent_readings())
    {:noreply, socket}
  end

  def handle_event("find_by_date", %{"date" => date}, socket) do
    socket = case date do
      "" -> assign(socket, readings: recent_readings())
      _ -> assign(socket, readings: Reading.find_by_date(date) |> Enum.take(10))
    end
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    Add new reading
    <form phx-submit="insert">
      <select name="station_name">
        <%= for station <- @stations do %>
          <option label={station.name} value={station.name} selected={station.name == @station_name} />
        <% end %>
      </select><br/>

      Type: <input type="text" name="type" value={@type} /><br/>
      Value: <input type="number" step="0.1" name="value" value={@value} /><br/>
      <input type="submit">
    </form>

    Find by date
    <form phx-change="find_by_date">
      <input type="date" name="date" value={@date} /><br/>
    </form>

    <table>
      <tr>
        <th>Station name</th><th>Date</th><th>Time</th><th>Type</th><th>Value</th>
      </tr>
      <%= for reading <- @readings do %>
        <tr>
          <td><%= reading.station.name %></td>
          <td><%= reading.date %></td>
          <td><%= reading.time %></td>
          <td><%= reading.type %></td>
          <td><%= reading.value %></td>
        </tr>
      <% end %>
    </table>

    """
  end
end