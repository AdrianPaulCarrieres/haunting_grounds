defmodule PhoenixPhantoms.Systems.Destruction do
  @moduledoc """
  Documentation for Destruction system.
  """
  @behaviour ECSx.System

  alias PhoenixPhantoms.Components

  alias Components.DestroyedAt
  alias Components.HealthPoints
  alias Components.XPosition
  alias Components.XVelocity
  alias Components.YPosition
  alias Components.YVelocity

  @impl ECSx.System
  def run do
    ghosts = HealthPoints.get_all()

    Enum.each(ghosts, fn {ghost, hp} ->
      if hp <= 0 do
        destroy(ghost)
      end
    end)
  end

  defp destroy(ghost) do
    HealthPoints.remove(ghost)
    XPosition.remove(ghost)
    XVelocity.remove(ghost)
    YPosition.remove(ghost)
    YVelocity.remove(ghost)

    DestroyedAt.add(ghost, DateTime.utc_now())
  end
end
