defmodule PollutiondbPhxWeb.StationRangeLive do
  use PollutiondbPhxWeb, :live_view

  alias PollutiondbPhx.Station

  def to_float(number, default) do
    case Float.parse(number) do
      {num, _} -> num
      _ -> default
    end
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), name: "", lat: "", lon: "",
                    lat_min: 0, lat_max: 300, lon_min: 0, lon_max: 300)
    {:ok, socket}
  end

  def handle_event("update", %{"lat_min" => lat_min, "lat_max" => lat_max, "lon_min" => lon_min, "lon_max" => lon_max}, socket) do
    socket = assign(socket,
      stations: Station.find_by_location_range(to_float(lon_min, 0.0),
                                                to_float(lon_max, 0.0),
                                                to_float(lat_min, 0.0),
                                                to_float(lat_max, 0.0)),
      lat_min: lat_min,
      lat_max: lat_max,
      lon_min: lon_min,
      lon_max: lon_max
    )
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <form phx-change="update">
      Lat min <input type="range" min="0" max="300" name="lat_min" value={@lat_min}/><br/>
      Lat max <input type="range" min="0" max="300" name="lat_max" value={@lat_max}/><br/>
      Lon min <input type="range" min="0" max="300" name="lon_min" value={@lon_min}/><br/>
      Lon max <input type="range" min="0" max="300" name="lon_max" value={@lon_max}/><br/>
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