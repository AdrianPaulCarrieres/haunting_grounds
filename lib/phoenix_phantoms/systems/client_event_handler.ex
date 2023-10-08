defmodule PhoenixPhantoms.Systems.ClientEventHandler do
  @moduledoc """
  Documentation for ClientEventHandler system.
  """
  @behaviour ECSx.System

  alias PhoenixPhantoms.Components.PlayerColor
  alias PhoenixPhantoms.Components.PlayerName
  alias PhoenixPhantoms.Components.AttackedBy
  alias PhoenixPhantoms.Components
  alias Components.AttackCooldown
  alias Components.KilledBy
  alias Components.HealthPoints
  alias Components.AttackSpeed
  alias Components.Score

  @impl ECSx.System
  def run do
    client_events = ECSx.ClientEvents.get_and_clear()

    Enum.each(client_events, &process_one/1)
  end

  defp process_one({player, {:spawn_player, name, color}}) do
    Score.add(player, 0)
    PlayerName.add(player, name)
    PlayerColor.add(player, color)

    AttackSpeed.add(player, 1.2)
  end

  defp process_one({player, {:shoot, ghost}}) do
    if AttackCooldown.exists?(player) do
      nil
    else
      deal_damage(ghost, player)
      add_cooldown(player)
    end
  end

  defp deal_damage(ghost, player) do
    case HealthPoints.get(ghost, :already_dead) do
      :already_dead ->
        :ok

      hp when hp - 1 >= 1 ->
        AttackedBy.add(ghost, player)
        HealthPoints.update(ghost, hp - 1)

      hp when hp <= 1 ->
        KilledBy.add(ghost, player)
        HealthPoints.update(ghost, 0)
    end
  end

  defp add_cooldown(self) do
    now = DateTime.utc_now()
    ms_between_attacks = calculate_cooldown_time(self)
    cooldown_until = DateTime.add(now, ms_between_attacks, :millisecond)

    AttackCooldown.add(self, cooldown_until)
  end

  # We're going to model AttackSpeed with a float representing attacks per second.
  # The goal here is to convert that into milliseconds per attack.
  defp calculate_cooldown_time(self) do
    attacks_per_second = AttackSpeed.get(self)
    seconds_per_attack = 1 / attacks_per_second

    ceil(seconds_per_attack * 1000)
  end
end
