defmodule UltimateTtt.Game do
  @moduledoc """
  This module implements the core, sequential rules of
  Ultimate Tic-Tac-Toe.

  To begin a game, use `new/0`. Make plays on the board with
  `place_tile/3`.

  ```
  alias UltimateTtt.Game
  game = Game.new()
  # Place an "x" in the center board, in the top-left square
  {:ok, game} = Game.place_tile(game, :x, {4, 0})
  ```

  You can check whether or not a move would be valid for a
  player using `valid_move?/3`. Note that this function returns
  false if it's not the given player's turn. (To check if a
  given move is valid for *any* player, use `board/1` and
  pass it to `UltimateTtt.Game.OuterBoard.valid_move?/2`.)
  You can get a list of *all* valid moves for a player with
  `valid_moves/2` (or valid moves for any player using
  `UltimateTtt.Game.OuterBoard.valid_moves/1`), which can
  be useful for highlighting valid moves in a UI.

  Note that no moves are considered valid once the game is
  over.

  In this example, since `:x` just played in the top-left
  square of a board, `:o` must now play inside the top-left
  board, if possible.

  ```
  Game.valid_move?(game, :o, {2, 3}) # false, not in top-left board!
  Game.valid_move?(game, :x, {0, 3}) # false, not x's turn!
  Game.valid_move?(game, :o, {0, 3}) # true
  Game.valid_moves(game, :o) # [{0, 0}, {0, 1}, {0, 2}, {0, 3}, ...]
  ```

  Finally, you can get an overall status of the game using
  `status/1`. The possible return values are `:in_progress`,
  `:tie`, and `{:win, player}` where `player` is `:x` or `:o`.

  ```
  Game.status(game) # :in_progress
  ```
  """

  defstruct board: nil, last_played: nil, next_turn: :x

  @opaque t :: %__MODULE__{board: board, last_played: nil | space, next_turn: player}

  @typedoc """
  An atom representing the player playing "X" or "O".
  """
  @type player :: :x | :o
  @typedoc """
  Represents the data for a single tile in a tic-tac-toe board;
  can be one of either players or `:empty`.
  """
  @type tile :: player() | :empty
  @type board :: UltimateTtt.Game.OuterBoard.t()
  @type game_status :: :in_progress | :tie | {:win, player()}
  @typedoc """
  A tuple of two numbers; the first number represents the index
  of the board, starting in the top-left cell and moving to the right
  and then to the left-most cell on the next row, and the
  second number represents the index of the cell inside that board.
  """
  @type space :: {number(), number()}

  alias UltimateTtt.Game.OuterBoard

  @doc """
  Creates a new game. The `:x` player starts.
  """
  @spec new() :: t
  def new do
    with_board(OuterBoard.new())
  end

  @doc false
  @spec with_board(board) :: t
  def with_board(board) do
    %__MODULE__{
      board: board,
      last_played: nil,
      next_turn: :x
    }
  end

  @doc """
  Return the `UltimateTtt.Game.OuterBoard` contained within
  the game.
  """
  @spec board(t) :: UltimateTtt.Game.OuterBoard.t()
  def board(game) do
    game.board
  end

  @doc """
  Get the status of the game.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> Game.status(game)
      :in_progress
  """
  @spec status(t) :: game_status
  def status(game) do
    OuterBoard.status(game.board)
  end

  @doc """
  Place a new tile.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> {:ok, game} = Game.place_tile(game, :x, {0, 0})
      iex> Game.valid_move?(game, :o, {0, 0})
      false
  """
  @spec place_tile(t, player, space) :: {:ok, t} | {:error, :invalid_move}
  def place_tile(game, player, space) do
    case valid_move?(game, player, space) do
      true ->
        {:ok, new_board} = OuterBoard.place_tile(game.board, player, space)

        new_game = %{
          game
          | board: new_board,
            next_turn: next_turn(game.next_turn),
            last_played: space
        }

        {:ok, new_game}

      false ->
        {:error, :invalid_move}
    end
  end

  @doc """
  Returns the tile at the given space.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> Game.tile_at(game, {0, 0})
      :empty
      iex> {:ok, game} = Game.place_tile(game, :x, {0, 0})
      iex> Game.tile_at(game, {0, 0})
      :x
  """
  @spec tile_at(t, space) :: tile
  def tile_at(game, space) do
    OuterBoard.tile_at(game.board, space)
  end

  @doc """
  Returns the space that the most recent move was made in.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> Game.last_played_space(game)
      nil
      iex> {:ok, game} = Game.place_tile(game, :x, {0, 4})
      iex> Game.last_played_space(game)
      {0, 4}
  """
  @spec last_played_space(t) :: space | nil
  def last_played_space(game) do
    game.last_played
  end

  @doc """
  Get a list of all valid moves for the given player.
  Will return an empty list if it's not the given player's
  turn, even if some moves would otherwise be valid. No moves
  are valid once the game is won.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> moves = Game.valid_moves(game, :x)
      iex> Enum.count(moves)
      81
      iex> Game.valid_moves(game, :o)
      []
  """
  @spec valid_moves(t, player) :: [space]
  def valid_moves(game, player) do
    Enum.filter(OuterBoard.valid_moves(game.board), &valid_move?(game, player, &1))
  end

  @doc """
  Determines if the given play is valid. Returns false if
  it's not the given player's turn, even if the move would
  otherwise be valid. Always returns false once the game
  is over.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> Game.valid_move?(game, :x, {0, 0})
      true
      iex> Game.valid_move?(game, :o, {0, 0})
      false
  """
  @spec valid_move?(t, player, space) :: boolean
  def valid_move?(game, player, space) do
    with :in_progress <- OuterBoard.status(game.board),
         ^player <- game.next_turn,
         true <- valid_space?(game, space) do
      OuterBoard.valid_move?(game.board, space)
    else
      _ -> false
    end
  end

  defp valid_space?(game, {board_idx, _}) do
    case game.last_played do
      nil ->
        true

      {_, last_space_idx} ->
        board_idx == last_space_idx ||
          OuterBoard.status_for_board_at(game.board, last_space_idx) != :in_progress
    end
  end

  @doc """
  Return the player who should play the next turn.

  ## Examples

      iex> alias UltimateTtt.Game
      iex> game = Game.new()
      iex> Game.turn(game)
      :x
      iex> {:ok, game} = Game.place_tile(game, :x, {0, 0})
      iex> Game.turn(game)
      :o
  """
  @spec turn(t) :: player
  def turn(game) do
    game.next_turn
  end

  @spec next_turn(player) :: player
  defp next_turn(player) do
    case player do
      :x -> :o
      :o -> :x
    end
  end

  @doc false
  @spec serialize(t) :: binary
  def serialize(game) do
    game
    |> :erlang.term_to_binary()
    |> Base.url_encode64()
  end

  @doc false
  @spec serialize(binary) :: t
  def deserialize(bin) when is_binary(bin) do
    Base.url_decode64!(bin)
    |> :erlang.binary_to_term()
  end
end
