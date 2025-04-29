# Technical Specification: Map System for Chaos DodgeBall

## 1. Overview
This document outlines the technical specifications for the Map System in *Chaos DodgeBall*, a fast-paced, first-person multiplayer dodgeball game developed in Godot 4. The Map System handles the creation, rendering, and management of arena environments, including raised platforms, dynamic obstacles, and thematic variations, to support fluid gameplay, strategic depth, and visual appeal.

## 2. Scope
The Map System includes:
- Arena structure (raised platform with void below, neon-lit aesthetics).
- Dynamic map features (e.g., moving platforms, destructible elements, themed obstacles).
- Integration with gameplay mechanics (e.g., ball physics, player spawning, spectator zones).
- Support for map variations and modifiers (e.g., low gravity, trampoline floors).
- Asset specifications for environmental elements, obstacles, and dodgeballs.

## 3. Requirements
### 3.1 Functional Requirements
- **FR1**: Maps consist of a raised platform (default size: 50x30 Godot units) with a void below, surrounded by a neon-lit arena boundary.
- **FR2**: Each map has a central dividing line for team-based modes, with spawn points on opposite ends.
- **FR3**: Maps support dynamic features (e.g., moving platforms, trees, bounce pads) that activate based on game modifiers or timers.
- **FR4**: Maps include invisible walls to contain dodgeballs while allowing players to fall off the platform.
- **FR5**: Maps support spectator zones (invisible platforms or free-fly cameras) for eliminated players.
- **FR6**: Maps integrate with ball spawning (center line for team modes, center pile for battle royale).
- **FR7**: Maps support environmental events (e.g., low gravity, disappearing floors) triggered by game modifiers.
- **FR8**: Maps render with thematic variations (e.g., space, aquatic) using consistent asset pipelines.

### 3.2 Non-Functional Requirements
- **NFR1**: Maps must render at 60 FPS on target platforms (PC, potentially consoles).
- **NFR2**: Map loading time must be <2 seconds for seamless match starts.
- **NFR3**: Maps must be modular to allow easy addition of new arenas or themes.
- **NFR4**: Collision detection must be precise to prevent physics glitches (e.g., balls clipping through walls).
- **NFR5**: Maps must support multiplayer synchronization with minimal network overhead.

## 4. Technical Design
### 4.1 Architecture
- **Primary Component**: `Arena` (Godot Node3D scene) serves as the root node for each map, containing sub-nodes for platform, obstacles, spawn points, and visual effects.
- **Dependencies**:
  - Godot’s PhysicsServer3D for collision and ball physics.
  - MultiplayerSynchronizer for networked gameplay.
  - VisualServer for neon-lit shaders and particle effects.
- **Node Hierarchy**:
  - `Arena` (Node3D)
    - `Platform` (StaticBody3D) – Main playable area.
    - `Obstacles` (Node3D) – Container for dynamic/static obstacles (e.g., trees, bounce pads).
    - `SpawnPoints` (Node3D) – Markers for player and ball spawns.
    - `SpectatorZone` (Node3D) – Invisible platform or camera system for spectators.
    - `VisualEffects` (Node3D) – Neon lights, particle systems, and thematic visuals.
    - `InvisibleWalls` (StaticBody3D) – Contains dodgeballs within the arena.
- **Asset Pipeline**:
  - 3D models (.gltf or .fbx) for platforms, obstacles, and decorations.
  - Materials with neon-lit shaders for thematic visuals.
  - Collision shapes generated from models or manually defined for precision.

### 4.2 Data Model
- **Map Configuration** (Resource file, e.g., `map_config.tres`):
  - `name`: String – Map name (e.g., “Neon Nexus”).
  - `theme`: String – Theme identifier (e.g., “space”, “aquatic”).
  - `platform_size`: Vector3 – Dimensions of the platform (default: 50x2x30).
  - `spawn_points`: Array[Vector3] – Team and ball spawn locations.
  - `obstacles`: Array[Dictionary] – List of obstacles with properties (type, position, dynamic).
  - `modifier_support`: Array[String] – Supported modifiers (e.g., “low_gravity”, “trampoline”).
- **Obstacle Properties**:
  - `type`: String – Obstacle type (e.g., “tree”, “bounce_pad”).
  - `position`: Vector3 – World position.
  - `is_dynamic`: Bool – Whether the obstacle moves or changes state.
  - `script`: Script – Custom behavior (e.g., `BouncePad.gd` for spring-like behavior).

### 4.3 Implementation Details
- **Platform Setup**:
  - Use a `StaticBody3D` with a `BoxShape3D` for the main platform.
  - Apply a material with a neon-edged shader (e.g., emissive outline) for visual appeal.
  - Position platform at y=0, with a `VoidArea` (Area3D) below (y=-10) to detect player falls and eliminate them.
- **Dynamic Obstacles**:
  - Implement as `RigidBody3D` or `StaticBody3D` with attached scripts for behavior.
  - Example: `BouncePad` applies an upward impulse to players/balls on collision.
  - Moving platforms use `AnimationPlayer` or `Tween` for smooth motion (e.g., oscillating trees).
- **Ball Containment**:
  - Use `StaticBody3D` with `BoxShape3D` around the arena edges, set to a specific collision layer (`BallOnly`).
  - Balls (`RigidBody3D`) collide only with `BallOnly` layer to prevent falling off.
- **Spawn Points**:
  - Use `Marker3D` nodes for team spawns (e.g., 4 per team for 4v4) and ball spawns (center line).
  - For battle royale, distribute spawns evenly around the platform edge.
- **Spectator Zones**:
  - Option 1: Invisible `StaticBody3D` platform at y=10, with a `CollisionShape3D` to allow spectators to walk.
  - Option 2: Free-fly camera system using `Camera3D` with input-based movement (like Minecraft spectator mode).
  - Spectators detect ball catches via `Area3D` triggers on the platform edges.
- **Modifiers and Events**:
  - Implement modifiers as scripts attached to the `Arena` node (e.g., `LowGravity.gd` adjusts `PhysicsServer3D` gravity).
  - Use `Timer` nodes to trigger events with a 5-second countdown UI notification.
  - Example: `DisappearingFloors` toggles `CollisionShape3D` visibility with red outline particles.
- **Asset Specifications**:
  - **Platform**: 50x30x2 units, low-poly mesh with neon-edged material.
  - **Obstacles**: Modular assets (e.g., tree: 2x5x2 units, bounce pad: 3x0.5x3 units) with collision shapes.
  - **Dodgeball**: Spherical `RigidBody3D` (radius: 0.3 units), mass=0.5, with dynamic material for trails (yellow-to-red based on velocity).
  - **Player Model**: Humanoid rig (height: 1.8 units), with first-person camera at eye level (y=1.6).
  - **Neon Effects**: Use `OmniLight3D` and `GPUParticles3D` for glowing outlines and thematic ambiance.

### 4.4 Sample Code
```gdscript
# Arena.gd
extends Node3D

@export var map_config: Resource
@onready var platform = $Platform
@onready var obstacles = $Obstacles
@onready var spawn_points = $SpawnPoints
@onready var spectator_zone = $SpectatorZone

func _ready():
    load_map_config()
    setup_dynamic_obstacles()
    setup_ball_walls()
    setup_event_timers()

func load_map_config():
    platform.scale = map_config.platform_size
    for spawn in map_config.spawn_points:
        var marker = Marker3D.new()
        marker.global_position = spawn
        spawn_points.add_child(marker)

func setup_dynamic_obstacles():
    for obstacle_data in map_config.obstacles:
        var obstacle = load(obstacle_data.type + ".tscn").instantiate()
        obstacle.global_position = obstacle_data.position
        if obstacle_data.is_dynamic:
            obstacle.set_script(load(obstacle_data.script))
        obstacles.add_child(obstacle)

func setup_ball_walls():
    var wall = StaticBody3D.new()
    var collision = CollisionShape3D.new()
    collision.shape = BoxShape3D.new()
    collision.shape.extents = Vector3(55, 10, 35) # Slightly larger than platform
    wall.collision_layer = 1 << 2 # BallOnly layer
    wall.add_child(collision)
    add_child(wall)

func trigger_modifier(modifier_name: String):
    match modifier_name:
        "low_gravity":
            PhysicsServer3D.set_gravity(Vector3(0, -2.0, 0))
            await get_tree().create_timer(10.0).timeout
            PhysicsServer3D.set_gravity(Vector3(0, -9.8, 0))
        "trampoline":
            platform.get_node("CollisionShape3D").set_script(load("Trampoline.gd"))
```

## 5. Testing Plan
- **Unit Tests**:
  - Verify platform dimensions match `map_config.platform_size`.
  - Confirm spawn points are correctly positioned for team and battle royale modes.
  - Test obstacle scripts (e.g., bounce pad applies correct impulse).
- **Integration Tests**:
  - Ensure balls stay within invisible walls but players can fall off.
  - Validate spectator zone allows ball catching without affecting active gameplay.
  - Test modifier triggers (e.g., low gravity changes player jump height).
- **Performance Tests**:
  - Measure FPS with 8 players, 10 balls, and 5 dynamic obstacles.
  - Confirm map loading time <2 seconds in Godot’s editor and exported builds.

## 6. Risks and Mitigations
- **Risk**: Physics glitches with dynamic obstacles (e.g., players getting stuck).
  - **Mitigation**: Use simplified collision shapes and test with Godot’s `ContinuousCollisionDetection`.
- **Risk**: Network desync for dynamic map elements in multiplayer.
  - **Mitigation**: Synchronize obstacle states via `MultiplayerSynchronizer` and use deterministic timers.
- **Risk**: High-poly assets causing performance issues.
  - **Mitigation**: Optimize models (target <10k tris per map) and use LODs for distant objects.

## 7. Future Considerations
- Add procedural map generation for battle royale modes.
- Implement map editor for community-created arenas.
- Support VR-compatible map layouts for future platforms.
- Expand modifier system with player-voted events (e.g., “meteor shower” spawning extra balls).