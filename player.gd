extends CharacterBody2D

var speed = 400.0

func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * speed
	
	if input_vector.length() > 0:
		rotation = input_vector.angle() + PI/2
		$CPUParticles2D.emitting = true
	else:
		$CPUParticles2D.emitting = false

	move_and_slide()
