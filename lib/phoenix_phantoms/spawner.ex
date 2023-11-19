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

  alias Components.ImageFile

  @images [
    "images/ghost_skull_Fusionnes.png",
    "images/ghost_grave_Fusionnes.png",
    "images/small_skull_Fusionnes.png"
  ]

  def spawn_many(n) do
    Enum.each(0..n, fn _ -> spawn_one() end)
  end

  def spawn_one() do
    entity = Ecto.UUID.generate()

    # Then use that ID to create the components which make up a ghost
    XPosition.add(entity, Enum.random(0..1500))
    YPosition.add(entity, Enum.random(0..900))

    XVelocity.add(entity, Enum.random(-3..3))
    YVelocity.add(entity, Enum.random(-3..3))

    image = Enum.random(@images)

    ImageFile.add(entity, image)

    HealthPoints.add(entity, 1)
  end
end
