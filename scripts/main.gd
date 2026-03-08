extends Node2D

## Snake Game Main Script
## Core game logic for Snake Game with complete gameplay

# Game constants
const GRID_SIZE := 20
const CELL_SIZE := 20
const INITIAL_SPEED := 0.2
const MIN_SPEED := 0.08
const SPEED_INCREMENT := 0.01

# Game state
var snake: Array[Vector2] = []
var direction: Vector2 = Vector2.RIGHT
var next_direction: Vector2 = Vector2.RIGHT
var food_position: Vector2 = Vector2.ZERO
var score: int = 0
var high_score: int = 0
var game_speed: float = INITIAL_SPEED
var game_running: bool = false
var game_paused: bool = false
var game_over: bool = false

# UI References
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var high_score_label: Label = $CanvasLayer/HighScoreLabel
@onready var game_over_panel: Control = $CanvasLayer/GameOverPanel
@onready var start_panel: Control = $CanvasLayer/StartPanel
@onready var start_button: Button = $CanvasLayer/StartPanel/StartButton
@onready var restart_button: Button = $CanvasLayer/GameOverPanel/RestartButton
@onready var pause_hint: Label = $CanvasLayer/PauseHint
@onready var grid_layer: Node2D = $GridLayer

# Timer for snake movement
var move_timer: Timer = Timer.new()

# Food animation
var food_pulse_time: float = 0.0

func _ready() -> void:
	# Setup timer
	move_timer.wait_time = game_speed
	move_timer.timeout.connect(_on_move_timer_timeout)
	add_child(move_timer)
	
	# Connect UI signals
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	
	# Load high score
	_load_high_score()
	
	# Draw initial grid
	_draw_grid()
	
	# Initialize game
	_initialize_game()

func _initialize_game() -> void:
	# Reset snake to center
	var center_x = int(get_viewport_rect().size.x / CELL_SIZE / 2)
	var center_y = int(get_viewport_rect().size.y / CELL_SIZE / 2)
	snake = [
		Vector2(center_x, center_y),
		Vector2(center_x - 1, center_y),
		Vector2(center_x - 2, center_y),
		Vector2(center_x - 3, center_y)
	]
	
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	score = 0
	game_speed = INITIAL_SPEED
	game_running = false
	game_paused = false
	game_over = false
	
	_spawn_food()
	_update_score_display()
	_update_high_score_display()
	_hide_game_over()
	_show_start_panel()
	
	# Redraw
	queue_redraw()

func _process(delta: float) -> void:
	food_pulse_time += delta * 5.0
	
	if not game_running:
		return
	
	# Handle input
	_handle_input()
	
	# Update pause hint
	if game_paused:
		pause_hint.visible = true
	else:
		pause_hint.visible = false

func _handle_input() -> void:
	if Input.is_action_just_pressed("ui_up") and direction != Vector2.DOWN:
		next_direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down") and direction != Vector2.UP:
		next_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left") and direction != Vector2.RIGHT:
		next_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right") and direction != Vector2.LEFT:
		next_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_accept"):
		_toggle_pause()
	elif Input.is_action_just_pressed("ui_cancel"):
		if game_running:
			_toggle_pause()

func _on_move_timer_timeout() -> void:
	if not game_running or game_paused or game_over:
		return
	
	# Apply next direction
	direction = next_direction
	
	# Calculate new head position
	var new_head: Vector2 = snake[0] + direction
	
	# Check collision with walls
	if _is_wall_collision(new_head):
		_game_over()
		return
	
	# Check collision with self
	if _is_self_collision(new_head):
		_game_over()
		return
	
	# Move snake
	snake.push_front(new_head)
	
	# Check food collision
	if new_head == food_position:
		# Eat food
		score += 10
		_update_score_display()
		_spawn_food()
		_increase_speed()
	else:
		# Remove tail
		snake.pop_back()
	
	# Queue redraw
	queue_redraw()

func _is_wall_collision(pos: Vector2) -> bool:
	var grid_width: int = int(get_viewport_rect().size.x / CELL_SIZE)
	var grid_height: int = int(get_viewport_rect().size.y / CELL_SIZE)
	return pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height

func _is_self_collision(pos: Vector2) -> bool:
	for i in range(1, snake.size()):
		if snake[i] == pos:
			return true
	return false

func _spawn_food() -> void:
	var grid_width: int = int(get_viewport_rect().size.x / CELL_SIZE)
	var grid_height: int = int(get_viewport_rect().size.y / CELL_SIZE)
	
	var valid_position: bool = false
	var attempts: int = 0
	var max_attempts: int = 100
	
	while not valid_position and attempts < max_attempts:
		food_position = Vector2(
			randi() % grid_width,
			randi() % grid_height
		)
		valid_position = not food_position in snake
		attempts += 1
	
	# If we couldn't find a valid position after max attempts,
	# try a different approach - find an empty spot
	if not valid_position:
		for x in range(grid_width):
			for y in range(grid_height):
				var test_pos = Vector2(x, y)
				if not test_pos in snake:
					food_position = test_pos
					valid_position = true
					break
			if valid_position:
				break

func _increase_speed() -> void:
	# Increase speed gradually
	game_speed = max(MIN_SPEED, game_speed - SPEED_INCREMENT)
	move_timer.wait_time = game_speed

func _update_score_display() -> void:
	if score_label:
		score_label.text = "Score: " + str(score)

func _update_high_score_display() -> void:
	if high_score_label:
		high_score_label.text = "High Score: " + str(high_score)

func _toggle_pause() -> void:
	if not game_running or game_over:
		return
	
	game_paused = not game_paused
	move_timer.paused = game_paused

func _game_over() -> void:
	game_over = true
	game_running = false
	move_timer.stop()
	
	# Update high score
	if score > high_score:
		high_score = score
		_save_high_score()
		_update_high_score_display()
	
	_show_game_over()

func _show_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = true
	
	# Update final score label
	var final_score_label = game_over_panel.get_node_or_null("FinalScoreLabel")
	if final_score_label:
		final_score_label.text = "Final Score: " + str(score)

func _hide_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = false

func _show_start_panel() -> void:
	if start_panel:
		start_panel.visible = true

func _hide_start_panel() -> void:
	if start_panel:
		start_panel.visible = false

func _on_start_button_pressed() -> void:
	_hide_start_panel()
	_initialize_game()
	game_running = true
	game_paused = false
	move_timer.start()

func _on_restart_button_pressed() -> void:
	_initialize_game()
	game_running = true
	game_paused = false
	move_timer.start()

func _draw() -> void:
	# Draw grid
	_draw_grid()
	
	# Draw snake
	for i in range(snake.size()):
		var color: Color
		if i == 0:
			# Head - brighter green
			color = Color(0.2, 1.0, 0.2, 1.0)
		elif i % 2 == 0:
			# Even segments
			color = Color(0.1, 0.7, 0.1, 1.0)
		else:
			# Odd segments
			color = Color(0.15, 0.55, 0.15, 1.0)
		_draw_cell(snake[i], color, i == 0)
	
	# Draw food with pulse effect
	var pulse_scale = 1.0 + sin(food_pulse_time) * 0.1
	_draw_cell(food_position, Color(1.0, 0.3, 0.3, 1.0), true, pulse_scale)

func _draw_cell(pos: Vector2, color: Color, is_head_or_food: bool = false, scale: float = 1.0) -> void:
	var cell_center = Vector2(
		pos.x * CELL_SIZE + CELL_SIZE / 2,
		pos.y * CELL_SIZE + CELL_SIZE / 2
	)
	var radius = (CELL_SIZE / 2 - 2) * scale
	
	if is_head_or_food:
		# Draw circle for head and food
		draw_circle(cell_center, radius, color)
		# Add highlight
		draw_circle(cell_center - Vector2(3, 3), radius * 0.3, Color(1, 1, 1, 0.3))
	else:
		# Draw rounded rectangle for body segments
		var rect = Rect2(
			pos.x * CELL_SIZE + 2,
			pos.y * CELL_SIZE + 2,
			CELL_SIZE - 4,
			CELL_SIZE - 4
		)
		draw_rect(rect, color)

func _draw_grid() -> void:
	if not grid_layer:
		return
	
	var viewport_size = get_viewport_rect().size
	var grid_color = Color(0.2, 0.2, 0.25, 0.5)
	
	# Draw vertical lines
	for x in range(0, int(viewport_size.x), CELL_SIZE):
		grid_layer.draw_line(
			Vector2(x, 0),
			Vector2(x, viewport_size.y),
			grid_color,
			1.0
		)
	
	# Draw horizontal lines
	for y in range(0, int(viewport_size.y), CELL_SIZE):
		grid_layer.draw_line(
			Vector2(0, y),
			Vector2(viewport_size.x, y),
			grid_color,
			1.0
		)

func _load_high_score() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://snake_game.ini")
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)
		_update_high_score_display()

func _save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.save("user://snake_game.ini")

func get_game_state() -> Dictionary:
	return {
		"score": score,
		"high_score": high_score,
		"game_running": game_running,
		"game_paused": game_paused,
		"game_over": game_over,
		"snake_size": snake.size()
	}
