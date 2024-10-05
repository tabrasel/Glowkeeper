extends CharacterBody2D
class_name Firefly

enum FireflyState {ROAMING, CAUGHT, DEPOSITED, FLYING_INTO_LANTERN, IN_LANTERN}

@export var animated_sprite: AnimatedSprite2D
@export var glow_sprite: AnimatedSprite2D
@export var particles: GPUParticles2D
@export var cry_particle_material: ParticleProcessMaterial
@export var sparkle_particle_material: ParticleProcessMaterial
@export var catch_explosion_scene: PackedScene
@export var firefly_resource: FireflyResource
@export var audio_player: AudioStreamPlayer2D

@export var target_offset_radius: float
@export var angle_spring_strength: float
@export var angle_spring_strength_range: float
@export var angle_spring_damping: float
@export var angle_spring_damping_range: float
@export var acceleration: float
@export var acceleration_range: float
@export var max_speed: float

var state: FireflyState = FireflyState.ROAMING

var _player: Node2D
var _lantern: Lantern

var _angle: float
var _angle_velocity: float
var _initial_anchor = Vector2()
var _target_anchor = Vector2()
var _target_offset = Vector2()
var _target_position = Vector2()

var _particles_material: ParticleProcessMaterial

const CATCH_DISTANCE = 15


func _ready():
	_player = get_node("%Player")
	_lantern = get_node("%Lantern")
	
	firefly_resource.connect("all_fireflies_deposited", _on_all_fireflies_deposited)
	
	#_particles_material = particles.process_material as ParticleProcessMaterial
	
	angle_spring_strength += angle_spring_strength_range * randf_range(-1, 1)
	angle_spring_damping += angle_spring_damping_range * randf_range(-1, 1)
	acceleration += acceleration_range * randf_range(-1, 1)
	
	_initial_anchor.x = global_position.x
	_initial_anchor.y = global_position.y
	_target_anchor.x = global_position.x
	_target_anchor.y = global_position.y
	_update_target()
	
func _process(_delta: float):
	if state == FireflyState.ROAMING:
		animated_sprite.play('roam')
		glow_sprite.visible = false
		particles.process_material = cry_particle_material
	elif state == FireflyState.CAUGHT:
		animated_sprite.play('caught')
		glow_sprite.visible = true
		particles.process_material = sparkle_particle_material
	elif state == FireflyState.DEPOSITED:
		animated_sprite.play('caught')
		glow_sprite.visible = true
		particles.process_material = sparkle_particle_material

func _physics_process(delta: float):
	if state == FireflyState.ROAMING:
		if global_position.distance_to(_player.global_position) <= CATCH_DISTANCE:
			_catch()
	elif state == FireflyState.CAUGHT:
		_target_anchor = _player.global_position
	elif state == FireflyState.FLYING_INTO_LANTERN:
		if global_position.distance_to(_lantern.top_marker.global_position) <= 5:
			state = FireflyState.IN_LANTERN
	elif state == FireflyState.IN_LANTERN:
		z_index = -10
		var lantern_top_position = _lantern.top_marker.global_position;
		global_position.x = clamp(global_position.x, lantern_top_position.x - 5, lantern_top_position.x + 5)
		global_position.y = clamp(global_position.y, lantern_top_position.y - 2, lantern_top_position.y + 2)
	
	_target_position = _target_anchor + _target_offset
	var direction_to_target: Vector2 = (_target_position - global_position).normalized()
	var angle_to_target: float = direction_to_target.angle()
	var angle_diff: float = angle_difference(_angle, angle_to_target)
	_angle_velocity += (angle_diff * angle_spring_strength) - (_angle_velocity * angle_spring_damping)
	_angle += _angle_velocity * delta
	
	velocity.x += cos(_angle) * acceleration * delta
	velocity.y += sin(_angle) * acceleration * delta
	
	var dist_to_target: float = global_position.distance_to(_target_position)
	var friction_coef: float = clamp(0.2 - dist_to_target * 0.005, 0.01, 0.06)
	velocity -= velocity * friction_coef
	velocity = velocity.limit_length(max_speed)

	move_and_slide()
	
	animated_sprite.flip_h = velocity.x < 0

func _catch():
	state = FireflyState.CAUGHT
	firefly_resource.catch_firefly(self)
	
	var catch_explosion = catch_explosion_scene.instantiate()
	add_child(catch_explosion)
	catch_explosion.global_position = global_position
	
	glow_sprite.play('flicker_on')
	
	audio_player.play()

func deposit():
	state = FireflyState.DEPOSITED
	_target_anchor = _lantern.top_marker.global_position
	
	var catch_explosion = catch_explosion_scene.instantiate()
	add_child(catch_explosion)
	catch_explosion.global_position = global_position

func _update_target():
	_target_offset.x = randf_range(-target_offset_radius, target_offset_radius)
	_target_offset.y = randf_range(-target_offset_radius, target_offset_radius)

func _draw():
	#var direction_to_target: Vector2 = (_target_position - global_position).normalized()
	#draw_line(Vector2.ZERO, velocity, Color.ORANGE)
	#draw_circle(global_position - _target_position, 3, Color.ORANGE)
	pass

func _on_target_reposition_timer_timeout():
	_update_target()
	
func uncatch():
	global_position.x = _initial_anchor.x
	global_position.y = _initial_anchor.y
	_target_anchor.x = _initial_anchor.x
	_target_anchor.y = _initial_anchor.y
	velocity = Vector2.ZERO
	state = FireflyState.ROAMING

func arrange_around_lantern(angle: float):
	_target_anchor.x = _lantern.top_marker.global_position.x + cos(angle) * 40
	_target_anchor.y = _lantern.top_marker.global_position.y + sin(angle) * 40
	target_offset_radius = 0
	angle_spring_strength = 1
	angle_spring_damping = 0.1
	
func move_toward_lantern():
	_target_anchor = _lantern.top_marker.global_position
	target_offset_radius = 0
	angle_spring_strength = 2
	angle_spring_damping = 0.2
	max_speed = 50
	state = FireflyState.FLYING_INTO_LANTERN
	particles.emitting = false

func _on_all_fireflies_deposited():
	pass
