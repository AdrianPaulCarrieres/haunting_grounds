defmodule PhoenixPhantomsWeb.HauntingGroundsLive.Index do
  alias PhoenixPhantoms.Components.PlayerName
  alias PhoenixPhantoms.Components.PlayerColor
  use PhoenixPhantomsWeb, :live_view

  import PhoenixPhantomsWeb.SpookyComponents

  alias PhoenixPhantoms.Components
  alias Components.HealthPoints
  alias Components.XPosition
  alias Components.YPosition
  alias Components.Score

  alias PhoenixPhantoms.PubSub
  alias PhoenixPhantomsWeb.Presence

  @presence "presence:home"

  require Logger
  @impl true
  def mount(_params, _session, socket) do
    player_id = Ecto.UUID.generate()

    socket =
      socket
      |> assign(:player_entity, player_id)
      # These will configure the scale of our display compared to the game world
      |> assign_loading_state()

    socket =
      if connected?(socket) do
        {name, color} = player_identity()
        ECSx.ClientEvents.add(player_id, {:spawn_player, name, color})

        send(self(), :first_load)

        socket
        |> assign(:name, name)
        |> assign(:color, color)
      else
        socket
      end

    {:ok, socket}
  end

  defp assign_loading_state(socket) do
    assign(socket,
      loading: true,
      scores: [],
      users: [],
      ghosts: []
    )
  end

  @impl true
  def handle_info(:first_load, socket) do
    socket =
      socket
      |> join_presence()
      |> assign_ghosts()
      |> assign_scores()
      |> assign(loading: false)

    :timer.send_interval(50, :refresh)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    socket =
      socket
      |> assign_ghosts()
      |> assign_scores()

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@presence)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)

    {:noreply, updated}
  end

  @impl true
  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    key = socket.id
    payload = %{x: x, y: y}

    metas =
      Presence.get_by_key(@presence, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @presence, key, metas)

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

  defp assign_scores(socket) do
    scores =
      Score.get_all()
      |> Enum.sort_by(fn {_p, s} -> s end, :desc)
      |> Enum.map(fn {entity, score} ->
        player_name = PlayerName.get(entity)
        player_color = PlayerColor.get(entity)

        {entity, player_name, player_color, score}
      end)

    assign(socket, :scores, scores)
  end

  defp join_presence(socket) do
    player_entity = socket.assigns.player_entity
    name = socket.assigns.name
    color = socket.assigns.color

    {:ok, _} =
      Presence.track(self(), @presence, socket.id, %{
        joined_at: :os.system_time(:seconds),
        x: 50,
        y: 50,
        name: name,
        color: color,
        id: socket.id,
        player_entity: player_entity
      })

    Phoenix.PubSub.subscribe(PubSub, @presence)

    initial_users =
      Presence.list(@presence)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    socket
    |> assign(:users, initial_users)
    |> assign(:x, 50)
    |> assign(:y, 50)
  end

  defp player_identity do
    name =
      [
        "Alucard",
        "Angel",
        "Donovan Baine",
        "Simon Belmont",
        "Blade",
        "Anita Blake",
        "Blubberella",
        "Bonnie Bubblegum",
        "Father Callahan",
        "Cordelia Chase",
        "Lucy Coe",
        "Darkwatch",
        "Eva",
        "Riley Finn",
        "Rupert Giles",
        "Gwenpool",
        "Jonathan Harker",
        "Arthur Holmwood",
        "Huntress",
        "Jonathan Joestar",
        "Tara Maclay",
        "Marceline the Vampire Queen",
        "Martin Mertens",
        "Oz",
        "Spike",
        "Abraham Van Helsing",
        "Noah van Helsing",
        "Watcher"
      ]
      |> Enum.random()

    color =
      [
        "#ef4444",
        "#f59e0b",
        "#84cc16",
        "#06b6d4",
        "#8b5cf6",
        "#c026d3",
        "#f43f5e"
      ]
      |> Enum.random()

    {name, color}
  end
end
