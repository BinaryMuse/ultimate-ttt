defmodule UltimateTtt.Game do
  alias UltimateTtt.Game.{InnerBoard, OuterBoard}

  @type tile :: InnerBoard.tile()
  @type player :: InnerBoard.player()
  @type board :: OuterBoard.board()
  @type game_status :: OuterBoard.board_status()
  @type space :: OuterBoard.space()
  @type game :: %{
          board: board,
          last_inner_idx: nil | number,
          next_turn: player
        }

  @doc """
  Creates a new game
  """
  @spec new() :: game
  def new do
    with_board(OuterBoard.new())
  end

  @spec with_board(board) :: game
  def with_board(board) do
    %{
      board: board,
      last_inner_idx: nil,
      next_turn: :x
    }
  end

  @doc """
  Get the status of the game.
  """
  @spec status(game) :: game_status()
  def status(game) do
    statuses = OuterBoard.status_per_inner_board(game.board)
    get_status(statuses)
  end

  @spec get_inner_board_status(game, number) :: game_status()
  def get_inner_board_status(game, idx) do
    OuterBoard.status_per_inner_board(game.board)
    |> Enum.at(idx)
  end

  @doc false
  @spec get_status([game_status()]) :: game_status()
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

  @doc """
  Place a new tile.
  """
  @spec place_tile(game, player, space) :: {:ok, game} | {:error, :invalid_move}
  def place_tile(game, player, {_, inner_idx} = space) do
    case valid_move?(game, player, space) do
      true ->
        {:ok, new_board} = OuterBoard.place_tile(game.board, space, player)

        new_game = %{
          game
          | board: new_board,
            next_turn: get_next_turn(game.next_turn),
            last_inner_idx: inner_idx
        }

        {:ok, new_game}

      false ->
        {:error, :invalid_move}
    end
  end

  @spec tile_at(game, space) :: tile
  def tile_at(game, {board_idx, space_idx}) do
    OuterBoard.get_inner_board(game.board, board_idx)
    |> InnerBoard.get_player_at(space_idx)
  end

  @doc """
  Get a list of all valid moves for the given player.
  Will return an empty list if it's not the player's turn.
  """
  @spec valid_moves(game, player) :: [space]
  def valid_moves(game, player) do
    Enum.filter(OuterBoard.valid_moves(game.board), &valid_move?(game, player, &1))
  end

  @doc """
  Determines if the given play is valid. Returns false if
  it's not the player's turn.
  """
  @spec valid_move?(game, player, space) :: boolean()
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
    case game.last_inner_idx do
      nil ->
        true

      n ->
        n == board_idx ||
          OuterBoard.get_status_for_board(game.board, game.last_inner_idx) != :in_progress
    end
  end

  @doc """
  Get the player whose turn it is.
  """
  @spec get_turn(game) :: player
  def get_turn(game) do
    game.next_turn
  end

  @spec get_next_turn(player) :: player
  defp get_next_turn(player) do
    case player do
      :x -> :o
      :o -> :x
    end
  end
end
