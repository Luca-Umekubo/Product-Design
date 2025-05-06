extends RigidBody3D

@onready var synchronizer: MultiplayerSynchronizer = $BallSynchronizer

func _ready():
	synchronizer.set_multiplayer_authority(1) # Server authority
	if not is_multiplayer_authority():
		freeze = true # Disable physics on clients
