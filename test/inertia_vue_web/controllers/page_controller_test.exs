defmodule InertiaVueWeb.PageControllerTest do
  use InertiaVueWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "data-page"
    assert inertia_component(conn) == "Home"
    assert inertia_props(conn).name == "My Name (from Server)"
  end
end
