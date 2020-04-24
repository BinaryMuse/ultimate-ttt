defmodule UltimateTtt.Game.InnerBoard do
  @type player :: :o | :x
  @type tile :: :empty | player
  @opaque board :: {tile, tile, tile, tile, tile, tile, tile, tile, tile}
  @type board_status :: :in_progress | :tie | {:win, player}

  @doc """
  Returns a new, empty board.
  """
  @spec new :: board
  def new do
    Tuple.duplicate(:empty, 9)
  end

  @doc """
  Returns a list of numbers that represent all valid moves for the board.
  """
  @spec valid_moves(board) :: list(number)
  def valid_moves(board) do
    for i <- 0..8, valid_move?(board, i), do: i
  end

  @doc """
  Returns a boolean specifying whether or not a given move is valid.
  """
  @spec valid_move?(board, number) :: boolean
  def valid_move?(board, space) when space >= 0 and space <= 8 do
    case Kernel.elem(board, space) do
      :empty -> true
      _      -> false
    end
  end

  def valid_move?(_board, _space) do
    false
  end

  @doc """
  Attempts to place the given tile on the board at the given space.
  Returns `{:ok, new_board}` if successful and `{:err, :invalid_move}` otherwise.
  """
  @spec place_tile(board, number, player) :: {:ok, board} | {:err, :invalid_move}
  def place_tile(board, space, tile) do
    case valid_move?(board, space) do
      true  -> {:ok, board |> Kernel.put_elem(space, tile)}
      false -> {:err, :invalid_move}
    end
  end

  @doc """
  Returns the status of the board. This can be `:in_progress`, `:tie`,
  or `{:win, player}` (where `player` is `:x` or `:o`).
  """
  @spec status(board) :: board_status
  def status({x, x, x, _, _, _, _, _, _}) when x != :empty, do: {:win, x}
  def status({_, _, _, x, x, x, _, _, _}) when x != :empty, do: {:win, x}
  def status({_, _, _, _, _, _, x, x, x}) when x != :empty, do: {:win, x}
  def status({x, _, _, x, _, _, x, _, _}) when x != :empty, do: {:win, x}
  def status({_, x, _, _, x, _, _, x, _}) when x != :empty, do: {:win, x}
  def status({_, _, x, _, _, x, _, _, x}) when x != :empty, do: {:win, x}
  def status({x, _, _, _, x, _, _, _, x}) when x != :empty, do: {:win, x}
  def status({_, _, x, _, x, _, x, _, _}) when x != :empty, do: {:win, x}
  def status(board) do
    case Tuple.to_list(board) |> Enum.any?(fn x -> x == :empty end) do
      true  -> :in_progress
      false -> :tie
    end
  end

  @doc """
  Serializes a board to a string representation
  """
  @spec serialize(board) :: binary
  def serialize(board) do
    Tuple.to_list(board)
      |> Enum.map_join("", &_serialize_tile/1)
  end

  @doc """
  Deserializes a serialized board back into an actual board.
  """
  @spec deserialize(binary) :: board
  def deserialize(str) when is_binary(str) do
    String.split(str, "", trim: true)
      |> Enum.map(&_deserialize_tile/1)
      |> List.to_tuple()
  end

  @spec _serialize_tile(tile) :: <<_::8>>
  def _serialize_tile(tile) do
    case tile do
      :empty -> "."
      :x     -> "x"
      :o     -> "o"
    end
  end

  @spec _deserialize_tile(<<_::8>>) :: tile
  def _deserialize_tile(tile) do
    case tile do
      "." -> :empty
      "o" -> :o
      "x" -> :x
    end
  end
end
