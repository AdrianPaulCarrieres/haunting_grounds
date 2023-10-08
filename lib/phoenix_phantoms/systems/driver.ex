defmodule PhoenixPhantoms.Systems.Driver do
  @moduledoc """
  Documentation for Driver system.
  """
  @behaviour ECSx.System

  alias PhoenixPhantoms.Components

  alias Components.XPosition
  alias Components.YPosition

  alias Components.XVelocity
  alias Components.YVelocity

  @impl ECSx.System
  def run do
    for {entity, x_velocity} <- XVelocity.get_all() do
      x_position = XPosition.get(entity)
      new_x_position = rem(x_position + x_velocity, 1000)
      XPosition.update(entity, new_x_position)
    end

    # Once the x-values are updated, do the same for the y-values
    for {entity, y_velocity} <- YVelocity.get_all() do
      y_position = YPosition.get(entity)
      new_y_position = rem(y_position + y_velocity, 1000)
      YPosition.update(entity, new_y_position)
    end
  end
end
