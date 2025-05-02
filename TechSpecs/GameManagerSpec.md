
## 1. GameManager (Root)

**Type**: `Node`  
**Path**: `res://scenes/GameManager.tscn` (Autoload)  
**Script**: `GameManager.gd`

### Enums & Properties

```gdscript
enum GameState { MENU, LOADING, LOBBY, PLAYING, PAUSED, GAME_OVER }

var state: GameState = GameState.MENU
export(int) var initial_lives = 2
export(float) var round_time = 240.0
export(bool) var dynamic_map = false
```

### Signals

```gdscript
signal hostGame()
signal stateChanging(old_state, new_state)
signal stateChanged(old_state, new_state)
```

### Methods & Callbacks

```gdscript
func _ready():
    # Called when GameManager enters the scene tree
    _load_config()
    _register_services()
    _transition_to(GameState.MENU)

func start_game() -> void:
    emit_signal("hostGame")
    _transition_to(GameState.LOBBY)

func _transition_to(new_state: GameState) -> void:
    if new_state == state:
        return
    emit_signal("stateChanging", state, new_state)
    var old = state
    state = new_state
    emit_signal("stateChanged", old, new_state)
    # handle on-enter logic
```

---

## 2. Lobby_Manager

**Type**: `Node`  
**Path**: `res://scenes/Lobby_Manager.tscn`  
**Script**: `Lobby_Manager.gd`

### Variables

```gdscript
var isHost: bool = false
var lobbyIsReady: bool = false
```

### Signals

```gdscript
signal joinedLobby()
```

### Callbacks & Methods

```gdscript
func _enter_tree():
    load_config()

func _ready():
    start_game_countdown()

func load_config() -> void:
    # parse lobby settings

func get_host() -> String:
    # return host player

func joined_lobby() -> void:
    lobbyIsReady = true
    emit_signal("joinedLobby")

func start_game_countdown() -> void:
    # show timer

func game_start() -> void:
    GameManager.start_game()
```

---

## 3. InGame_Manager

**Type**: `Node`  
**Path**: `res://scenes/InGame_Manager.tscn`  
**Script**: `InGame_Manager.gd`

### Signals

```gdscript
signal frame_update(delta: float)
signal startHitPlayer(player_id)
signal thisPlayerDied(player_id)
signal gameOver()
signal changingState(old_state, new_state)
```

### Callbacks & Methods

```gdscript
func _enter_tree():
    GameManager.connect("stateChanged", self, "_on_game_state_changed")

func _process(delta: float) -> void:
    emit_signal("frame_update", delta)

func next_round() -> void:
    # reset, respawn

func end_game() -> void:
    emit_signal("gameOver")

func spawn_powerups() -> void:
    # scatter powerups

func player_respawn(respawned_player_id) -> void:
    # respawn player

func player_hit(thrown_from_id, hit_player_id) -> void:
    emit_signal("startHitPlayer", hit_player_id)
    # handle elimination
```

### In-Game Variables

```gdscript
var players: Array   # Player instances
var teams: Array     # Team instances
var hoardingTimer: float
var map: String
var gameClock: float
var balls: Array     # Ball instances
```

---

## 4. Entity Definitions

### Team (Data Class)

```gdscript
class_name Team
var players: Array
var teamColor: String
var roundWins: int = 0
var isHoarding: bool = false
```

### Player (Data Class)

```gdscript
class_name Player
var name: String
var team: String
var livesRemaining: int
var isAlive: bool
var hasBall: bool
var position: Vector3
var outputLabel: Label
var isCatching: bool
var isBlocking: bool
```

### Ball (Data Class)

```gdscript
class_name Ball
var inHand: bool
var velocity: Vector3
var holder: String
var position: Vector3
var ballHolder: String
```

---

## 5. Integration Flow

1. **GameManager** (`MENU → LOBBY`):  
   - Instantiates Lobby_Manager, waits for `joinedLobby()`.  
2. **GameManager** (`LOBBY → PLAYING`):  
   - Removes lobby UI, instantiates InGame_Manager.  
3. **InGame_Manager**:  
   - Emits `frame_update` each frame → physics, movement, UI react.  
   - Listens for `player_hit` → updates lives, emits `thisPlayerDied` or respawn.  
   - Calls `spawn_powerups()` at intervals.  
4. **Round End**:  
   - `InGame_Manager.end_game()` → emits `gameOver` → GameManager transitions to `GAME_OVER`.  
5. **GameManager** (`GAME_OVER → MENU`):  
   - Cleans up InGame nodes, returns to main menu.

---

**Next Steps:**  
- Use this spec to update your Figma diagram.  
- Ensure each node, signal, variable, and method is represented as a component.  
- Collaborators can reference these exact names to wire up scenes and scripts in Godot.