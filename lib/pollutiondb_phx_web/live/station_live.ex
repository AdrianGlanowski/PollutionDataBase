defmodule PollutiondbPhxWeb.StationLive do
  use PollutiondbPhxWeb, :live_view

  alias PollutiondbPhx.Station

  def to_float(number, default) do
    case Float.parse(number) do
      {num, _} -> num
      _ -> default
    end
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), name: "", lat: "", lon: "")
    {:ok, socket}
  end

  def handle_event("insert", %{"name" => name, "lat" => lat, "lon" => lon}, socket) do
    Station.add(%Station{name: name, lat: to_float(lat, 0.0), lon: to_float(lon, 0.0)})
    socket = assign(socket, stations: Station.get_all(), name: name, lat: lat, lon: lon)
    {:noreply, socket}
  end

  def handle_event("search", %{"name" => name}, socket) do
    socket = case name do
      "" -> assign(socket, stations: Station.get_all())
      _ -> assign(socket, stations: Station.find_by_name(name))
    end
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    Create new station
    <form phx-submit="insert">
      Name: <input type="text" name="name" value={@name} /><br/>
      Lat: <input type="number" name="lat" step="0.1" value={@lat} /><br/>
      Lon: <input type="number" name="lon" step="0.1" value={@lon} /><br/>
      <input type="submit" />
    </form>

    <form phx-change="search">
      Query: <input type="text" name="name" value={@name} /><br/>
    </form>

    <table>
      <tr>
        <th>Name</th><th>Longitude</th><th>Latitude</th>
      </tr>
      <%= for station <- @stations do %>
        <tr>
          <td><%= station.name %></td>
          <td><%= station.lon %></td>
          <td><%= station.lat %></td>
        </tr>
      <% end %>
    </table>
    """
  end
end