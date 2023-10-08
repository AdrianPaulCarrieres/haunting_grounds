defmodule PhoenixPhantoms.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  alias PhoenixPhantoms.Components

  alias Components.XPosition
  alias Components.YPosition

  alias Components.XVelocity
  alias Components.YVelocity

  alias Components.HealthPoints

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)
    :ok
  end

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart
    for _ghosts <- 1..10 do
      # First generate a unique ID to represent the new entity
      entity = Ecto.UUID.generate()

      # Then use that ID to create the components which make up a ghost
      XPosition.add(entity, Enum.random(0..1000))
      YPosition.add(entity, Enum.random(0..1000))

      XVelocity.add(entity, 1)
      YVelocity.add(entity, 1)

      HealthPoints.add(entity, 1)
    end
  end

  # Declare all valid Component types
  def components do
    [
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
      PhoenixPhantoms.Systems.ClientEventHandler,
      PhoenixPhantoms.Systems.Destruction,
      PhoenixPhantoms.Systems.CooldownExpiration,
      PhoenixPhantoms.Systems.Driver
    ]
  end
end
