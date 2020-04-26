defmodule UltimateTtt.Game.OuterBoard do
  @moduledoc """
  This module represents the larger, outer tic-tac-toe grid containing
  9 inner tic-tac-toe grids (which are in turn represented by
  `UltimateTtt.Game.InnerBoard`). Normally you will not need to
  interact with this module directly as most of its functionality
  is exposed through `UltimateTtt.Game`.

  Note that this module does not track player turn, nor does it
  it implement the rules restricting play to the board associated with
  the last played space, and thus any move into any empty space
  is valid unless the board is won or tied.
  """

  defimpl Inspect, for: UltimateTtt.Game.OuterBoard do
    def inspect(board, _opts) do
      Inspect.Algebra.concat([
        "#OuterBoard<\"",
        UltimateTtt.Game.OuterBoard.serialize(board),
        "\">"
      ])
    end
  end

  defstruct [:data]

  @typedoc """
  An opaque data structure representing the larger, outer
  tic-tac-toe grid.
  """
  @opaque t :: %__MODULE__{data: board_data}
  @typep inner_board_info :: %{board: InnerBoard.t(), status: Game.game_status()}
  @typep board_data ::
           {inner_board_info, inner_board_info, inner_board_info, inner_board_info,
            inner_board_info, inner_board_info, inner_board_info, inner_board_info,
            inner_board_info}

  @doc """
  Returns a new, empty board.
  """
  @spec new :: t
  def new do
    %__MODULE__{data: Tuple.duplicate(create_inner_board_info(), 9)}
  end

  @doc false
  @spec with_boards([UltimateTtt.Game.InnerBoard.t()]) :: t
  def with_boards(boards) when is_list(boards) and length(boards) == 9 do
    data = Enum.map(boards, &create_inner_board_info/1) |> List.to_tuple()
    %__MODULE__{data: data}
  end

  @doc false
  @spec create_inner_board_info(UltimateTtt.Game.InnerBoard.t()) :: inner_board_info
  def create_inner_board_info(board \\ UltimateTtt.Game.InnerBoard.new()) do
    %{board: board, status: UltimateTtt.Game.InnerBoard.status(board)}
  end

  @doc """
  Returns the `UltimateTtt.Game.InnerBoard` stored at the given index.
  """
  @spec inner_board_at(t, number) :: UltimateTtt.Game.InnerBoard.t()
  def inner_board_at(board, index) when index >= 0 and index <= 8 do
    Kernel.elem(board.data, index) |> Map.get(:board)
  end

  @doc """
  Returns a list of all spaces representing valid moves on the board.
  No moves are considered valid once the board is won.
  """
  @spec valid_moves(t) :: [UltimateTtt.Game.space()]
  def valid_moves(board) do
    with :in_progress <- status(board) do
      for i <- 0..8,
          moves = inner_board_at(board, i) |> UltimateTtt.Game.InnerBoard.valid_moves(),
          j <- moves,
          do: {i, j}
    else
      _ -> []
    end
  end

  @doc """
  Determines if the given move is valid for the board. The move
  is specified as `{board_idx, space_idx}`.

  ## Example

      iex> alias UltimateTtt.Game.OuterBoard
      iex> board = OuterBoard.new()
      iex> OuterBoard.valid_move?(board, {0, 0})
      true
      iex> {:ok, board} = OuterBoard.place_tile(board, :x, {0, 0})
      iex> OuterBoard.valid_move?(board, {0, 0})
      false
  """
  @spec valid_move?(t, UltimateTtt.Game.space()) :: boolean
  def valid_move?(board, space)

  def valid_move?(board, {inner_idx, inner_space}) when inner_idx >= 0 and inner_idx <= 8 do
    case status(board) do
      :in_progress ->
        board.data
        |> Kernel.elem(inner_idx)
        |> Map.get(:board)
        |> UltimateTtt.Game.InnerBoard.valid_move?(inner_space)

      _ ->
        false
    end
  end

  def valid_move?(_, _), do: false

  @doc """
  Attempts to place the given tile on the given board at the given space.
  Returns `{:ok, new_board}` if successful and `{:err, :invalid_move}` otherwise.
  The move is specified as `{board_idx, space_idx}`.
  """
  @spec place_tile(t, UltimateTtt.Game.player(), UltimateTtt.Game.space()) ::
          {:ok, t} | {:err, :invalid_move}
  def place_tile(board, tile, {inner_idx, inner_space} = space) do
    with :in_progress = status(board),
         true <- valid_move?(board, space),
         inner = inner_board_at(board, inner_idx),
         {:ok, new_inner_board} <-
           UltimateTtt.Game.InnerBoard.place_tile(inner, tile, inner_space) do
      {:ok, replace_inner_board(board, inner_idx, new_inner_board)}
    else
      _ -> {:err, :invalid_move}
    end
  end

  @doc """
  Returns the `t:UltimateTtt.Game.tile/0` at the given space.

  ## Examples

      iex> alias UltimateTtt.Game.OuterBoard
      iex> board = OuterBoard.new()
      iex> OuterBoard.tile_at(board, {0, 0})
      :empty
      iex> {:ok, board} = OuterBoard.place_tile(board, :x, {0, 0})
      iex> OuterBoard.tile_at(board, {0, 0})
      :x
  """
  @spec tile_at(t, UltimateTtt.Game.space()) :: UltimateTtt.Game.tile()
  def tile_at(board, space)

  def tile_at(board, {board_idx, space_idx}) do
    inner_board_at(board, board_idx)
    |> UltimateTtt.Game.InnerBoard.tile_at(space_idx)
  end

  @doc false
  @spec replace_inner_board(t, number, UltimateTtt.Game.InnerBoard.t()) :: t
  def replace_inner_board(board, inner_idx, new_inner_board) do
    data = Kernel.put_elem(board.data, inner_idx, create_inner_board_info(new_inner_board))
    %{board | data: data}
  end

  @doc false
  @spec status_per_inner_board(t) :: [UltimateTtt.Game.game_status()]
  def status_per_inner_board(board) do
    Tuple.to_list(board.data) |> Enum.map(&Map.get(&1, :status))
  end

  @doc """
  Returns the status of the board. This can be `:in_progress`, `:tie`,
  or `{:win, player}` (where `player` is `:x` or `:o`).
  """
  @spec status(t) :: UltimateTtt.Game.game_status()
  def status(board) do
    status_per_inner_board(board)
    |> get_status()
  end

  @doc false
  @spec get_status([UltimateTtt.Game.game_status()]) :: UltimateTtt.Game.game_status()
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
      true -> :in_progress
      false -> :tie
    end
  end

  @doc false
  @spec status_for_board_at(t, number) :: UltimateTtt.Game.game_status()
  def status_for_board_at(board, board_idx) when board_idx >= 0 and board_idx <= 8 do
    Kernel.elem(board.data, board_idx)[:status]
  end

  @doc """
  Serializes a board to a string representation
  """
  @spec serialize(t) :: binary
  def serialize(board) do
    Tuple.to_list(board.data)
    |> Enum.map(&UltimateTtt.Game.InnerBoard.serialize(&1[:board]))
    |> Enum.join("/")
  end

  @doc """
  Deserializes a serialized board back into an actual board.
  """
  @spec deserialize(binary) :: t
  def deserialize(serialized) do
    String.split(serialized, "/")
    |> Enum.map(&UltimateTtt.Game.InnerBoard.deserialize/1)
    |> with_boards()
  end
end
