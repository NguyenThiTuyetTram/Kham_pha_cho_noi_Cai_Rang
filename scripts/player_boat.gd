extends CharacterBody2D

@export var max_speed := 240.0
@export var acceleration := 720.0
@export var friction := 560.0
@export var river_bounds := Rect2(160, 120, 1600, 820)

@onready var wake: CPUParticles2D = $Wake
var external_force := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	wake.emitting = false


func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length() > 0.0:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity += external_force
	external_force = external_force.move_toward(Vector2.ZERO, 240.0 * delta)
	move_and_slide()
	global_position.x = clamp(global_position.x, river_bounds.position.x, river_bounds.end.x)
	global_position.y = clamp(global_position.y, river_bounds.position.y, river_bounds.end.y)

	if velocity.length() > 8.0:
		rotation = lerp_angle(rotation, velocity.angle() + PI / 2.0, delta * 8.0)
		wake.emitting = true
	else:
		wake.emitting = false
