
## 2. Core Components

### 2.1 Player Movement Controller
The central system responsible for managing all player movement and physics interactions.

#### Variables:
- `rigidbody: Rigidbody` - Physics component for the player
- `collider: CapsuleCollider` - Collision shape for the player
- `movementSpeed: float` - Base movement speed (units per second)
- `sprintSpeed: float` - Faster movement speed when sprint is activated
- `acceleration: float` - Acceleration rate when changing direction (units per second²)
- `deceleration: float` - Deceleration rate when stopping (units per second²)
- `airControl: float` - Movement control factor while in air (0-1)
- `jumpForce: float` - Upward force applied when jumping (Newtons)
- `maxJumpHeight: float` - Maximum jump height (units)
- `coyoteTime: float` - Time window after leaving a platform where jump is still allowed (seconds)
- `jumpBufferTime: float` - Time window where jump input is buffered if pressed before landing (seconds)
- `groundCheckDistance: float` - Distance for ground detection rays (units)
- `groundLayers: LayerMask` - Layers considered as ground for collision detection
- `slopeLimit: float` - Maximum slope angle player can traverse (degrees)
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
- `SetState(PlayerMovementState newState)` - Change movement state
- `ApplyGroundMovement()` - Handle ground movement
- `ApplyAirMovement()` - Handle air movement
- `GroundCheck()` - Check if player is on ground
- `HandleSlopes()` - Handle movement on slopes
- `ApplyGravity()` - Apply custom gravity
- `GetMoveDirection()` - Get normalized movement direction
- `OnCollision(Collision collision)` - Handle collisions

### 2.2 Dodge System
System for managing dodge mechanics and timing windows.

#### Variables:
- `dodgeCooldown: float` - Cooldown time between dodges (seconds)
- `dodgeDuration: float` - Duration of dodge action (seconds)
- `dodgeDistance: float` - Distance covered during dodge (units)
- `dodgeSpeed: float` - Speed of dodge movement (units per second)
- `currentDodgeCooldown: float` - Current remaining cooldown (seconds)
- `dodgeDirections: Dictionary<DodgeAction, Vector3>` - Mapping of dodge inputs to movement vectors
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
- `SetDodgeInvulnerability(bool enabled)` - Toggle dodge invulnerability
- `GetDodgeVector(DodgeDirection direction)` - Get movement vector for dodge

### 2.3 Aim State Controller
System for managing the aiming state when the player is preparing to throw.

#### Variables:
- `isAiming: bool` - Whether player is currently in aim state
- `aimStateMovementFactor: float` - Movement speed factor in aim state (0-1)
- `aimStateGravityFactor: float` - Gravity factor in aim state (0-1)
- `aimStateMaxDuration: float` - Maximum duration of aim state (seconds)
- `currentAimTime: float` - Current time spent in aim state (seconds)
- `aimingFromAir: bool` - Whether aiming was initiated while airborne
- `originalVelocity: Vector3` - Velocity before entering aim state
- `hoverHeight: float` - Height maintained during hover
- `hoverStability: float` - How stable the hover is (less wobble)

#### Methods:
- `EnterAimState()` - Enter aiming state
- `ExitAimState()` - Exit aiming state
- `UpdateAimState()` - Update aim state timer and effects
- `HoverInAir()` - Suspend player in air during aim state
- `ReduceMovementSpeed()` - Apply movement speed reduction during aim
- `RestoreMovement()` - Restore normal movement parameters

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
- `inputSmoothingFactor: float` - Input smoothing for analog sticks

#### Methods:
- `ProcessInput()` - Process all input for current frame
- `GetMovementVector()` - Get processed movement vector
- `GetLookRotation()` - Get processed look rotation
- `BufferInput(InputCommand command)` - Store input for later processing
- `ProcessInputBuffer()` - Process buffered inputs
- `SmoothInput(Vector2 rawInput)` - Apply smoothing to raw input
- `MapDodgeDirection()` - Map current input to a dodge direction

### 2.5 Camera Controller
System for managing the player's first-person camera.

#### Variables:
- `camera: Camera` - Reference to the player's camera
- `lookSensitivity: Vector2` - Sensitivity for look input (x and y axes)
- `maxLookAngleUp: float` - Maximum upward look angle
- `maxLookAngleDown: float` - Maximum downward look angle
- `currentPitch: float` - Current pitch angle (looking up/down)
- `currentYaw: float` - Current yaw angle (looking left/right)
- `cameraSmoothing: float` - Smoothing factor for camera movement
- `headBobEnabled: bool` - Whether head bob effect is enabled
- `headBobFrequency: float` - Frequency of head bob
- `headBobAmplitude: float` - Amplitude of head bob
- `headBobSprintMultiplier: float` - Head bob multiplier when sprinting

#### Methods:
- `Initialize()` - Set up camera controller
- `UpdateCamera(Vector2 lookInput)` - Update camera based on look input
- `ProcessHeadBob(float moveSpeed)` - Apply head bob effect based on movement
- `SetFOV(float fov)` - Adjust camera field of view
- `CalculatePitchYaw(Vector2 lookInput)` - Calculate new pitch and yaw from input
- `ApplyCameraSway(float intensity)` - Apply slight camera sway for realism

## 3. Technical Implementation

### 3.1 Character Movement Implementation
Details on character controller implementation.

#### Variables:
- `rootMotion: bool` - Whether to use animation root motion
- `footstepDetectors: List<Transform>` - Points for footstep detection
- `environmentDetectors: List<Sensor>` - Sensors for detecting environment
- `movementStateTimer: Dictionary<PlayerMovementState, float>` - Timers for different states
- `momentumConservation: float` - How much momentum is conserved in direction changes
- `stepHeight: float` - Maximum height of step the player can automatically climb
- `slideThreshold: float` - Angle at which player begins to slide down slopes
- `maxGroundedVelocity: float` - Maximum velocity while grounded
- `maxAirVelocity: float` - Maximum velocity while in air

#### Methods:
- `ApplyRootMotion(Vector3 rootMotionDelta)` - Apply root motion from animation
- `UpdateAnimationState()` - Update animation based on movement
- `CalculateMovementVector()` - Calculate final movement vector
- `ApplyForce(Vector3 force)` - Apply an external force to the player
- `StepUpCheck()` - Check if player should step up over small obstacles
- `ClampVelocity(bool isGrounded)` - Clamp velocity based on grounded state
- `CalculateFriction()` - Calculate friction based on surface and movement

### 3.2 Special Movement States
Implementation of special movement states.

#### Variables:
- `knockbackResistance: float` - Resistance to knockback forces
- `timeDilation: float` - Time dilation during special states
- `stateTransitionSpeed: float` - How quickly player transitions between states
- `fallingThreshold: float` - Velocity threshold to enter falling state
- `landingRecoveryTime: float` - Time to recover after hard landing (seconds)
- `slideControlFactor: float` - How much control player has while sliding

#### Methods:
- `TransitionBetweenStates(PlayerMovementState from, PlayerMovementState to)` - Handle state transitions
- `ApplyStatePhysics()` - Apply physics modifications for current state
- `ExitSpecialState()` - Exit any special movement state
- `CalculateStateModifiers()` - Calculate modifiers based on current state
- `HandleLanding(float impactVelocity)` - Handle landing physics and effects
- `ApplyMovementPenalty(float duration, float factor)` - Apply temporary movement penalty

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

## 6. External Dependencies and Relationships

### 6.1 Game Systems Integration
- `PlayerController` - Main player controller that uses Movement System
- `GameStateManager` - Manages overall game state affecting movement
- `AudioManager` - Receives movement events for sound triggers (footsteps, landing)
- `VisualEffectsManager` - Receives movement events for visual effects
- `PowerUpManager` - Applies movement modifications for power-ups
- `AnimationController` - Receives movement state to drive animations
- `CameraSystem` - Integrates with first-person camera for movement effects
- `UIManager` - Receives movement state for UI feedback (dodge cooldown, etc.)

### 6.2 Animation System Integration
- Animation state machine driven by movement state
- Root motion feeding back to physics system when appropriate
- Procedural animation adjustments based on movement speed and direction
- IK systems for foot placement on uneven terrain
- Blend spaces for smooth transitions between movement states
- Animation events triggering movement effects (footstep sounds, particles)
- Pose matching for seamless transitions between states

## 7. Future Enhancements (Non-Core)
- Advanced movement abilities (wall running, sliding, mantling)
- Environmental interaction (swinging, climbing, vaulting)
- Procedural animation for more realistic movement
- Contextual movement based on environment
- Character-specific movement styles and abilities
- User-configurable movement parameters
- Accessibility options for movement control
- Advanced camera effects based on movement (motion blur, FOV changes)
- Physics-based character customization that affects movement