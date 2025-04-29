
## 2. Core Physics Components

### 2.1 Physics Manager
The central system responsible for overseeing all physics interactions in the game.

#### Variables:
- `physicsTimeStep: float` - Fixed time step for physics calculations (typically 0.02 seconds)
- `gravityStrength: Vector3` - Gravity vector affecting players and balls
- `physicsLayers: Dictionary<string, int>` - Physics layer mappings for collision filtering
- `physicsMaterials: Dictionary<string, PhysicsMaterial>` - Different material types for surfaces
- `collisionMatrix: bool[,]` - Matrix defining which layers collide with each other
- `simulationSpeed: float` - Current speed of physics simulation (used for time slow power-up)
- `normalSimulationSpeed: float` - Default simulation speed
- `slowedSimulationSpeed: float` - Slowed simulation speed for power-ups

#### Methods:
- `Initialize()` - Set up physics system
- `SetGravity(Vector3 gravity)` - Modify gravity vector
- `SetTimeScale(float timeScale)` - Adjust physics simulation speed
- `RegisterCollisionHandler(GameObject obj, ICollisionHandler handler)` - Register collision callbacks
- `CreatePhysicsObject(GameObject obj, PhysicsObjectType type)` - Initialize physics for an object
- `ApplyKnockback(Rigidbody target, Vector3 direction, float force)` - Apply knockback to an object
- `CheckGrounded(Transform transform, float distance)` - Check if an object is grounded
- `SimulateTrajectory(Vector3 startPos, Vector3 velocity, int steps)` - Calculate projectile trajectory
- `GetBounceDirection(Vector3 incomingDir, Vector3 surfaceNormal)` - Calculate bounce reflection

### 2.2 Player Movement Controller
System managing player character movement and physics.

#### Variables:
- `rigidbody: Rigidbody` - Physics component for the player
- `collider: CapsuleCollider` - Collision shape for the player
- `movementSpeed: float` - Base movement speed
- `sprintSpeed: float` - Faster movement speed
- `acceleration: float` - Acceleration rate when changing direction
- `deceleration: float` - Deceleration rate when stopping
- `airControl: float` - Movement control factor while in air (0-1)
- `jumpForce: float` - Upward force applied when jumping
- `maxJumpHeight: float` - Maximum jump height
- `coyoteTime: float` - Time window after leaving a platform where jump is still allowed
- `jumpBufferTime: float` - Time window where jump input is buffered if pressed before landing
- `groundCheckDistance: float` - Distance for ground detection rays
- `groundLayers: LayerMask` - Layers considered as ground
- `slopeLimit: float` - Maximum slope angle player can traverse
- `friction: float` - Ground friction coefficient
- `airDrag: float` - Air resistance coefficient
- `gravity: float` - Custom gravity scale for player
- `fallMultiplier: float` - Increases gravity when falling for better feel
- `isGrounded: bool` - Whether player is on ground
- `isJumping: bool` - Whether player is actively jumping
- `isSprinting: bool` - Whether player is sprinting
- `velocity: Vector3` - Current velocity vector
- `input: Vector2` - Raw movement input from player
- `facingDirection: Vector3` - Direction player is facing
- `playerState: PlayerMovementState` - Current movement state (idle, running, jumping, etc.)

#### Methods:
- `Initialize()` - Set up player movement controller
- `ProcessMovementInput(Vector2 input)` - Process raw input into movement
- `UpdateMovement()` - Apply movement physics
- `Jump()` - Initiate jump
- `Dodge(DodgeDirection direction)` - Perform dodge action
- `SetState(PlayerMovementState newState)` - Change movement state
- `ApplyGroundMovement()` - Handle ground movement
- `ApplyAirMovement()` - Handle air movement
- `GroundCheck()` - Check if player is on ground
- `HandleSlopes()` - Handle movement on slopes
- `ApplyGravity()` - Apply custom gravity
- `EnterAimState()` - Enter ball aiming state
- `ExitAimState()` - Exit ball aiming state
- `HoverInAir()` - Suspend player in air during aim state
- `ReduceMovementSpeed(float factor)` - Reduce movement speed (for aim state)
- `GetMoveDirection()` - Get normalized movement direction
- `OnCollision(Collision collision)` - Handle collisions

### 2.3 Ball Physics Controller
System managing dodgeball physics behavior.

#### Variables:
- `rigidbody: Rigidbody` - Physics component for the ball
- `collider: SphereCollider` - Collision shape for the ball
- `bounciness: float` - Bounciness coefficient
- `drag: float` - Air resistance
- `mass: float` - Ball mass
- `throwSpeed: float` - Base throw speed
- `quickThrowSpeedMultiplier: float` - Speed multiplier for quick throws
- `chargedThrowSpeedMultiplier: float` - Speed multiplier for charged throws
- `ultimateThrowSpeedMultiplier: float` - Speed multiplier for ultimate throws
- `knockbackForce: float` - Force applied to players when hit
- `catchWindow: float` - Time window for catching after teammate hit
- `currentState: BallState` - Current state (idle, thrown, held, etc.)
- `ownerTeam: Team` - Team that last touched the ball
- `lastThrownBy: Player` - Player who last threw the ball
- `throwDirection: Vector3` - Direction the ball was thrown
- `throwVelocity: Vector3` - Velocity vector of throw
- `heldTime: float` - Time ball has been held by current player
- `maxHoldTime: float` - Maximum allowed hold time before auto-transfer
- `isPoweredUp: bool` - Whether ball has power-up effects
- `trailRenderer: TrailRenderer` - Visual trail following the ball
- `collisionLayers: LayerMask` - Layers ball can collide with

#### Methods:
- `Initialize()` - Set up ball physics
- `Throw(Vector3 direction, float chargeLevel, bool isUltimate)` - Throw ball with parameters
- `QuickThrow(Vector3 direction)` - Perform quick throw
- `Bounce(Vector3 normal)` - Handle ball bounce
- `OnHit(Player hitPlayer)` - Process hit on player
- `BePickedUp(Player player)` - Handle ball pickup
- `BeDropped()` - Handle ball being dropped
- `UpdatePhysics()` - Update ball physics state
- `ApplyGravity()` - Apply gravity to ball
- `CheckBoundaries()` - Keep ball within arena boundaries
- `ApplyKnockback(Player player)` - Apply knockback to hit player
- `EnableTrail(bool enabled)` - Enable/disable visual trail
- `SetPowerUpEffect(PowerUpType powerUp)` - Apply power-up effect to ball
- `ResetState()` - Reset ball to default state
- `OnCollision(Collision collision)` - Handle collision events

### 2.4 Dodge and Counter System
System for managing dodge mechanics and timing windows.

#### Variables:
- `dodgeCooldown: float` - Cooldown time between dodges
- `dodgeDuration: float` - Duration of dodge action
- `dodgeDistance: float` - Distance covered during dodge
- `dodgeSpeed: float` - Speed of dodge movement
- `currentDodgeCooldown: float` - Current remaining cooldown
- `dodgeDirections: Dictionary<DodgeAction, Vector3>` - Mapping of dodge inputs to movement vectors
- `canDodge: bool` - Whether player can currently dodge
- `isDodging: bool` - Whether player is currently dodging
- `dodgeInvulnerabilityTime: float` - Brief invulnerability window during dodge
- `perfectDodgeWindow: float` - Timing window for perfect dodge
- `dodgeType: DodgeType` - Type of dodge performed (regular, perfect)

#### Methods:
- `PerformDodge(DodgeDirection direction)` - Execute dodge action
- `StartDodge()` - Begin dodge movement and effects
- `EndDodge()` - End dodge state
- `UpdateDodgeCooldown()` - Update dodge cooldown timer
- `CheckPerfectDodgeTiming(Ball incomingBall)` - Check for perfect dodge timing
- `ApplyDodgeMovement()` - Apply dodge movement physics
- `SetDodgeInvulnerability(bool enabled)` - Toggle dodge invulnerability
- `GetDodgeVector(DodgeDirection direction)` - Get movement vector for dodge

### 2.5 Showdown System
System for managing quick-time event style dodgeball confrontations.

#### Variables:
- `isInShowdown: bool` - Whether showdown is active
- `showdownTimeScale: float` - Time scale during showdown (slow-mo)
- `showdownDuration: float` - Maximum duration of showdown
- `attacker: Player` - Player throwing the ball
- `defender: Player` - Player attempting to dodge
- `successWindow: float` - Time window for successful dodge input
- `showdownCamera: Camera` - Special camera for showdown moments
- `cameraTransitionSpeed: float` - Speed of camera transition to showdown view

#### Methods:
- `InitiateShowdown(Player attacker, Player defender)` - Start showdown sequence
- `EndShowdown()` - End showdown and return to normal gameplay
- `ProcessAttackerInput(bool inputReceived)` - Handle attacker's throw timing
- `ProcessDefenderInput(DodgeDirection direction)` - Handle defender's dodge input
- `EvaluateShowdownResult()` - Determine outcome of showdown
- `TransitionToShowdownCamera()` - Change camera to showdown view
- `RestoreNormalCamera()` - Return to normal camera view
- `SlowDownTime()` - Activate slow-motion effect
- `RestoreNormalTime()` - Return to normal time scale

## 3. Technical Implementation

### 3.1 Character Movement Implementation
Details on character controller implementation.

#### Variables:
- `inputBuffer: Queue<InputCommand>` - Buffer for stored inputs
- `smoothingFactor: float` - Input smoothing for analog sticks
- `rootMotion: bool` - Whether to use animation root motion
- `footstepDetectors: List<Transform>` - Points for footstep detection
- `environmentDetectors: List<Sensor>` - Sensors for detecting environment
- `movementStateTimer: Dictionary<PlayerMovementState, float>` - Timers for different states
- `momentumConservation: float` - How much momentum is conserved in direction changes

#### Methods:
- `ApplyRootMotion(Vector3 rootMotionDelta)` - Apply root motion from animation
- `SmoothInput(Vector2 rawInput)` - Apply smoothing to raw input
- `ProcessInputBuffer()` - Process buffered inputs
- `BufferInput(InputCommand command)` - Store input for later processing
- `UpdateAnimationState()` - Update animation based on movement
- `CalculateMovementVector()` - Calculate final movement vector

### 3.2 Ball Physics Implementation
Details on ball physics implementation.

#### Variables:
- `velocityRetention: float` - Percentage of velocity retained after bounce
- `spinFactor: float` - How much spin affects trajectory
- `windupTime: float` - Time to reach maximum throw power
- `velocityPredictionSteps: int` - Steps used in trajectory prediction
- `throwAngleVariance: float` - Small random variance in throw angle
- `ballSleepVelocity: float` - Velocity below which ball goes to sleep
- `audioVelocityThresholds: float[]` - Velocity thresholds for different bounce sounds

#### Methods:
- `CalculateThrowPower(float chargeTime)` - Calculate throw power based on charge time
- `ApplySpin(Vector3 spinAxis, float spinPower)` - Apply spin to ball
- `PredictTrajectory()` - Predict and visualize ball trajectory
- `UpdateBallState()` - Update ball state machine
- `ProcessBoundaryCollision(Vector3 collisionPoint)` - Handle boundary collisions
- `SnapToBallPoint(Transform hand)` - Snap ball to player's hand

### 3.3 Special Movement States
Implementation of special movement states.

#### Variables:
- `aimStateMovementFactor: float` - Movement speed factor in aim state
- `aimStateGravityFactor: float` - Gravity factor in aim state
- `aimStateMaxDuration: float` - Maximum duration of aim state
- `hoverHeight: float` - Height maintained during hover
- `hoverStability: float` - How stable the hover is (less wobble)
- `knockbackResistance: float` - Resistance to knockback forces
- `timeDilation: float` - Time dilation during special states

#### Methods:
- `EnterAimState()` - Enter aiming state
- `MaintainHover()` - Maintain hover position/height
- `ExitSpecialState()` - Exit any special movement state
- `TransitionBetweenStates(PlayerMovementState from, PlayerMovementState to)` - Handle state transitions
- `ApplyStatePhysics()` - Apply physics modifications for current state

## 4. Process Flows

### 4.1 Player Movement Flow
1. Input received from player controller
2. `PlayerMovementController.ProcessMovementInput()` receives input
3. If grounded, `ApplyGroundMovement()` is called
4. If in air, `ApplyAirMovement()` is called with reduced control
5. `GroundCheck()` updates grounded state
6. `ApplyGravity()` applies appropriate gravity based on state
7. State machine updates current movement state
8. Physics simulation applied through Rigidbody
9. Animation system updated with current velocity and state

### 4.2 Jump and Dodge Flow
1. Jump button pressed
2. System checks if player can jump (grounded or within coyote time)
3. If yes, `Jump()` method applies vertical force
4. State changes to jumping
5. For dodge, system checks if dodge is available and not on cooldown
6. `PerformDodge()` called with direction parameter
7. Player movement temporarily overridden with dodge vector
8. Invulnerability briefly applied
9. Cooldown timer started
10. Animation triggers for dodge action

### 4.3 Ball Throw Flow
1. Player enters aim state via `EnterAimState()`
2. Movement limited, possibly hovering in air
3. Player aims using look controls
4. On throw button press, ball charge begins
5. Charge level increases over time
6. On button release, `BallPhysicsController.Throw()` called with parameters
7. Ball transitions to thrown state
8. Physics applies velocity in throw direction
9. Trail renderer activated
10. Collision detection enabled

### 4.4 Ball Hit and Catch Flow
1. Ball collides with player
2. `BallPhysicsController.OnCollision()` detects player hit
3. System checks if player is on same team as last thrower
4. If opponent hit, player loses life and ball bounces
5. Ball bounces in random direction at reduced speed
6. Catch window timer starts for teammate catch opportunity
7. If teammate catches within window via `OnCollision()`, original thrower loses life
8. Catch event triggers life restoration for previously hit teammate if applicable

### 4.5 Showdown QTE Flow
1. Conditions met for showdown (direct aim at player for certain time)
2. `ShowdownSystem.InitiateShowdown()` called with both players
3. Camera transitions to showdown view
4. Time slows down
5. UI prompts appear for both players
6. Attacker and defender input windows activate
7. Inputs processed through respective methods
8. Outcome determined by `EvaluateShowdownResult()`
9. Result animation plays
10. Normal gameplay resumes via `EndShowdown()`

## 5. Performance Considerations

### 5.1 Physics Optimization
- Use simplified collision meshes for players and environment
- Implement physics LOD based on distance
- Disable simulation for objects far from action
- Use physics layers to limit unnecessary collision checks
- Implement sub-stepping for fast-moving objects
- Optimize raycasts with layermasks

### 5.2 CPU Optimization
- Batch physics queries where possible
- Use multithreading for trajectory prediction
- Implement spatial partitioning for collision detection
- Limit physics calculations on non-essential objects
- Cache frequently used physics data
- Use fixed time step carefully to balance performance and accuracy

### 5.3 Networked Physics
- Implement client-side prediction for responsive feel
- Server authority for critical physics interactions
- Interpolation for smooth movement between updates
- Jitter buffer for physics state synchronization
- Bandwidth-efficient physics state serialization
- Prioritize synchronization of near/relevant objects

## 6. External Dependencies and Relationships

### 6.1 Game Systems Integration
- `PlayerController` - Takes input and communicates with Movement Controller
- `GameStateManager` - Manages overall game state affecting physics (time slow power-up)
- `AudioManager` - Receives collision/movement events for sound triggers
- `PowerUpManager` - Applies physics modifications for power-ups
- `UIManager` - Receives physics state for UI updates
- `ReplaySystem` - Records physics state for replay functionality

### 6.2 Animation System Integration
- Animation state machine driven by physics state
- Root motion feeding back to physics system
- Procedural animation adjustments based on surface angle
- IK systems for foot placement and ball holding
- Blend spaces for smooth transitions between movement states
- Animation events triggering physics effects

## 7. Future Enhancements (Non-Core)
- Advanced cloth physics for character outfits
- Destructible environment elements
- Weather effects influencing physics (wind, etc.)
- Advanced ragdoll on elimination
- Physics-based character customization (hats, accessories that react to movement)
- Replays with physics debug visualization
- Custom gravity zones as map features