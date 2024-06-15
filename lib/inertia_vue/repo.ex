defmodule InertiaVue.Repo do
  use Ecto.Repo,
    otp_app: :inertia_vue,
    adapter: Ecto.Adapters.SQLite3
end
