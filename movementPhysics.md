# Movement Physics Spec

_Laying out **movement physics** – this lives under the **Features basic overview** bullet in the game ReadMe (“fluid movement, making a responsive and quick game”).  

---

## Class Overview

| Class | Responsibility | Relationship |
|-------|----------------|--------------|
| **Player**   | Stores physical state (position, velocity, etc.). | • Composes **Movement**<br>• Talks to **GameWorld** for collision/ground checks |
| **Movement** | Converts raw input into acceleration & jump impulses. | • Writes into owning **Player** |

---

## Player

### Variables

| Name | Type | Purpose |
|------|------|---------|
| `position`      | `Vector3` | World‑space location |
| `velocity`      | `Vector3` | Current linear velocity (m s⁻¹) |
| `acceleration`  | `Vector3` | Per‑frame xy acceleration |
| `max_velocity`  | `Vector3` | Clamp for top speed / terminal fall |
| `height`        | `int`     | Player height (affected by `duck`) |
| `gravity`       | `float`   | Down‑ward acceleration (m s⁻²) |

### Methods


duck()                                 -> void
change_position_z(vel: Vector3)        -> void
change_speed_xy(fwd: Vector3,
                left: Vector3,
                right: Vector3,
                back: Vector3)         -> void
change_position_xy(speed: Vector3)     -> void
change_velocity_z(gravity: float)      -> void
```

| Method | Behaviour |
|--------|-----------|
| **duck** | Toggles crouch; shrinks/expands `height`. |
| **change_position_z** | Integrates vertical motion into `position`. |
| **change_speed_xy** | Adds input‑driven acceleration to the `velocity` variable, respecting `max_velocity` as the maximum velocity, at which point velocity stays constant |
| **change_position_xy** | Translates `position.xz` based on current `velocity`. |
| **change_velocity_z** | Applies gravity acceleration downwards each physics tick until grounded. |

### Collaborators

* **Movement** – primary writer of horizontal acceleration & jump impulse.
* **GameWorld / PhysicsSpace** – collision resolution, floor detection, friction.

---

## Movement

### Variables

| Name | Type | Purpose |
|------|------|---------|
| `acceleration_xy` | `Vector3` | Horizontal acceleration applied while key is held |
| `velocity_up`     | `Vector3` | Jump impulse injected on key‑down edge |

### Methods

```text
move_forward(is_pressed: bool) -> void
move_left(is_pressed: bool)    -> void
move_right(is_pressed: bool)   -> void
move_back(is_pressed: bool)    -> void
move_up(is_pressed: bool)      -> void
```

* **move_* methods** – set or clear axis flags, updating `acceleration_xy` on the owning Player.
* **move_up** – once per *key‑down* event applies `velocity_up` to `Player.velocity.y`.

### Collaborators

* **Player** – receives acceleration and impulses.
* **Input** – queried for W / A / S / D / Space states each frame.

---

## Frame‑by‑Frame Sequence

1. **Horizontal input (`W/A/S/D`) held**  
   `Movement.move_*` sets axis flag → writes `acceleration_xy` → `Player.change_speed_xy` integrates → `Player.change_position_xy` moves character.
2. **Key released**  
   Axis flag clears → horizontal velocity decays via friction until 0.
3. **Jump (`Space`)**  
   `Movement.move_up` injects `velocity_up` once → `Player.change_velocity_z` applies gravity each tick → `Player.change_position_z` updates height until landing.


