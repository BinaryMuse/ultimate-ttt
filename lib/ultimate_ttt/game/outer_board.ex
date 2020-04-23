defmodule UltimateTtt.Game.OuterBoard do
  alias UltimateTtt.Game.InnerBoard

  @type inner_board :: %{ board: InnerBoard.board, status: InnerBoard.board_status }
  @opaque board :: {inner_board, inner_board, inner_board, inner_board, inner_board, inner_board, inner_board, inner_board, inner_board}
  @type board_status :: :in_progress | :tie | {:win, InnerBoard.player}
  @type space :: {number, number}

  @spec new :: board
  @doc """
  Returns a new, empty board
  """
  def new do
    Tuple.duplicate(create_inner_board(), 9)
  end

  @doc """
  Create an `OuterBoard` out of a list of 9 `InnerBoard`s
  """
  @spec with_boards([InnerBoard.board]) :: board
  def with_boards(boards) when is_list(boards) and length(boards) == 9 do
    Enum.map(boards, &create_inner_board/1) |> List.to_tuple()
  end

  @doc """
  Creates inner board data based on the passed inner board, or a
  new empty inner board if none provided.
  """
  @spec create_inner_board(InnerBoard.board) :: inner_board
  def create_inner_board(board \\ InnerBoard.new) do
    %{ board: board, status: InnerBoard.status(board) }
  end

  @doc """
  Returns the `InnerBoard.board` stored at the given index
  """
  @spec get_inner_board(board, number) :: any
  def get_inner_board(board, index) when index >= 0 and index <= 9 do
    Kernel.elem(board, index) |> Map.get(:board)
  end

  @doc """
  Determines if the given move is valid for the board. The move
  is specified as `{board_idx, space_idx}`.
  """
  @spec valid_move?(board, space) :: boolean
  def valid_move?(board, {inner_idx, inner_space}) when inner_idx >= 0 and inner_idx <= 8 do
    inner = Kernel.elem(board, inner_idx)
    case inner[:status] do
      :in_progress -> InnerBoard.valid_move?(inner[:board], inner_space)
      _            -> false
    end
  end
  def valid_move?(_, _), do: false

  @doc """
  Attempts to place the given tile on the given board at the given space.
  Returns `{:ok, new_board}` if successful and `{:err, :invalid_move}` otherwise.
  The move is specified as `{board_idx, space_idx}`.
  """
  @spec place_tile(board, space, InnerBoard.player) :: {:ok, board} | {:err, :invalid_move}
  def place_tile(board, {inner_idx, inner_space}, tile) do
    case valid_move?(board, {inner_idx, inner_space}) do
      true ->
        inner = Kernel.elem(board, inner_idx)
        case InnerBoard.place_tile(inner[:board], inner_space, tile) do
          {:ok, new_inner_board} -> {:ok, replace_inner_board(board, inner_idx, new_inner_board)}
          _                      -> {:err, :invalid_move}
        end
      false -> {:err, :invalid_move}
    end
  end

  @doc """
  Returns a new board after replacing the data at the given index
  with new data generated from the given `InnerBoard.board`.
  """
  @spec replace_inner_board(board, number, InnerBoard.board) :: board
  def replace_inner_board(board, inner_idx, new_inner_board) do
    new_inner = %{ board: new_inner_board, status: InnerBoard.status(new_inner_board) }
    Kernel.put_elem(board, inner_idx, new_inner)
  end

  @doc """
  Returns the status of the board. This can be `:in_progress`, `:tie`,
  or `{:win, player}` (where `player` is `:x` or `:o`).
  """
  @spec status(board) :: board_status
  def status(board) do
    statuses = Tuple.to_list(board) |> Enum.map(&Map.get(&1, :status))
    get_status(statuses)
  end

  @spec get_status([board_status]) :: board_status
  defp get_status([x, x, x, _, _, _, _, _, _]) when elem(x, 0) == :win, do: x
  defp get_status([_, _, _, x, x, x, _, _, _]) when elem(x, 0) == :win, do: x
  defp get_status([_, _, _, _, _, _, x, x, x]) when elem(x, 0) == :win, do: x
  defp get_status([x, _, _, x, _, _, x, _, _]) when elem(x, 0) == :win, do: x
  defp get_status([_, x, _, _, x, _, _, x, _]) when elem(x, 0) == :win, do: x
  defp get_status([_, _, x, _, _, x, _, _, x]) when elem(x, 0) == :win, do: x
  defp get_status([x, _, _, _, x, _, _, _, x]) when elem(x, 0) == :win, do: x
  defp get_status([_, _, x, _, x, _, x, _, _]) when elem(x, 0) == :win, do: x
  defp get_status(statuses) do
    case Enum.any?(statuses, fn x -> x == :in_progress end) do
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
      |> Enum.map(&InnerBoard.serialize(&1[:board]))
      |> Enum.join("/")
  end

  @doc """
  Deserializes a serialized board back into an actual board.
  """
  @spec deserialize(binary) :: board
  def deserialize(serialized) do
    String.split(serialized, "/")
      |> Enum.map(&InnerBoard.deserialize/1)
      |> with_boards()
  end
end
