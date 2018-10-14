# Roadblock

We visited the [National Building Museum](https://www.nbm.org/) in Washington DC and my oldest son picked out a game called [Roadblock](https://www.smartgames.eu/uk/one-player-games/roadblock) in the gift shop. I was initially turned off by the subject matter, but the first time we played it I was intrigued by the puzzles and some questions I had about them:
1. How many starting board permutations are possible with this set of pieces?
2. What determines the difficulty of each starting board?
3. Each starting board published in the Roadblock instructions has only only solution. Are there starting boards with multiple solutions? How many?

In seeking some answers to my questions I discovered [polyominoes](https://en.wikipedia.org/wiki/Polyomino) and the [recursive backtracking algorithms](http://www.mattbusche.org/blog/article/polycube/#algorithm) used to solve polyomino puzzles. In particular, Matt Busche's [Polycube](http://www.mattbusche.org/blog/article/polycube/) turned out to be a great resource to help answer some of these questions.

So I created a simple ruby wrapper around the polycube binary called [polycube-rb](https://github.com/jordanderson/polycube-rb), and this repository to help answer some of the questions above.
