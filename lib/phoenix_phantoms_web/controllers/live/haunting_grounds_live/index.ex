defmodule PhoenixPhantomsWeb.HauntingGroundsLive.Index do
  use PhoenixPhantomsWeb, :live_view

  import PhoenixPhantomsWeb.SpookyComponents

  alias PhoenixPhantoms.Components
  alias Components.HealthPoints
  alias Components.XPosition
  alias Components.YPosition

  require Logger
  @impl true
  def mount(_params, _session, socket) do
    player_id = Ecto.UUID.generate()

    socket =
      socket
      |> assign(:player_entity, player_id)
      # These will configure the scale of our display compared to the game world
      |> assign_loading_state()

    if connected?(socket) do
      ECSx.ClientEvents.add(player_id, :spawn_player)
      send(self(), :first_load)
    end

    {:ok, socket}
  end

  defp assign_loading_state(socket) do
    assign(socket,
      loading: true
    )
  end

  @impl true
  def handle_info(:first_load, socket) do
    socket =
      socket
      |> assign_ghosts()
      |> assign(loading: false)

    :timer.send_interval(50, :refresh)

    {:noreply, socket}
  end

  def handle_info(:refresh, socket) do
    socket =
      socket
      |> assign_ghosts()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cursor-move", %{"x" => _x, "y" => _y}, socket) do
    # key = socket.id
    #payload = %{x: x, y: y}

    # metas =
    #   Presence.get_by_key(@presence, key)[:metas]
    #   |> List.first()
    #   |> Map.merge(payload)

    # Presence.update(self(), @presence, key, metas)

    {:noreply, socket}
  end

  @impl true
  def handle_event("ghost_click", %{"id" => ghost_id}, socket) do
    player_id = socket.assigns.player_entity

    ECSx.ClientEvents.add(player_id, {:shoot, ghost_id})

    {:noreply, socket}
  end

  defp assign_ghosts(socket) do
    assign(socket, ghosts: all_ghosts())
  end

  defp all_ghosts do
    for {ghost, _hp} <- HealthPoints.get_all() do
      x = XPosition.get(ghost)
      y = YPosition.get(ghost)
      {ghost, x, y}
    end
  end
end
