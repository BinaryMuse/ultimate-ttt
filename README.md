# Elixir Ultimate Tic-Tac-Toe

`UltimateTtt` is an Elixir module implementing the game Ultimate Tic-Tac-Toe. It implements the core, sequential game logic as well as an OTP app for creating and managing games. If you're unfamiliar with the game, [check out _Ultimate Tic-Tac-Toe_ by Ben Orlin](https://mathwithbaddrawings.com/ultimate-tic-tac-toe-original-post/).

## Links

- Package: [https://hex.pm/packages/ultimate_ttt](https://hex.pm/packages/ultimate_ttt)
- Documentation: [https://hexdocs.pm/ultimate_ttt/](https://hexdocs.pm/ultimate_ttt/)
- Source: [https://github.com/BinaryMuse/ultimate-ttt](https://github.com/BinaryMuse/ultimate-ttt)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `ultimate_ttt` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ultimate_ttt, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at [https://hexdocs.pm/ultimate_ttt](https://hexdocs.pm/ultimate_ttt).

## Game Rules

Ultimate Tic-Tac-Toe is played on a 3x3 grid, where each cell of the grid contains another 3x3 grid. The goal of the game is to win three games of tic-tac-toe in the inner grids such that they form a line in the outer grid.

The key rule of the game is that a play must be made in the board associated with the space the previous player played.

For example, `x` starts the game by plying anywhere they want. Here, they choose to play in the middle-left board (index 3) in the center space (index 4):

```elixir
alias UltimateTtt.Game
game = Game.new()
{:ok, game} = Game.place_tile(game, :x, {3, 4})
```

```text
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───────────┼───────────┼───────────
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │ x │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───────────┼───────────┼───────────
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
```

Now, `o` is required to play somewhere in the board at the center of the outer grid, because `x` played in the center space in the grid they chose. Similarly, the square they choose to play on in this center board will affect which grid `x` will be forced to play in next.

```elixir
Game.valid_moves(game, :o)
```

```text
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───────────┼───────────┼───────────
   │   │   │ + │ + │ + │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │ x │   │ + │ + │ + │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │ + │ + │ + │   │   │
───────────┼───────────┼───────────
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
───┼───┼───│───┼───┼───│───┼───┼───
   │   │   │   │   │   │   │   │
```

If a play forces the next player to play in a board that is either already claimed (by someone winning that board) or is full (resulting in a tie in the board), that player may choose to play anywhere they want.

The game is over when a player has won three inner boards in a row, resulting in a win for that player, or when every board is either won or a tie but no player has won three boards in a line, resulting in a tie.

## Example

### Core Rules

```elixir
iex> alias UltimateTtt.Game
iex> game = Game.new()
iex> Game.turn(game)
:x
iex> Game.valid_move?(game, :x, {3, 4})
true
iex> {:ok, game} = Game.place_tile(game, :x, {3, 4})
iex> Game.turn(game)
:o
iex> Game.valid_move?(game, :o, {3, 0}) # Player o has to play in the board at index 4
false
iex> Game.valid_move?(game, :x, {4, 0}) # Not player x's turn
false
iex> Game.valid_move?(game, :o, {4, 0})
true
iex> Game.valid_moves(game, :o)
[{4, 0}, {4, 1}, {4, 2}, {4, 3}, {4, 4}, {4, 5}, {4, 6}, {4, 7}, {4, 8}]
iex> Game.status(game)
:in_progress
iex> Game.last_played_space(game)
{3, 4}
iex> Game.tile_at(game, {3, 4})
:x
iex> Game.tile_at(game, {4, 0})
:empty
```

### OTP App

(Not yet implemented)

```elixir
game = GameSession.start_link()
```
