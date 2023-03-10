extends KinematicBody2D


signal attack_executed(strength)

export var opposite_side = false
export var action_prefix = "p1_"
export var attack_angle_values = {
	'normal': deg2rad(45),
	'high': deg2rad(60),
	'low': deg2rad(30)
}
export var attack_strength_modifier = 1

onready var visual_instance = $VisualInstance
onready var colliders = $Colliders
onready var ground_raycast = $GroundRayCast2D
onready var animation = $AnimationPlayer

var velocity = Vector2.ZERO
var attack_strength = 0
var attack_angle = 0


func _ready():
	var scale_x = -1 if opposite_side else 1
	visual_instance.scale.x = scale_x
	colliders.scale.x = scale_x


func get_action(action: String):
	return action_prefix + action


func grab_movement() -> Vector2:
	return Vector2.RIGHT * (
		Input.get_action_strength(get_action("right")) - 
		Input.get_action_strength(get_action("left"))
	)


func with_gravity(movement = Vector2.ZERO):
	return movement + Vector2.DOWN * 98


func move(delta, movement = Vector2.ZERO):
	# var _collision = move_and_collide(velocity * delta)
	velocity = lerp(velocity, movement, delta * 8)
	var _slide = move_and_slide(velocity, Vector2.UP)


func get_attack_angle():
	var angle = attack_angle_values["normal"]
	
	var action_forward = get_action("right")
	var action_backward = get_action("left")
	
	if opposite_side:
		action_forward = get_action("left")
		action_backward = get_action("right")
	
	if Input.is_action_pressed(action_forward):
		angle = attack_angle_values["low"]
	elif Input.is_action_pressed(action_backward):
		angle = attack_angle_values["high"]
	
	return angle


func attack(body: RigidBody2D, strength):
	var horizontal_modifier = 1 if opposite_side else -1
	var angle = attack_angle
	var direction = Vector2.LEFT
	var modified_strength = strength * attack_strength_modifier
	
	direction = direction.rotated(angle)
	direction.x = direction.x * horizontal_modifier
	
	$DebugNode/AttackStrengthLabel.text = str("strength: ", modified_strength)
	$DebugNode/AttackAngleLabel.text = str("angle: ", rad2deg(angle), "º")
	
	body.set_deferred("linear_velocity", Vector2.ZERO)
	body.call_deferred("apply_central_impulse", direction * modified_strength)
	
	emit_signal("attack_executed", modified_strength)


func _on_StateMachine_transition(state_name):
	$DebugNode/StateLabel.text = str("state: ", state_name)
