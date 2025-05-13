extends RigidBody3D

var is_active = true
var respawn_timer = 0.0
var max_respawn_time = 15.0  # Seconds until ball disappears if not picked up
var spawn_immunity_time = 0.2  # Short immunity after spawning
var last_hit_player = null  # Track which player we last hit

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Create and set physics material for friction and bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.5
	physics_material.bounce = 0.7
	physics_material_override = physics_material
	
	# Set other physics parameters
	mass = 2.0
	custom_integrator = false
	continuous_cd = true
	max_contacts_reported = 5
	contact_monitor = true
	
	# Set collision layer and mask to ensure proper collision
	collision_layer = 2  # Layer 2 for balls
	collision_mask = 1 | 2 | 4  # Collide with players (1), other balls (2), and environment (4)
	
	add_to_group("balls")
	
	# Give a small impulse upward to prevent sticking to ground on spawn
	apply_central_impulse(Vector3(0, 0.5, 0))
	
	# Brief immunity to allow the ball to move away from the player
	set_deferred("monitoring", false)
	var timer = get_tree().create_timer(spawn_immunity_time)
	timer.timeout.connect(func(): set_deferred("monitoring", true))

func _physics_process(delta):
	# Handle respawn timer for balls at rest
	if is_active and linear_velocity.length() < 0.1:
		respawn_timer += delta
		if respawn_timer > max_respawn_time:
			queue_free()
	else:
		respawn_timer = 0.0
	
	# Apply small damping to slow rolling balls over time
	if linear_velocity.length() < 3.0 and linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity * 0.98
	
	# Prevent balls from getting stuck in the floor
	if is_active and abs(linear_velocity.y) < 0.01 and is_on_floor():
		apply_central_impulse(Vector3(0, 0.2, 0))

func is_on_floor():
	# Simple check to detect if ball is on a floor-like surface
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3(0, -0.55, 0)
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result != null

func _on_body_entered(body):
	if not multiplayer.is_server():
		return
		
	if body.is_in_group("players"):
		# Check if this is a high-velocity hit that should cause damage
		if linear_velocity.length() > 5.0:
			# Damage the player, but DON'T destroy the ball
			body.hit_by_ball.rpc()
			
			# Make the ball bounce off the player instead of destroying it
			var bounce_direction = (global_position - body.global_position).normalized()
			linear_velocity = bounce_direction * linear_velocity.length() * 0.7  # 70% of original speed
			
			# Add a slight upward component to the bounce
			linear_velocity.y += 2.0
			
			# Remember this player to prevent multiple rapid hits
			last_hit_player = body
			
			# Create a brief immunity period to prevent multiple hits in succession
			set_deferred("monitoring", false)
			var timer = get_tree().create_timer(0.5)  # Half second immunity
			timer.timeout.connect(func(): 
				set_deferred("monitoring", true)
				last_hit_player = null
			)
		else:
			# Allow players to push the ball when it's slow/stopped
			var push_direction = (global_position - body.global_position).normalized()
			apply_central_impulse(push_direction * 3.0)
