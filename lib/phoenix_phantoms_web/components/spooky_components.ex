defmodule PhoenixPhantomsWeb.SpookyComponents do
  @moduledoc """
  Boo! 👻
  """
  use Phoenix.Component

  # alias Phoenix.LiveView.JS
  # import PhoenixPhantomsWeb.Gettext

  @doc """
  Renders a button that plays a sound effect when clicked.
  """
  attr :id, :string, required: true
  attr :sample, :string, required: true
  slot :inner_block

  def sfx(assigns) do
    ~H"""
    <button id={@id} phx-hook="SoundFx" data-sample={@sample}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :float_speed, :integer, default: 1

  attr :on_click, :string, default: ""
  attr :id, :string, default: ""
  attr :image, :string, default: "images/ghost_skull_Fusionnes.png"

  @doc """
  Renders a spooky ghost that floats on your screen.
  """
  def ghost(assigns) do
    ~H"""
    <img
      phx-click={@on_click}
      phx-value-id={@id}
      class="fixed z-0 opacity-75 w-20 animate-[ghost_1s_ease-in-out_infinite]"
      src={~c"#{@image}"}
      style={"left: #{@x}px; top: #{@y}px; animation-duration: #{@float_speed}s";}
    />
    """
  end
end
