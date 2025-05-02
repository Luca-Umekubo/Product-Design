# Catching/Knocking Tech Spec

## Feature Name
**Catching/Knocking Mechanic**

## Overview
This feature handles the player interaction mechanic for catching and knocking dodgeballs during gameplay. A small target appears when a ball is headed toward the player based on the location the ball is hitting the player. Clicking the target in time allows the player to catch or knock the ball, depending on whether they're holding a ball themselves.

---

## Variables

| Name               | Type     | Description                                                                 |
|--------------------|----------|-----------------------------------------------------------------------------|
| `has_ball`         | `bool`   | Indicates whether the player currently holds a ball                        |
| `ball_speed`       | `float`  | The speed at which the incoming ball is approaching                        |
| `target_location`  | `Vector2`| The screen position where the target appears for catching/knocking         |
| `is_reachable`     | `bool`   | Determines whether the ball is within reach (in terms of timing & location)|
| `target_radius`    | `float`  | Radius of the clickable target area (larger for knock, smaller for catch)  |

---

## Methods

### `activate_target(ball_node: Node, hit_location: Vector2)`
- Activates the UI element for the clickable target.
- Positions it on the screen based on where the ball is expected to hit.
- Adjusts the `target_radius` based on and whether the player is holding a ball using `has_ball`.

### `display_target(pos: Vector2)`
- Visually displays the target on the player's screen at `pos`.

### `hide_target()`
- Hides the target once time has expired or the interaction is resolved.

### `try_click(pos: Vector2)`
- Called when the player clicks.
- Checks whether the click was within the `target_location` and `target_radius`.
- Resolves as a catch or knock depending on state and proximity.

### `resolve_catch(ball: Node)`
- Handles successful catch:
  - Transfers ball ownership to player.
  - Updates UI/state.
  - Removes life if unsuccessful and redirects the ball.
- Handles knock:
  - Redirects the incoming ball.
  - Applies knockback to receiver.
  - Removes life if unsuccessful and redirects the ball.

---

## Dependencies

- **Ball.gd**: For ball state, speed, trajectory
- **Player.gd**: To determine whether a player has a ball and apply knockback
- **UIManager.gd**: To render and hide target UI element
- **GameState.gd**: To update global stats and game rules (e.g. catching gives life back)

---

## User Flow

1. Ball is approaching the player
2. System checks if it's within catchable range (angle + speed)
3. Target appears (`activate_target`)
4. Player clicks → `try_click()` is called
    - If hit, `resolve_catch()` runs catch or knock logic
    - If miss or time expires, `hide_target()` is called
5. Ball continues or is destroyed depending on result

---

## Edge Cases & Notes

- Catch radius is smaller than knock radius
- If player already has a ball, default to knock unless specified otherwise
- Can be expanded to allow special character abilities (e.g., wider radius, time slow)
- Player in air may have harder time catching depending on momentum
- Add visual cue or animation for success/failure (particle effect or sound)

---
