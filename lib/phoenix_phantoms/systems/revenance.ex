defmodule PhoenixPhantoms.Systems.Revenance do
  @moduledoc """
  Documentation for Revenance system.
  """
  @behaviour ECSx.System

  alias PhoenixPhantoms.Components
  alias Components.DestroyedAt

  require Logger

  @impl ECSx.System
  def run do
    destroyed_ghosts = DestroyedAt.get_all()

    Enum.each(destroyed_ghosts, fn {id, _d} -> 
      raise_dead(id, Enum.random([false, true]))
    end)
    :ok
  end

  defp raise_dead(killed_at, raise_dead?)
  defp raise_dead(_killed_at, false), do: nil

  defp raise_dead(killed_at, _) do
    PhoenixPhantoms.Spawner.spawn_one()
    DestroyedAt.remove(killed_at)
  end
end
