# Movement Physics Spec

_Laying out **movement physics** – this lives under the **Features basic overview** bullet in the game ReadMe (“fluid movement, making a responsive and quick game”).  

---

## Class Overview

| Class | Responsibility | Relationship |
|-------|----------------|--------------|
| **Player**   | Stores physical state (position, velocity, etc.). | • Composes **Movement**<br>• Talks to **GameWorld** for collision/ground checks |
| **Movement** | Converts raw input into acceleration & jump impulses. | • Writes into owning **Player** |
**DodgeController** handles the dodging system based on the movement from player class
**AimState** Handles iming based on player classs and changes physics due to aiming state
**InputHandler** Balances the player inputs and correlates them to changes in the player physics






## 2. Core Components

### 2.1 Player 
The central system responsible for managing all player movement and physics interactions.

#### Variables:
- `rigidbody: Rigidbody` - Physics component for the player
- `movementSpeed: float` - Base movement speed (units per second)
- `sprintSpeed: float` - Faster movement speed when sprint is activated
- `velocity: Vector3` - Current velocity vector
- `input: Vector2` - Raw movement input from player
- `facingDirection: Vector3` - Direction player is facing
- `playerState: PlayerMovementState` - Current movement state (idle, running, jumping, etc.)
| Name | Type | Purpose |
|------|------|---------|
| `position`      | `Vector3` | World‑space location |
| `acceleration`  | `Vector3` | Per‑frame xy acceleration |
| `max_velocity`  | `Vector3` | Clamp for top speed / terminal fall |
| `height`        | `int`     | Player height (affected by `duck`) |
| `gravity`       | `float`   | Down‑ward acceleration (m s⁻²) |

#### Methods:
- `ProcessMovementInput(Vector2 input)` - Process raw input into movement
- `Jump()` - Initiate jump
- `SetState(PlayerMovementState newState)` - Change movement state
- `ApplyGroundMovement()` - Handle ground movement
-  duck()                                 -> void
- change_position_z(vel: Vector3)        -> void
- change_speed_xy(fwd: Vector3,
                left: Vector3,
                right: Vector3,
                back: Vector3)         -> void
- change_position_xy(speed: Vector3)     -> void
- change_velocity_z(gravity: float)      -> void

| Method | Behaviour |
|--------|-----------|
| **duck** | Toggles crouch; shrinks/expands `height`. |
| **change_position_z** | Integrates vertical motion into `position`. |
| **change_speed_xy** | Adds input‑driven acceleration to the `velocity` variable, respecting `max_velocity` as the maximum velocity, at which point velocity stays constant |
| **change_position_xy** | Translates `position.xz` based on current `velocity`. |
| **change_velocity_z** | Applies gravity acceleration downwards each physics tick until grounded. |


### 2.2 Dodge System
System for managing dodge mechanics and timing windows.

#### Variables:
- `dodgeCooldown: float` - Cooldown time between dodges (seconds)
- `dodgeDuration: float` - Duration of dodge action (seconds)
- `dodgeDistance: float` - Distance covered during dodge (units)
- `dodgeSpeed: float` - Speed of dodge movement (units per second)
- `currentDodgeCooldown: float` - Current remaining cooldown (seconds)
movement vectors
- `canDodge: bool` - Whether player can currently dodge
- `isDodging: bool` - Whether player is currently dodging
- `dodgeInvulnerabilityTime: float` - Brief invulnerability window during dodge (seconds)
- `perfectDodgeWindow: float` - Timing window for perfect dodge (seconds)
- `dodgeType: DodgeType` - Type of dodge performed (regular, perfect)

#### Methods:
- `PerformDodge(DodgeDirection direction)` - Execute dodge action
- `StartDodge()` - Begin dodge movement and effects
- `EndDodge()` - End dodge state
- `UpdateDodgeCooldown()` - Update dodge cooldown timer
- `CheckPerfectDodgeTiming()` - Check for perfect dodge timing
- `ApplyDodgeMovement()` - Apply dodge movement physics

### 2.3 Aim State Controller
System for managing the aiming state when the player is preparing to throw.

#### Variables:
- `isAiming: bool` - Whether player is currently in aim state
- `aimStateMaxDuration: float` - Maximum duration of aim state (seconds)
- `currentAimTime: float` - Current time spent in aim state (seconds)
- `aimingFromAir: bool` - Whether aiming was initiated while airborne
- `originalVelocity: Vector3` - Velocity before entering aim state
- `hoverHeight: float` - Height maintained during hover

#### Methods:
- `EnterAimState()` - Enter aiming state
- `ExitAimState()` - Exit aiming state
- `UpdateAimState()` - Update aim state timer and effects
- `HoverInAir()` - Suspend player in air during aim state

### 2.4 Input Handler
System managing player input for movement and actions.

#### Variables:
- `moveInput: Vector2` - Raw movement input vector
- `lookInput: Vector2` - Raw look/aim input vector
- `jumpInput: bool` - Jump button state
- `sprintInput: bool` - Sprint button state
- `dodgeInput: bool` - Dodge button state
- `aimInput: bool` - Aim button state
- `throwInput: bool` - Throw button state
- `inputBuffer: Queue<InputCommand>` - Buffer for stored inputs
- `inputBufferTime: float` - How long inputs are stored in buffer (seconds)

#### Methods:
- `ProcessInput()` - Process all input for current frame
- `ProcessInputBuffer()` - Process buffered inputs

### 2.5 Movement
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


## 4. Process Flows

### 4.1 Player Movement Flow
1. Input received from player controller
2. Input Handler processes and buffers input
3. Player Movement Controller receives processed input
4. Ground check performed to determine player state
5. If grounded, ground movement applied, else air movement applied
6. Special states like aiming or dodging are given priority
7. Movement vector calculated based on input and current state
8. Physics simulation applies resulting forces
9. Collisions are resolved
10. Animation state updated based on movement
11. Camera position and effects updated

### 4.2 Jump Flow
1. Jump input detected by Input Handler
2. Player Movement Controller checks if jump is possible:
   - Player is grounded or within coyote time
   - Jump is not on cooldown
3. If jump is valid, vertical force is applied
4. Player state changes to jumping
5. Jump animation is triggered
6. Air control parameters are applied
7. Gravity is constantly applied, with increased fall multiplier on descent
8. Ground check runs continuously to detect landing
9. On landing, ground state is restored and landing effects triggered

### 4.3 Dodge Flow
1. Dodge input detected by Input Handler
2. Dodge direction determined from movement input
3. Dodge System checks if dodge is available:
   - Not on cooldown
   - Player is in valid state
4. If dodge is valid, Dodge System initiates dodge sequence:
   - Original movement temporarily overridden
   - Dodge direction vector calculated
   - Dodge force applied
   - Brief invulnerability window applied
   - Dodge animation triggered
5. After dodge duration, regular movement restored
6. Cooldown timer started
7. Player state returned to normal

### 4.4 Aim State Flow
1. Aim input detected by Input Handler
2. Aim State Controller checks if aiming is possible:
   - Player has a ball
   - Not in incompatible state
3. If aiming is valid, enter aim state:
   - Movement speed reduced
   - If in air, gravity reduced and hover effect applied
   - Camera FOV slightly adjusted
   - Aim animation/stance activated
4. During aim state:
   - Look input controls aim direction
   - Movement still possible but limited
   - Charge indicator increases if throw input held
5. On throw input release:
   - Exit aim state
   - Return to normal movement parameters
   - Camera returns to normal
6. On aim cancel:
   - Exit aim state without throwing
   - Return to normal movement parameters

## 5. Performance Considerations

### 5.1 Physics Optimization
- Use simplified collision meshes for player character
- Implement physics layers to limit unnecessary collision checks
- Optimize raycasts with layermasks
- Use sphere casts for ground detection instead of multiple raycasts
- Cache physics results where appropriate
- Consider using capsule colliders for better performance
- Use continuous collision detection only when necessary (high-speed movement)

### 5.2 CPU Optimization
- Batch physics queries where possible
- Limit physics calculations on non-essential components
- Cache frequently used physics data
- Use fixed time step carefully to balance performance and accuracy
- Consider different update rates for various systems (input = every frame, physics = fixed update)
- Profile and optimize common movement scenarios
- Use object pooling for effects that occur frequently (footsteps, landing effects)

### 5.3 Networked Player Movement
- Implement client-side prediction for responsive feel
- Server authority for final position determination
- Interpolation for smooth movement between updates
- Jitter buffer for movement state synchronization
- Prioritize important state changes (dodge, aim, jump)
- Use delta compression for movement updates
- Consider dead reckoning for prediction during packet loss



## 6. Future Enhancements (Non-Core)
- Advanced movement abilities (wall running, sliding, mantling)
- Environmental interaction (swinging, climbing, vaulting)
- Procedural animation for more realistic movement
- Contextual movement based on environment
- Character-specific movement styles and abilities
- User-configurable movement parameters
- Accessibility options for movement control
- Advanced camera effects based on movement (motion blur, FOV changes)
- Physics-based character customization that affects movement