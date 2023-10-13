defmodule PhoenixPhantoms.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  alias PhoenixPhantoms.Spawner

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)
    :ok
  end

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart
    Spawner.spawn_many(10)
  end

  # Declare all valid Component types
  def components do
    [
      PhoenixPhantoms.Components.PlayerName,
      PhoenixPhantoms.Components.PlayerColor,
      PhoenixPhantoms.Components.AttackedBy,
      PhoenixPhantoms.Components.KilledBy,
      PhoenixPhantoms.Components.Score,
      PhoenixPhantoms.Components.AttackSpeed,
      PhoenixPhantoms.Components.DestroyedAt,
      PhoenixPhantoms.Components.AttackCooldown,
      PhoenixPhantoms.Components.HealthPoints,
      PhoenixPhantoms.Components.YVelocity,
      PhoenixPhantoms.Components.XVelocity,
      PhoenixPhantoms.Components.YPosition,
      PhoenixPhantoms.Components.XPosition
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      PhoenixPhantoms.Systems.Revenance,
      PhoenixPhantoms.Systems.ClientEventHandler,
      PhoenixPhantoms.Systems.Destruction,
      PhoenixPhantoms.Systems.CooldownExpiration,
      PhoenixPhantoms.Systems.Driver
    ]
  end
end
