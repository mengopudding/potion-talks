defmodule Potiontalks.Repo do
  use Ecto.Repo,
    otp_app: :potiontalks,
    adapter: Ecto.Adapters.Postgres
end
