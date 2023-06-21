# Julia Solver for a two-person game

## Knuth's algorithm

Donald Knuth describes an algorithm for "solving" a two-person game with perfect information, no randomness, and with a finite number of states. The algorithm returns all states in which the outcome of the game is already determined if both players play optimally. If these states contain the initial position of the game, we know that always one of the players can force the victory and which of the two players it is. The original description of the algorithm is:

> The following construction shows how to solve a fairly general type of two-person game, including chess, nim, and many simpler games: Consider a finite set of nodes, each of which represents a possible position in the game. For each position there are zero or more moves that transform that position into some other position. We say that position x is a predecessor of position y (and y is a successor of x) if there is a move from x to y. Certain positions that have no successors are classified as won or lost positions. The player to move in position x is the opponent of the player to move in the successors of position x. Given such a configuration of positions, we can compute the complete set of won positions (those in which the next player to move can force a victory) and the complete set of lost positions (those in which the player must lose against an expert opponent) by repeatedly doing the following operation until it yields no change: Mark a position “lost” if all its successors are marked “won”; mark a position “won” if at least one of its successors is marked “lost.” After this operation has been repeated as many times as possible, there may be some positions that have not been marked at all; a player in such a position can neither force a victory nor be compelled to lose. This procedure for obtaining the complete set of won and lost positions can be adapted to an efficient algorithm for computers that closely resembles Algorithm T. We may keep with each position a count of the number of its successors that have not been marked “won,” and a list of all its predecessors.
>
> Knuth, D. E. (1997). The art of computer programming (3rd ed.). Addison Wesley. 2.2.4 Exercise 28, Page 272-273

For the presentation of the algorithm, the self-invented game "Tupitu" is chosen, which is described in detail in the next section.

## Tupitu

```math
\begin{array}{|c|c|c|c|c|} \hline - & - & - & - & - \\ \hline - & - & - & B & - \\ \hline - & - & - & - & - \\ \hline - & A & - & - & - \\ \hline - & - & - & - & - \\ \hline\end{array}
```

The game Tupitu is played on a 5x5 grid with the two players A and B positioned as shown in the figure. The players take turns, with player A starting. In the first half of the turn, the player must move to one of the up to 8 adjacent pieces, just like the king in chess. In the second half of the turn, he chooses one of the tiles on which no player is standing. This tile is then cleared for the rest of the game, meaning that no player can move on it anymore. The first player who can no longer move on his turn loses.

## Code

Since the game has more than $`2 \cdot 10^9`$ states, all checks for analysis are implemented in bitwise operations and the state of the board is stored in a 32-bit integer. The `startAnalysis()` function creates the game tree and keeps track of all possible final states, which are classified by win or loss. Due to memory limitations, the data is stored on disk using the internal Julia library [Serialization](https://docs.julialang.org/en/v1/stdlib/Serialization/). `endAnalysis()` then works backwards through the tree, marking the states according to the rules established by Knuth: (1) if all successors are marked as "won", the state is marked as "lost", and (2) if at least one of its successors is marked as "lost", the state is marked as "won".

In the end, the initial state is included in the winning states for player A, which means that the starting player can force a win.

(c) Christoph Muessig
