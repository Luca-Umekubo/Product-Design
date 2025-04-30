# PlayerCharacteristicsSpec.md

## 🔹 Part of the Design Being Laid Out

This spec covers the **player characteristics** related to physical presence, health, and hit detection. It corresponds to the visual flow:

```
[Player] ── has ──▶ [Hitbox]
       └── has ──▶ [HealthSystem]

[Ball] ── has ──────▶ [Hitbox]
       └── hits ────▶ [Player] (via Hitbox.isColliding)

[Hitbox] ── isColliding(other) ──▶ [Hitbox]
```

Relevant classes: `Player`, `Ball`, `Hitbox`, `HealthSystem` (implied)

---

## 🧩 Object: `Player`

### Expected Variables:
- `position: Vector3` – 3D position of the player.
- `rotation: Vector3` – Direction the player is facing.
- `hitbox: Hitbox` – Defines the player's collision volume.
- `health: HealthSystem` – Tracks player lives or HP.
- `isAlive: boolean` – If the player is still in play.
- `teamID: int` – For team-based rules.

### Expected Methods:
- `checkHit(other: Hitbox): boolean` – Tests if another object (ball) hits the player.
- `checkCollision(other: Hitbox): boolean` – General collision detection.
- `eliminate(): void` – Called when player is hit and removed from play.

### Related Objects:
- Has a `Hitbox` for collision.
- Has a `HealthSystem` to track lives.
- Interacts with `Ball` when hit.

---

## 🧩 Object: `Ball`

### Expected Variables:
- `state: BallState` – Enum: `inAir`, `ground`, `player`.
- `position: Vector3` – Ball's world position.
- `owner: Player` – Who currently possesses the ball.
- `hitbox: Hitbox` – Defines collision volume.

### Expected Methods:
- `checkCollision(): boolean` – Checks if ball collides with any object.
- `updatePosition(delta: float): void` – Moves ball in world space.

### Related Objects:
- Has a `Hitbox`.
- Calls `checkCollision` against player hitboxes.

---

## 🧩 Object: `Hitbox`

### Expected Variables:
- `center: Vector3` – Center of the hitbox in world coordinates.
- `size: Vector3` – Dimensions (width, height, depth).

### Expected Methods:
- `isColliding(other: Hitbox): boolean` – Checks overlap with another hitbox.
- `ballCollision(other: Hitbox): boolean` – Optional specialized logic for ball-to-player collision.

### Related Objects:
- Belongs to both `Player` and `Ball`.
- Compared using `Player.checkHit()` and `Ball.checkCollision()`.

---

## 🧩 Implied Object: `HealthSystem` NOT INCLUDED IN PHASE 1


### Suggested Fields:
- `lives: int`
- `isInvulnerable: boolean`

### Suggested Methods:
- `loseLife(): void`
- `isAlive(): boolean`

### Related Objects:
- Accessed by `Player` to track elimination.

---

## ✅ Summary of Key Interactions

- Each `Player` has a `Hitbox` and `HealthSystem`.
- `Ball` checks collision with `Player.hitbox`.
- `Player.checkHit()` uses `Hitbox.isColliding()` to determine hits.
- `Player.eliminate()` or `loseLife()` is triggered on valid hit.

This spec enables basic hit detection and health tracking in a 3D environment with simple bounding boxes.

