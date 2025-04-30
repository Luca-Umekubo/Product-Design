# Throwing Physics Spec

> **Lines 60–62** of the design ReadMe outline the throwing mechanic

---

## Class Overview

| Class | Responsibility | Relationship |
|-------|----------------|--------------|
| **Player** | Owns a ball while aiming / throwing; chooses throw type; spawns the projectile. | • *Has‑a* **Ball** while holding.• Calls **Target** for hit‑detection via Ball. |
| **Ball**   | Simulates projectile flight, boundary bounces, friction, and hit tests. | • Created & launched by **Player**.|
| **Target** | Represents any entity that can be hit (players, obstacles). | • Provides `is_hit` API consumed by **Ball**. |

---

## Player (Throwing Interface)

### Variables

| Name | Type | Purpose |
|------|------|---------|
| `throw_type` | `enum { QUICK, AIM, NONE }` | Current throw style selected. |
| `position`   | `Vector3` | Player’s world position. |
| `speed`      | `Vector3` | Horizontal velocity (affected by aiming slow). |
| `held_ball`  | `Ball`    | Reference while in possession; `null` after throw. |

### Methods

```text
type_of_throw(press_time_ms: int) -> ThrowType
throw_direction(mouse_pos_screen: Vector2,
                camera: Camera3D)          -> Vector3
player_slow(t: ThrowType)                   -> float
throw(dir: Vector3, t: ThrowType)          -> void
```

| Method | Behaviour |
|--------|-----------|
| **type_of_throw** | Maps button‑hold length to `QUICK` (<200 ms) or `AIM` (>200 ms). |
| **throw_direction** | Casts a ray from `camera` through `mouse_pos_screen`; returns normalised direction. |
| **player_slow** | Returns a movement‑speed multiplier (e.g., 0.4 while aiming). |
| **throw** | Instantiates / detaches `held_ball`; sets its `speed` & `direction` based on `t` and `dir`. |

---

## Ball

### Variables

| Name | Type | Purpose |
|------|------|---------|
| `position`   | `Vector3` | Current centre of the sphere. |
| `speed`      | `Vector3` | Velocity magnitude & direction (`direction * speed_mag`). |
| `direction`  | `Vector3` | Normalised heading updated on bounce. |
| `radius`     | `float`   | Collision radius. |

### Methods

```text
ball_movement(delta: float)                 -> void
touching_boundary(next_pos: Vector3)        -> bool
apply_friction(delta: float)                -> void
```

| Method | Behaviour |
|--------|-----------|
| **ball_movement** | Integrates position each physics tick; checks for bounces & Target hits. |
| **touching_boundary** | Queries an Arena class for wall/floor intersection and returns `true` if bounce needed. |
| **apply_friction** | Reduces horizontal speed when `touching_boundary` was `true`. |

### Collaborators

* **Target** – collision sphere vs hit‑box test inside `ball_movement`.

---

## Target

### Variables

| Name | Type | Purpose |
|------|------|---------|
| `position`      | `Vector3` | World location. |
| `has_ball`      | `bool`    | Whether the entity is currently holding a ball. |
| `facing_dir`    | `Vector3` | Forward vector (for shield / block logic). |
| `hitbox_radius` | `float`   | Simplified spherical hit‑box. |

### Methods

```text
is_hit(ball_pos: Vector3, ball_radius: float) -> bool
```

*Returns `true` if distance ≤ `hitbox_radius + ball_radius`, triggering life loss / knockback.*

---

### Timing & Numbers (tuneable)

| Parameter | QUICK | AIM |
|-----------|-------|-----|
| Hold time              | <200 ms | ≥200 ms |
| Launch speed (m s⁻¹)    | 26      | 38 |
| Player slow multiplier  | 1.0     | 0.4 (during charge + 250 ms after) |
| Pump‑fake cooldown      | —       | 0.6 s |

---

