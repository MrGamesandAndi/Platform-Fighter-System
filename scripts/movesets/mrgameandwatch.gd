extends Node

@onready var character_controller = get_parent()

enum lag_frames
{
	Neutral_Air = 19,
	Forward_Air = 25,
	Back_Air = 17,
	Up_Air = 1,
	Down_Air = 11
}

#width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag

#region Grounded Attacks

func jab():
	if character_controller.frame == 4:
		character_controller.create_hitbox(48, 19, 3, 361, 3, 1, 6, "normal", Vector2(16, 3.5), 0, 1)
	if character_controller.frame >= 17:
		return true
		
func down_tilt():
	if character_controller.frame == 6:
		character_controller.create_hitbox(37, 45, 9, 90, 3, 120, 7, "normal", Vector2(18.5, -1.5), 0, 1)
	if character_controller.frame >= 29:
		return true
		
func forward_tilt():
	if character_controller.frame == 10:
		character_controller.create_hitbox(37, 45, 9, 30, 3, 120, 7, "normal", Vector2(18.5, -1.5), 0, 1)
	if character_controller.frame >= 44:
		return true

func up_tilt():
	if character_controller.frame == 9:
		character_controller.create_hitbox(56, 41, 9, 90, 3, 120, 29, "normal", Vector2(-3, -20.5), 0, 1)
	if character_controller.frame >= 29:
		return true

#endregion

#region Aerials
func neutral_air():
	if character_controller.frame == 1:
		character_controller.create_hitbox(35, 44, 5, 90, 130, 0,2,"normal",Vector2(-0.5,-8),0,1)
	if character_controller.frame == 10:
		character_controller.create_hitbox(35, 44, 5, 90, 130, 0,2,"normal",Vector2(-0.5,-8),0,1)
	if character_controller.frame == 20:
		character_controller.create_hitbox(77, 61, 12, 361, 0, 50,3,"normal",Vector2(-0.5,0.5),0,0.4)
	if character_controller.frame == 30:
		return true
	
				
func up_air():
	if character_controller.frame == 7:
		character_controller.create_hitbox(32,26,5,90,130,0,2,"normal",Vector2(-4,-21),0,1)
	if character_controller.frame == 22:
		character_controller.create_hitbox(32,26,10,90,20,108,3,"normal",Vector2(-4,-21),0,2)
	if character_controller.frame == 39:
		return true
		
func back_air():
	if character_controller.frame == 10:
		character_controller.create_hitbox(37,28.5,5,90,130,0,2,"normal",Vector2(-11.5,6.75),0,1)
	if character_controller.frame == 24:
		character_controller.create_hitbox(37,28.5,10,90,20,108,3,"normal",Vector2(-11.5,6.75),0,2)
	if character_controller.frame == 39:
		return true

func forward_air():
	if character_controller.frame == 10:
		character_controller.create_hitbox(36,21,5,90,130,0,2,"normal",Vector2(19,2.5),0,1)
	if character_controller.frame == 44:
		return true

func down_air():
	if character_controller.frame == 12:
		character_controller.create_hitbox(20,31,15,45,1,100,26,"normal",Vector2(6,7.5),6,1)
	if character_controller.frame == 49:
		return true
#endregion
