defmodule UltimateTttWeb.GameView do
  use UltimateTttWeb, :view
  alias UltimateTtt.Game

  @type game :: Game.game()
  @type space :: Game.space()

  def get_border_classes(i) do
    case i do
      0 -> "bb br"
      1 -> "bl bb br"
      2 -> "bl bb"
      3 -> "bt bb br"
      4 -> "bt bb bl br"
      5 -> "bt bl bb"
      6 -> "bt br"
      7 -> "bl bt br"
      8 -> "bl bt"
    end
  end

  @spec is_empty(game, space) :: boolean
  def is_empty(game, space) do
    case Game.tile_at(game, space) do
      :empty -> true
      _ -> false
    end
  end

  def content_for_space(game, {i, j}) do
    case Game.tile_at(game, {i, j}) do
      :x -> "X"
      :o -> "O"
      :empty -> ""
    end
  end

  def get_player(game) do
    Game.get_turn(game)
  end

  def get_space({i, j}) do
    "#{i},#{j}"
  end

  def classes_for_cell(game, {_, idx} = space) do
    tile = Game.tile_at(game, space)
    next_player = Game.get_turn(game)
    valid = Game.valid_move?(game, next_player, space)

    taken_class =
      case tile do
        :x -> "taken cell-text x"
        :o -> "taken cell-text o"
        :empty -> ""
      end

    valid_class =
      case valid do
        true -> "valid"
        false -> "invalid"
      end

    [
      "cell",
      "inner",
      taken_class,
      valid_class,
      get_border_classes(idx)
    ]
  end

  def get_outer_cell_classes(game, idx) do
    status = Game.get_inner_board_status(game, idx)

    won_class =
      case status do
        {:win, :x} -> "won-x"
        {:win, :o} -> "won-o"
        :tie -> "tied"
        _ -> ""
      end

    [
      "cell",
      "grid",
      "blight",
      won_class,
      get_border_classes(idx)
    ]
  end

  def game_over(game) do
    case Game.status(game) do
      :in_progress -> nil
      :tie -> "It's a tie!"
      {:win, p} -> "#{Atom.to_string(p)} wins!"
    end
  end
end
