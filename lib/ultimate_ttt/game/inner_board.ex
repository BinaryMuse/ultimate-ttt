defmodule UltimateTtt.Game.InnerBoard do
  @moduledoc """
  This module represents one of the nine inner tic-tac-toe boards
  in a game of Ultimate Tic-Tac-Toe. Normally you will not need to
  interact with this module directly as most of its functionality
  is exposed through `UltimateTtt.Game.OuterBoard`.

  Note that this module does not track player turn, and thus
  any move into any empty space is valid unless the board is
  won or tied.
  """

  defimpl Inspect, for: UltimateTtt.Game.InnerBoard do
    def inspect(board, _opts) do
      Inspect.Algebra.concat([
        "#InnerBoard<\"",
        UltimateTtt.Game.InnerBoard.serialize(board),
        "\">"
      ])
    end
  end

  defstruct [:data]

  @opaque t :: %__MODULE__{data: board_data}
  @typep board_data :: {tile, tile, tile, tile, tile, tile, tile, tile, tile}
  @type player :: UltimateTtt.Game.player()
  @type tile :: UltimateTtt.Game.tile()
  @type space :: number()
  @type board_status :: UltimateTtt.Game.game_status()

  alias UltimateTtt.Game.InnerBoard

  @doc """
  Returns a new, empty board.
  """
  @spec new :: t
  def new do
    with_tiles(Tuple.duplicate(:empty, 9))
  end

  @doc false
  @spec with_tiles(board_data) :: t
  def with_tiles(tiles) when is_tuple(tiles) do
    %InnerBoard{data: tiles}
  end

  @doc """
  Returns a list of numbers that represent all valid moves for the board.
  No moves are considered valid once the board is won.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> InnerBoard.valid_moves(InnerBoard.new)
      [0, 1, 2, 3, 4, 5, 6, 7, 8]

      iex> alias UltimateTtt.Game.InnerBoard
      iex> ".x.ox...o"
      ...> |> InnerBoard.deserialize()
      ...> |> InnerBoard.valid_moves()
      [0, 2, 5, 6, 7]
  """
  @spec valid_moves(t) :: list(space)
  def valid_moves(board) do
    case status(board) do
      :in_progress ->
        for i <- 0..8, valid_move?(board, i), do: i

      _ ->
        []
    end
  end

  @doc """
  Returns a boolean specifying whether or not a given move is valid.
  `space` must be a number between 0 and 8, inclusive.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.new()
      iex> InnerBoard.valid_move?(board, 0)
      true
      iex> InnerBoard.valid_move?(board, 9)
      false

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.deserialize(".x.ox...o")
      iex> InnerBoard.valid_move?(board, 1)
      false
  """
  @spec valid_move?(t, space) :: boolean
  def valid_move?(board, space) when space >= 0 and space <= 8 do
    case Kernel.elem(board.data, space) do
      :empty -> status(board) == :in_progress
      _ -> false
    end
  end

  def valid_move?(_board, _space) do
    false
  end

  @doc """
  Attempts to place the given tile on the board at the given space.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.new()
      iex> {:ok, board} = InnerBoard.place_tile(board, 0, :x)
      iex> InnerBoard.place_tile(:board, 0, :o)
      {:error, :invalid_move}

  """
  @spec place_tile(t, player, space) :: {:ok, t} | {:err, :invalid_move}
  def place_tile(board, tile, space) do
    case valid_move?(board, space) do
      true -> {:ok, %{board | data: Kernel.put_elem(board.data, space, tile)}}
      false -> {:err, :invalid_move}
    end
  end

  @doc """
  Returns the tile occupying the given space.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.deserialize("xo.......")
      iex> InnerBoard.tile_at(board, 1)
      :o
      iex> InnerBoard.tile_at(board, 2)
      :empty
  """
  @spec tile_at(t, space) :: tile
  def tile_at(board, space) when space >= 0 and space <= 8 do
    Kernel.elem(board.data, space)
  end

  @doc """
  Returns the status of the board. This can be `:in_progress`, `:tie`,
  or `{:win, player}` (where `player` is `:x` or `:o`).

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.new
      iex> InnerBoard.status(board)
      :in_progress

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.deserialize("x...x...x")
      iex> InnerBoard.status(board)
      {:win, :x}
  """
  @spec status(t) :: board_status
  def status(%InnerBoard{data: {x, x, x, _, _, _, _, _, _}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {_, _, _, x, x, x, _, _, _}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {_, _, _, _, _, _, x, x, x}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {x, _, _, x, _, _, x, _, _}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {_, x, _, _, x, _, _, x, _}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {_, _, x, _, _, x, _, _, x}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {x, _, _, _, x, _, _, _, x}}) when x != :empty, do: {:win, x}
  def status(%InnerBoard{data: {_, _, x, _, x, _, x, _, _}}) when x != :empty, do: {:win, x}

  def status(board) do
    case Tuple.to_list(board.data) |> Enum.any?(fn x -> x == :empty end) do
      true -> :in_progress
      false -> :tie
    end
  end

  @doc """
  Serializes a board to a string representation.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> board = InnerBoard.new()
      iex> {:ok, board} = InnerBoard.place_tile(board, :x, 0)
      iex> {:ok, board} = InnerBoard.place_tile(board, :o, 8)
      iex> InnerBoard.serialize(board)
      "x.......o"
  """
  @spec serialize(t) :: binary
  def serialize(board) do
    Tuple.to_list(board.data)
    |> Enum.map_join("", &_serialize_tile/1)
  end

  @doc """
  Deserializes a serialized board back into an actual board.

  ## Examples

      iex> alias UltimateTtt.Game.InnerBoard
      iex> InnerBoard.deserialize("x.......o")
      #InnerBoard<"x.......o">
  """
  @spec deserialize(binary) :: t
  def deserialize(str) when is_binary(str) do
    data =
      String.split(str, "", trim: true)
      |> Enum.map(&_deserialize_tile/1)
      |> List.to_tuple()

    %InnerBoard{data: data}
  end

  @doc false
  @spec _serialize_tile(tile) :: <<_::8>>
  def _serialize_tile(tile) do
    case tile do
      :empty -> "."
      :x -> "x"
      :o -> "o"
    end
  end

  @doc false
  @spec _deserialize_tile(<<_::8>>) :: tile
  def _deserialize_tile(tile) do
    case tile do
      "." -> :empty
      "o" -> :o
      "x" -> :x
    end
  end
end
