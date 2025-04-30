# Catching/Knocking Mechanic Technical Specification

## Feature: Catching / Knocking Dodgeballs

This feature introduces a timed quick reaction mechanic in *HyperBallz*, where players can either catch an incoming dodgeball or knock it away, depending on whether they currently hold a ball. Successful interaction prevents a hit, affects player states, and adds strategic depth.

---

## Feature Scope
- Implements an interactive on-screen target that players must click in time.
- Determines whether the player catches or knocks the incoming ball.
- Adjusts target size based on difficulty (catching is smaller than knocking).
- Adds dynamic positioning based on ball approach.

---

## Associated Lines from Design Document
- **Gameplay → Catching/Knocking Balls** (line ~112)
  > “If the player clicks within the target while not holding a ball, they will catch the ball. If the player clicks on the target while holding a ball, they knock the ball away, resulting in no hit.”

---

## Variables
```gdscript
var has_ball: bool                    # Whether the player currently has a ball
var ball_speed: float                 # Speed of the incoming ball (used to adjust target timer)
var target_location: Vector2          # Position on screen where target appears
var is_reachable: bool                # Whether the ball is within interactive range
var target_radius: float              # Size of the clickable target
```

---

## Methods
```gdscript
# Triggered when a ball approaches a player
activate_target(ball_node: Node, hit_location: Vector2, is_catch: bool) -> void
```
**Parameters:**
- `ball_node`: reference to the incoming dodgeball
- `hit_location`: screen position where the ball will arrive
- `is_catch`: `true` if player isn’t holding a ball, else it’s a knock

```gdscript
# Handles visual UI creation and logic timer
display_target(pos: Vector2, radius: float) -> void
```
**Shows the reaction dot, starts countdown.**

```gdscript
# Hides the target UI on screen
hide_target() -> void
```

```gdscript
# Called on user click — checks if click was inside target zone
try_click(pos: Vector2) -> void
```
**Parameters:**
- `pos`: screen coordinates of user click (mouse or touch)

```gdscript
# Resolves what happens to the ball/player
resolve_catch(ball: Node) -> void
```
- If player caught: give ball to them, trigger animation
- If knock: reflect ball or deflect
- If miss: player loses life, knockback applied

---

## Target Behavior
- Appears for **1 second** (adjustable with ball speed)
- Target size:
  - **Catch (no ball held)**: 40px radius
  - **Knock (holding ball)**: 60px radius
- Position varies:
  - Based on ball trajectory
  - Centered for head-on throws, offset for sides/legs

---

## Relationships
- Depends on `Player` class to read inventory state (`has_ball`)
- Depends on `Ball` class to apply outcomes (`catch`, `deflect`, `damage`)
- Interfaces with `HUD` or `UIManager` to display interactive target
- Hooks into `InputManager` to receive click events

---

## Future Enhancements
- Slow-down effect for powerups (e.g. Speedster or Time Slow)
- Audio/visual feedback for each outcome
- Animations based on where player is hit (torso, leg, head)

---

## Suggested Folder Structure
```
/project
├── Player/
│   └── CatchMechanic.gd
├── UI/
│   └── CatchTarget.tscn
│   └── CatchTarget.gd
├── Balls/
│   └── DodgeBall.gd
```

---

## Completion Checklist
- [x] Dynamic dot appears with time limit
- [x] Varies by player state (catch vs knock)
- [x] Click detection with resolution tolerance
- [x] Handles success/failure outcomes

---
