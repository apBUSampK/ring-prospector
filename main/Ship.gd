extends RigidBody2D

@export var torque = 20
@export var phiMax = 1
@export var burn = 60
@export var stabilizer = 20
@export var velMax = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var heading = Vector2(0, 1).rotated(rotation)
	var appliedForce = Vector2.ZERO
	var turning = 0
	
	# Input part
	if Input.is_action_pressed("Left"):
		appliedForce += stabilizer * heading.rotated(-PI/2)
	if Input.is_action_pressed("Right"):
		appliedForce += stabilizer * heading.rotated(PI/2)
	if Input.is_action_pressed("Forward") and not Input.is_action_pressed("Backward"):
		appliedForce += burn * heading
	elif Input.is_action_pressed("Backward"):
		appliedForce -= stabilizer * heading
	apply_central_force(appliedForce)
	if Input.is_action_pressed("CW"):
		apply_torque(torque)
		turning = 1
	if Input.is_action_pressed("CCW"):
		apply_torque(-torque)
		turning = -1
	
	# Compensation part
	# First address if the linear velocity limit has been exceeded:
	if linear_velocity.length() > velMax:
		apply_central_force(-appliedForce)
		apply_central_force(stabilizer * -linear_velocity.normalized())
	else: # Now try to compensate for momentum orthogonal to appliedForce
		apply_central_force(stabilizer * -linear_velocity.project(appliedForce.orthogonal()).normalized())
	# Same for angular velocity
	if abs(angular_velocity) > phiMax:
		apply_torque(torque * -turning)
		apply_torque(torque * -sign(angular_velocity))
	elif not turning:
		apply_torque(torque * -sign(angular_velocity))
