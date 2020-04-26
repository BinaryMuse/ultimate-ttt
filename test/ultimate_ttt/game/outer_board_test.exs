defmodule UltimateTttTest.Game.OuterBoard do
  use ExUnit.Case
  doctest UltimateTtt.Game.OuterBoard

  alias UltimateTtt.Game.InnerBoard
  alias UltimateTtt.Game.OuterBoard
  alias UltimateTttTest.Game.InnerBoard, as: InnerBoardTest

  def mid_game_board do
    inner_board = InnerBoardTest.mid_game_board()
    OuterBoard.with_boards(Tuple.duplicate(inner_board, 9) |> Tuple.to_list())
  end

  def tie_board do
    inner_board = InnerBoardTest.tie_board()
    OuterBoard.with_boards(Tuple.duplicate(inner_board, 9) |> Tuple.to_list())
  end

  test "serializes" do
    assert OuterBoard.new() |> OuterBoard.serialize() ==
             Enum.map(1..9, fn _ -> "........." end) |> Enum.join("/")
  end

  test "deserializes" do
    serialized =
      "........x/........./........./........./........./........./........./........./........."

    outer = OuterBoard.deserialize(serialized)
    top_left = OuterBoard.inner_board_at(outer, 0)
    assert InnerBoard.status(top_left) == :in_progress
    assert InnerBoard.valid_move?(top_left, 8) == false
  end

  test "fetches inner boards by index" do
    serialized =
      "........x/........./........./........./........./........./........./........./........."

    outer = OuterBoard.deserialize(serialized)
    top_left = OuterBoard.inner_board_at(outer, 0)
    assert InnerBoard.serialize(top_left) == "........x"
  end

  test "allows moves in empty spaces" do
    board = mid_game_board()
    assert OuterBoard.valid_move?(board, {0, 0}) == true
    assert OuterBoard.valid_move?(board, {0, 1}) == false
  end

  test "allows valid moves" do
    board = mid_game_board()
    assert OuterBoard.valid_move?(board, {0, 0}) == true
    {:ok, board} = OuterBoard.place_tile(board, :x, {0, 0})
    {:err, :invalid_move} = OuterBoard.place_tile(board, :x, {0, 0})
    {:err, :invalid_move} = OuterBoard.place_tile(board, :x, {9, 0})
  end

  test "returns valid moves" do
    mid_game_board = InnerBoardTest.mid_game_board()
    tie_board = InnerBoardTest.tie_board()
    boards = List.duplicate(mid_game_board, 2) ++ List.duplicate(tie_board, 7)
    board = OuterBoard.with_boards(boards)
    assert OuterBoard.valid_moves(board) == [{0, 0}, {0, 3}, {0, 8}, {1, 0}, {1, 3}, {1, 8}]
  end

  test "reports status per inner board" do
    assert OuterBoard.status_per_inner_board(mid_game_board()) == List.duplicate(:in_progress, 9)
  end

  test "reports overall board status" do
    assert OuterBoard.status(mid_game_board()) == :in_progress
    assert OuterBoard.status(tie_board()) == :tie

    board = mid_game_board()
    {:ok, board} = OuterBoard.place_tile(board, :x, {0, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {0, 3})
    {:ok, board} = OuterBoard.place_tile(board, :x, {1, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {1, 3})
    {:ok, board} = OuterBoard.place_tile(board, :x, {2, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {2, 3})
    assert OuterBoard.status(board) == {:win, :x}
  end

  test "doesn't allow moves after the game is over" do
    assert OuterBoard.valid_moves(tie_board()) == []

    board = mid_game_board()
    {:ok, board} = OuterBoard.place_tile(board, :x, {0, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {0, 3})
    {:ok, board} = OuterBoard.place_tile(board, :x, {1, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {1, 3})
    {:ok, board} = OuterBoard.place_tile(board, :x, {2, 0})
    {:ok, board} = OuterBoard.place_tile(board, :x, {2, 3})
    assert OuterBoard.valid_move?(board, {0, 8}) == false
    assert OuterBoard.valid_moves(board) == []
  end
end
