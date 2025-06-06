defmodule PollutiondbPhx.Repo do
  use Ecto.Repo,
    otp_app: :pollutiondb_phx,
    adapter: Ecto.Adapters.SQLite3
end
