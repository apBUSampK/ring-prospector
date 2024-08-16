extends RigidBody2D

@export var torque = 100000000
@export var phiMax = 1
@export var burn = 3e6
@export var stabilizer = 1e6
@export var velMax = 500

@onready var lparticle = $LeftEngineFlames
@onready var rpaticle = $RightEngineFlames

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var heading = Vector2(0, -1).rotated(rotation)
	var appliedForce = Vector2.ZERO
	var turning = 0
	
	lparticle.emitting = false
	rpaticle.emitting = false
	
	# Input part
	if Input.is_action_pressed("Left"):
		appliedForce += stabilizer * heading.rotated(-PI/2)
	if Input.is_action_pressed("Right"):
		appliedForce += stabilizer * heading.rotated(PI/2)
	if Input.is_action_pressed("Forward") and not Input.is_action_pressed("Backward"):
		lparticle.emitting = true
		rpaticle.emitting = true
		appliedForce += burn * heading
	elif Input.is_action_pressed("Backward"):
		appliedForce -= stabilizer * heading
	
	if Input.is_action_pressed("CW"):
		turning = 1
	if Input.is_action_pressed("CCW"):
		turning = -1
	print("Velocity: ")
	print(linear_velocity)
	print("Position: ")
	print(position)
	
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
