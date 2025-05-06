enum GameState { MENU, LOADING, LOBBY, PLAYING, PAUSED, GAME_OVER }
@export var initial_lives: int = 2
@export var round_time: float = 240.0
@export var dynamic_map: bool = false
var state: GameState = GameState.MENU
