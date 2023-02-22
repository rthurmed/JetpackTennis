extends State


const SPEED = 150


func process(delta: float):
	if (
		not Input.is_action_pressed(owner.get_action("left")) and
		not Input.is_action_pressed(owner.get_action("right"))
	):
		transition("Idle")
		return
	
	if not owner.ground_raycast.is_colliding():
		transition("Fall")
		return
	
	owner.move(delta, owner.grab_movement() * SPEED)


func physics_process(_delta: float): pass
func enter(): pass
func exit(): pass
