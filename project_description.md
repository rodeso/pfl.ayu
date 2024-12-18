# Project PFL Description

## Types game:
- Human/Human
- Human/Computer
- Computer/Computer

(Computers must have 2 dificulty levels)

## User Interface

The implementation should also include a suitable user interface in text mode.


## Languages and Tools: 

The game must run under SICStus Prolog version 4.9 and should work on Windows and Linux. If any configuration is required (beyond the standard installation of the software), or a font other than the default one is used, this must be expressed in the README file, which must also include the steps required to configure and/or install the necessary components (on Windows and Linux). Inability to test the developed code will result in penalties in the evaluation.

## Comments

Ensure that predicate names and functionality are as requested below and that all code is properly commented

## Submition

(See document)

## Source code: 
Consider the following guidelines for your source code:
 
- The main code file must be named game.pl and should be in the src folder.
 
- You can separate your code in different files for increased organization; however, all files should be in the src folder (i.e., do not include additional folders). 

- You can use any available SICStus libraries in your code.  
 
- The following predicates should have the specified signatures: 
    - **The main predicate, play/0** -> must be in the game.pl file and must give access to the game menu, which allows configuring the game type (H/H, H/PC, PC/H, or PC/PC), difficulty level(s) to be used by the artificial player(s), among other possible parameters, and start the game cycle. 
    - **initial_state(+GameConfig, -GameState).** -> This predicate receives a desired game configuration and returns the corresponding initial game state. Game configuration includes the type of each player and other parameters such as board size, use of optional rules, player names, or other information to provide more flexibility to the game. The game state describes a snapshot of the current game state, including board configuration (typically using list of lists with different atoms for the different pieces), identifies the current player (the one playing next), and possibly captured pieces and/or pieces yet to be played, or any other information that may be required, depending on the game. 
    - **display_game(+GameState).** -> This predicate receives the current game state (including the player who will make the next move) and prints the game state to the terminal. Appealing and intuitive visualizations will be valued. Flexible game state representations and visualization predicates will also be valued, for instance those that work with any board size. For uniformization purposes, coordinates should start at (1,1) at the lower left corner. 
    - **move(+GameState, +Move, -NewGameState).** -> This predicate is responsible for move validation and execution, receiving the current game state and the move to be executed, and (if the move is valid) returns the new game state after the move is executed. 
    - **valid_moves(+GameState, -ListOfMoves).** -> This predicate receives the current game state, and returns a list of all possible valid moves. 
    - **game_over(+GameState, -Winner).** -> This predicate receives the current game state, and verifies whether the game is over, in which case it also identifies the winner (or draw). Note that this predicate should not print anything to the terminal. 
    - **value(+GameState, +Player, -Value).** -> This predicate receives the current game state and returns a value measuring how good/bad the current game state is to the given Player. 
    - **choose_move(+GameState, +Level, -Move).** -> This predicate receives the current game state and returns the move chosen by the computer player. Level 1 should return a random valid move. Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. For human players, it should interact with the user to read the move. 

- You cannot use assert or retract to store / manipulate game configuration or game state information. If you need information from the game configuration, you can include it in the game state term. 

- Source code should follow established conventions for code quality and organization. Use meaningful names for predicates and arguments. Try to write code that ‘looks declarative’ and avoid using ‘imperative-looking’ constructions (e.g., if-then-else clauses). Try to write efficient code (e.g., using tail recursion when possible).1, 2 • All source code must be properly commented. Each of the predicates listed above should have extended comments describing the strategy used to implement it. 
000

## Readme

The README file (to submit in .pdf format) should be structured as follows: 

- Identification of the topic (game) and group (group designation, student number and full name of each member of the group), as well as an indication of the contribution (in percentages, adding up to 100%, and a brief description of tasks performed) of each member of the group to the assignment. 
- Installation and Execution: include all the necessary steps for the correct execution of the game in both Linux and Windows environments (in addition to the installation of SICStus Prolog 4.9). 
- Description of the game: a brief description of the game and its rules; you should also include the links used to gather information (official game website, rule book, etc.). 
- Considerations for game extensions: describe the considerations taken into account when extending the game design, namely when considering variable-sized boards, optional rules (e.g., simplified rules for novice players, additional rules for expert players), and other aspects. 
- Game Logic: Describe the main design decisions regarding the implementation of the game logic in Prolog (do not copy the source code). This section should have information on the following topics, among others: o Game Configuration Representation: describe the information required to represent the game configuration, how it is represented internally and how it is used by the initial_state/2 predicate. o Internal Game State Representation: describe the information required to represent the game state, how it is represented internally, including an indication of the meaning of each atom (i.e. how different pieces are represented). Include examples of representations of initial, intermediate, and final game states. o Move Representation: describe the information required to represent a move, and how it is represented internally (e.g., the coordinates of a board location, and/or other information necessary to represent a move) and how it is used by the move/3 predicate. o User Interaction: briefly describe the game menu system, as well as how interaction with the user is performed, focusing on input validation (e.g., when reading a move). 
- Conclusions: Conclusions about the work carried out, including limitations of the program (and known issues), as well as possible improvements (future developments roadmap). 
- Bibliography: List of books, papers, web pages and other resources used during the development of the assignment. If you used tools such as ChatGPT, list the queries used. You can also include one or more images illustrating the execution of the game, showing initial, intermediate and final game states, and interaction with the game. The entire document should not exceed four pages (including images and references). 