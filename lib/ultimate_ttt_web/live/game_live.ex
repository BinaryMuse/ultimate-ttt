defmodule UltimateTttWeb.GameLive do
  use Phoenix.LiveView
  alias UltimateTtt.Game

  def render(assigns) do
    Phoenix.View.render(UltimateTttWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _other_params, socket) do
    game = Game.new()
    {:ok, assign(socket, :game, game)}
  end

  def handle_event("place_tile", %{"space" => space, "tile" => tile}, socket) do
    tile =
      case tile do
        "o" -> :o
        "x" -> :x
      end

    [board_idx, space_idx] = String.split(space, ",") |> Enum.map(&String.to_integer/1)

    case Game.place_tile(socket.assigns.game, tile, {board_idx, space_idx}) do
      {:ok, game} -> {:noreply, assign(socket, :game, game)}
      {:error, :invalid_move} -> {:noreply, socket}
    end
  end
end
