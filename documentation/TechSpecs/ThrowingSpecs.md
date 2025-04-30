# ThrowingSpec.md

## 🔹 Part of the Design Being Laid Out

This spec covers the **throwing mechanics** in the dodgeball game. It corresponds to the flow:

```
[Player] ──▶ throws ──▶ [Ball] ──▶ moves_with ──▶ [Physics]
       
        uses
         
     [TypeOfThrow] ──▶ affects ──▶ [Ball]
```

Relevant classes from the diagram: `Player`, `Ball`, `TypeOfThrow`, `Physics`

---

## 🧩 Object: `Player`

### Expected Variables:
- `hasBall: boolean` – Whether the player currently holds the ball.
- `position: Vector3` – Current location of the player.
- `teamID: int` – (Optional) Player's team ID.

### Expected Methods:
- `ThrowBall(type: TypeOfThrow): void` – Initiates the throw using a specified throw type.

### Related Objects:
- Owns and throws a `Ball`.
- Uses a `TypeOfThrow` to determine how to throw.

---

## 🧩 Object: `Ball`

### Expected Variables:
- `state: BallState` – Enum: `inAir`, `ground`, `onPlayer`.
- `position: Vector3` – Current ball position.
- `owner: Player` – Who currently owns the ball.
- `hitbox: float` – Simplified collision radius.

### Expected Methods:
- `checkCollision(): bool` – Checks if ball collides with another object.
- `updatePosition(delta: float): void` – Updates ball's location each frame.

### Related Objects:
- Receives force from `TypeOfThrow`.
- Moved via `Physics` methods.

---

## 🧩 Object: `TypeOfThrow`

### Expected Variables:
- `speed: float` – How fast the ball travels.
- `accuracy: float` – Chance that throw stays on trajectory.

### Expected Methods:
- `calculateTrajectory(target: Vector3): Vector3` – Outputs a velocity vector to hit target.
- `ApplyThrow(ball: Ball): void` – Applies calculated velocity to the ball.

### Related Objects:
- Used by `Player` to throw.
- Affects `Ball` with force vector.

---

## 🧩 Object: `Physics`

### Expected Variables:
- `gravity: float` – Downward force on the ball.

### Expected Methods:
- `ApplyForce(ball: Ball, force: Vector3): void` – Adds a velocity/force to the ball.
- `+ method(type): type` – Placeholder for future physics extensions (e.g. friction, spin).

### Related Objects:
- Acts on `Ball` when it is in air.

---

## ✅ Summary of Key Interactions

- Player uses `TypeOfThrow` to apply velocity to a `Ball`.
- `Ball` is moved by `Physics`, simulating trajectory.
- Collision can be checked using `Ball.checkCollision()`.

The above definitions and relationships provide all basic functionality for a working throw mechanic in a 3D dodgeball game.

