# multiplayer

## server

central node that controls game logic and syncrhonizes game state

example variables:

- players: array, or dictionary that maps players to ids
- balls: array
- powerups: array
- game_state: String - e.g. "playing", "game_over"

methods:

- start_game(), end_game(): void

## MultiplayerSpawner

node built in to godot that automatically spawns in new nodes serverwide

has an auto spawn list that elements can be added to, e.g. players, balls, powerups

potential methods

- create_player(id): void
- spawn_ball(): void
- spawn_powerup(): void

## client

local game instance, handles individual player inputs

potential variables

properties: Dictionary (position, physics, holding ball, alive)

methods (RPCs to connect to server)

- join_game(), exit_game(): void
- throw(ball), catch(ball): void
- die(): void

### holder child

there is a bug apparently according to a youtube video where the client's properties will not update serverwide, and this can be fixed by putting all properites into a child node of the client and then feeding the child to a MultiplayerSynchronizer node

## MultiplayerSynchronizer

built-in node in Godot that automatically synchronizes updates serverwide

potential properties to sync:
players and their properites
balls and their properties
powerups
state of game

other variables
Replication Rate (most likely every frame)

## other notes

- i don't really know what i'm doing
