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
    assert OuterBoard.new |> OuterBoard.serialize() == Enum.map(1..9, fn _ -> "........." end) |> Enum.join("/")
  end

  test "deserializes" do
    serialized = "........x/........./........./........./........./........./........./........./........."
    outer = OuterBoard.deserialize(serialized)
    top_left = Kernel.elem(outer, 0)
    assert top_left[:status] == :in_progress
    assert InnerBoard.valid_move?(top_left[:board], 8) == false
  end

  test "fetches inner boards by index" do
    serialized = "........x/........./........./........./........./........./........./........./........."
    outer = OuterBoard.deserialize(serialized)
    top_left = OuterBoard.get_inner_board(outer, 0)
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
    {:ok, board} = OuterBoard.place_tile(board, {0, 0}, :x)
    {:err, :invalid_move} = OuterBoard.place_tile(board, {0, 0}, :x)
    {:err, :invalid_move} = OuterBoard.place_tile(board, {9, 0}, :x)
  end

  test "returns valid moves" do
    mid_game_board = InnerBoardTest.mid_game_board()
    tie_board = InnerBoardTest.tie_board()
    boards = List.duplicate(mid_game_board, 2) ++ List.duplicate(tie_board, 7)
    board = OuterBoard.with_boards(boards)
    assert OuterBoard.valid_moves(board) == [{0, 0}, {0, 3}, {0, 8}, {1, 0}, {1, 3}, {1, 8}]
  end

  test "reports board status" do
    assert OuterBoard.status(mid_game_board()) == :in_progress
    assert OuterBoard.status(tie_board()) == :tie

    board = mid_game_board()
    {:ok, board} = OuterBoard.place_tile(board, {0, 0}, :x)
    {:ok, board} = OuterBoard.place_tile(board, {0, 3}, :x)
    {:ok, board} = OuterBoard.place_tile(board, {1, 0}, :x)
    {:ok, board} = OuterBoard.place_tile(board, {1, 3}, :x)
    {:ok, board} = OuterBoard.place_tile(board, {2, 0}, :x)
    {:ok, board} = OuterBoard.place_tile(board, {2, 3}, :x)
    assert OuterBoard.status(board) == {:win, :x}
  end
end
