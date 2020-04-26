defmodule UltimateTttTest.Game.InnerBoard do
  use ExUnit.Case
  doctest UltimateTtt.Game.InnerBoard, except: [{:place_tile, 3}]

  alias UltimateTtt.Game.InnerBoard

  def mid_game_board do
    InnerBoard.with_tiles({:empty, :x, :o, :empty, :o, :x, :x, :o, :empty})
  end

  def tie_board do
    InnerBoard.with_tiles({:x, :o, :x, :o, :x, :x, :o, :x, :o})
  end

  def winning_boards(tile) do
    letter =
      case tile do
        :x -> "x"
        :o -> "o"
      end

    [
      "xxx......",
      "...xxx...",
      "......xxx",
      "x..x..x..",
      ".x..x..x.",
      "..x..x..x",
      "x...x...x",
      "..x.x.x.."
    ]
    |> Enum.map(&String.replace(&1, "x", letter))
    |> Enum.map(&InnerBoard.deserialize/1)
  end

  test "allows moves in empty spaces" do
    board = mid_game_board()
    assert InnerBoard.valid_move?(board, 0) == true
    assert InnerBoard.valid_move?(board, 1) == false
    assert InnerBoard.valid_move?(board, 2) == false
    assert InnerBoard.valid_move?(board, 8) == true
    assert InnerBoard.valid_move?(board, 10) == false
  end

  test "modifies the board with valid moves" do
    board = mid_game_board()
    {:ok, new_board} = InnerBoard.place_tile(board, 0, :x)
    assert InnerBoard.tile_at(new_board, 0) == :x

    assert InnerBoard.place_tile(board, :o, 1) == {:err, :invalid_move}
    assert InnerBoard.place_tile(board, :o, 9) == {:err, :invalid_move}
  end

  test "reports game status" do
    assert InnerBoard.status(mid_game_board()) == :in_progress
    assert InnerBoard.status(tie_board()) == :tie

    is_win_for = &(InnerBoard.status(&1) == {:win, &2})
    assert Enum.all?(winning_boards(:x), &is_win_for.(&1, :x))
    assert Enum.all?(winning_boards(:o), &is_win_for.(&1, :o))
  end
end
