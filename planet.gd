extends Sprite

export var planetRadius = 110
export (int) var playerNumber
export (Color) var color
export var health = 100

var player
var income = 4
var start_money = 200
var money = 0
var slot_count = 14
var slot_width
var label_color = Color("#42286c")

func _ready():
	money += start_money

	player = preload('res://player/Player.tscn').instance()
	add_child(player)
	player.planet = self
	player.position.y -= planetRadius
	player.playerNumber = playerNumber
	player.name = '%s_player' % name
	# player.modulate = color.lightened(0.5)
	add_to_group('planet')
	slot_width = planetRadius * PI / slot_count

func _draw():
	# draw_circle(Vector2(0, 0), planetRadius, color)
	# draw_rect(Rect2(Vector2(10, 10), Vector2(health, 10)), Color(255, 40, 80))
	var arc_rotation = current_slot_position().direction_to(Vector2(0, 0)).angle() - PI/2
	if (not is_instance_valid(player.current_building)):
		# draw_circle(current_slot_position(), slot_width / 2, Color(1, 1, 1, 0.2))
		draw_circle_arc(Vector2(0, 0), 95, (arc_rotation * 180/PI) - (slot_width / 4), (arc_rotation * 180/PI) + (slot_width / 4), Color(0.3, 0.8, 1, 0.5))

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 17
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 1.5)

func _process(delta):
	money += income * delta
	if playerNumber == 1:
		rotation_degrees -= 5 * delta
	elif playerNumber == 2:
		rotation_degrees += 5 * delta

	if is_network_master():
		rpc('_sync_rotation', rotation)

puppet func _sync_rotation(rot):
	rotation = rot

func current_slot_position():
	var slot_angle_width = PI / slot_count
	var player_position_angle = (player.position.angle() + PI/2)
	var slot_index = round(player_position_angle / slot_angle_width)
	var offset = 0.9
	return Vector2(0, -planetRadius * offset) \
		.rotated(slot_index * slot_angle_width)
