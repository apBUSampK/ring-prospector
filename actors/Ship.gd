extends RigidBody2D

@export var torque = 100000000
@export var phiMax = 1
@export var burn = 3e6
@export var stabilizer = 1e6
@export var velMax = 500

@onready var lParticle = $LeftEngineFlames
@onready var rParticle = $RightEngineFlames
@onready var cdTimer = $FireCd

const LaserRound = preload("res://actors/LaserRound.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var heading = Vector2.UP.rotated(rotation)
	var appliedForce = Vector2.ZERO
	var turning = 0
	
	lParticle.emitting = false
	rParticle.emitting = false
	
	# Input part
	appliedForce += stabilizer * heading.rotated(PI/2) * Input.get_axis("Left", "Right")
	var FBM = Input.get_axis("Backward", "Forward")
	if FBM > 0:
		lParticle.emitting = true
		rParticle.emitting = true
		appliedForce += burn * heading
	elif FBM < 0:
		appliedForce -= stabilizer * heading
	
	turning = Input.get_axis("CCW", "CW")
	
	# Compensation part
	# First address if the linear velocity limit has been exceeded (or no input):
	if linear_velocity.length() > velMax or appliedForce == Vector2.ZERO:
		apply_central_force(stabilizer * -linear_velocity.normalized())
	else: # Now try to compensate for momentum orthogonal to appliedForce
		appliedForce += stabilizer * -linear_velocity.project(appliedForce.orthogonal()).normalized()
		apply_central_force(appliedForce)
	# Same for angular velocity
	if abs(angular_velocity) > phiMax or not turning:
		apply_torque(torque * -sign(angular_velocity))
	else:
		apply_torque(torque * turning)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Fire") and cdTimer.is_stopped():
		cdTimer.start()
		var laserRound = LaserRound.instantiate()
		laserRound.set_rotation(rotation)
		laserRound.set_global_position(position + Vector2(-59.0, -175.0).rotated(rotation))
		get_parent().add_child(laserRound)
