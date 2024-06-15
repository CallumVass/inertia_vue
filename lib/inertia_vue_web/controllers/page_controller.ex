defmodule InertiaVueWeb.PageController do
  use InertiaVueWeb, :controller

  def home(conn, _params) do
    conn
    |> assign_prop(:name, "My Name (from Server)")
    |> render_inertia("Home")
  end
end
