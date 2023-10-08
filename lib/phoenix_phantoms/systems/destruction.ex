defmodule PhoenixPhantoms.Systems.Destruction do
  @moduledoc """
  Documentation for Destruction system.
  """
  @behaviour ECSx.System

  alias PhoenixPhantoms.Components.KilledBy
  alias PhoenixPhantoms.Components.Score
  alias PhoenixPhantoms.Components.AttackedBy
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
        award_points(ghost)
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

  defp award_points(ghost) do
    AttackedBy.get_all()
    |> Enum.filter(fn {g, _player} -> g == ghost end)
    |> Enum.each(fn {_g, player} ->
      s = Score.get(player) + 5
      Score.update(player, s)
    end)

    KilledBy.get_all()
    |> Enum.filter(fn {g, _player} -> g == ghost end)
    |> Enum.each(fn {_g, player} ->
      s = Score.get(player) + 10
      Score.update(player, s)
    end)
  end
end
