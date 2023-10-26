defmodule PhoenixPhantoms.Spawner do
  @moduledoc """
  Ghost spawner utility
  """

  alias PhoenixPhantoms.Components

  alias Components.XPosition
  alias Components.YPosition

  alias Components.XVelocity
  alias Components.YVelocity

  alias Components.HealthPoints

  def spawn_many(n) do
    Enum.each(0..n, fn _ -> spawn_one() end)
  end

  def spawn_one() do
    entity = Ecto.UUID.generate()

    # Then use that ID to create the components which make up a ghost
    XPosition.add(entity, Enum.random(0..1000))
    YPosition.add(entity, Enum.random(0..1000))

    XVelocity.add(entity, Enum.random(-5..5))
    YVelocity.add(entity, Enum.random(-5..5))

    HealthPoints.add(entity, 1)
  end
end
