defmodule UltimeTttTest.Game do
  use ExUnit.Case
  doctest UltimateTtt.Game

  alias UltimateTtt.Game
  alias UltimateTtt.Game.InnerBoard
  alias UltimateTtt.Game.OuterBoard

  describe "UltimateTtt.Game" do
    def mid_game() do
      InnerBoard.deserialize(".xo.oxxo.")
      |> List.duplicate(9)
      |> OuterBoard.with_boards()
      |> Game.with_board()
    end

    def tie_game() do
      InnerBoard.deserialize("xoxoxxoxo")
      |> List.duplicate(9)
      |> OuterBoard.with_boards()
      |> Game.with_board()
    end

    def win_game() do
      tie_board = InnerBoard.deserialize("xoxoxxoxo")

      InnerBoard.deserialize("xoxoxxoox")
      |> List.duplicate(3)
      |> Enum.concat(List.duplicate(tie_board, 6))
      |> OuterBoard.with_boards()
      |> Game.with_board()
    end

    test "allows x to move anywhere on the first move" do
      game = Game.new()
      assert Game.valid_move?(game, :x, {0, 0}) == true
      assert Game.valid_move?(game, :x, {1, 0}) == true
      assert Game.valid_move?(game, :x, {2, 0}) == true
    end

    test "doesn't allow moves out of turn order" do
      game = Game.new()
      assert Game.valid_move?(game, :o, {0, 0}) == false
    end

    test "returns valid moves" do
      mid = InnerBoard.deserialize(".xo.oxxo.") |> List.duplicate(2)
      tie = InnerBoard.deserialize("xoxoxxoxo") |> List.duplicate(7)
      game = (mid ++ tie) |> OuterBoard.with_boards() |> Game.with_board()

      assert Game.valid_moves(game, :x) == [{0, 0}, {0, 3}, {0, 8}, {1, 0}, {1, 3}, {1, 8}]
      assert Game.valid_moves(game, :o) == []
      {:ok, game} = Game.place_tile(game, :x, {0, 0})
      assert Game.valid_moves(game, :x) == []
      assert Game.valid_moves(game, :o) == [{0, 3}, {0, 8}]
    end

    test "changes player turn" do
      game = Game.new()
      assert Game.get_turn(game) == :x
      {:ok, game} = Game.place_tile(game, :x, {0, 0})
      assert Game.get_turn(game) == :o
    end

    test "enforces that moves happen in the inner board associated with the last space" do
      game = Game.new()
      {:ok, game} = Game.place_tile(game, :x, {0, 0})
      assert Game.valid_move?(game, :o, {0, 1}) == true
      assert Game.valid_move?(game, :o, {1, 1}) == false
    end

    test "allows moves outside of the inner board associated with the last space if that board is full" do
      first_inner = InnerBoard.deserialize(".oxoxxoxo")
      blank_board = InnerBoard.new()

      game =
        ([first_inner] ++ List.duplicate(blank_board, 8))
        |> OuterBoard.with_boards()
        |> Game.with_board()

      {:ok, game} = Game.place_tile(game, :x, {0, 0})
      assert OuterBoard.get_status_for_board(game.board, 0) == :tie
      assert Game.valid_move?(game, :o, {8, 1}) == true
    end

    test "reports game status" do
      assert Game.status(Game.new()) == :in_progress
      assert Game.status(tie_game()) == :tie
      assert Game.status(win_game()) == {:win, :x}
    end
  end
end
