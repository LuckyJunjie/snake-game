extends Node2D

## Snake Game Main Script
## Core game logic for Snake Game

# Game constants
const GRID_SIZE := 20
const CELL_SIZE := 20
const INITIAL_SPEED := 0.3

# Game state
var snake: Array[Vector2] = []
var direction: Vector2 = Vector2.RIGHT
var next_direction: Vector2 = Vector2.RIGHT
var food_position: Vector2 = Vector2.ZERO
var score: int = 0
var game_speed: float = INITIAL_SPEED
var game_running: bool = false
var game_paused: bool = false

# UI References
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var game_over_panel: Control = $CanvasLayer/GameOverPanel
@onready var start_button: Button = $CanvasLayer/StartPanel/StartButton

# Timer for snake movement
var move_timer: Timer = Timer.new()

func _ready() -> void:
	# Setup timer
	move_timer.wait_time = game_speed
	move_timer.timeout.connect(_on_move_timer_timeout)
	add_child(move_timer)
	
	# Connect UI signals
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	
	# Initialize game
	_initialize_game()

func _initialize_game() -> void:
	snake = [Vector2(10, 10), Vector2(9, 10), Vector2(8, 10)]
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	score = 0
	game_speed = INITIAL_SPEED
	game_running = false
	game_paused = false
	
	_spawn_food()
	_update_score_display()
	_hide_game_over()
	_show_start_panel()

func _process(delta: float) -> void:
	if not game_running:
		return
	
	# Handle input
	_handle_input()

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

func _on_move_timer_timeout() -> void:
	if not game_running or game_paused:
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
	var grid_width: int = get_viewport_rect().size.x / CELL_SIZE
	var grid_height: int = get_viewport_rect().size.y / CELL_SIZE
	return pos.x < 0 or pos.x >= grid_width or pos.y < 0 or pos.y >= grid_height

func _is_self_collision(pos: Vector2) -> bool:
	for i in range(1, snake.size()):
		if snake[i] == pos:
			return true
	return false

func _spawn_food() -> void:
	var grid_width: int = get_viewport_rect().size.x / CELL_SIZE
	var grid_height: int = get_viewport_rect().size.y / CELL_SIZE
	
	var valid_position: bool = false
	while not valid_position:
		food_position = Vector2(
			randi() % grid_width,
			randi() % grid_height
		)
		valid_position = not food_position in snake

func _increase_speed() -> void:
	# Increase speed every 50 points
	if score % 50 == 0:
		game_speed = max(0.1, game_speed - 0.02)
		move_timer.wait_time = game_speed

func _update_score_display() -> void:
	if score_label:
		score_label.text = "Score: " + str(score)

func _toggle_pause() -> void:
	game_paused = not game_paused

func _game_over() -> void:
	game_running = false
	move_timer.stop()
	_show_game_over()

func _show_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = true

func _hide_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = false

func _show_start_panel() -> void:
	var start_panel = get_node_or_null("CanvasLayer/StartPanel")
	if start_panel:
		start_panel.visible = true

func _hide_start_panel() -> void:
	var start_panel = get_node_or_null("CanvasLayer/StartPanel")
	if start_panel:
		start_panel.visible = false

func _on_start_button_pressed() -> void:
	_hide_start_panel()
	_initialize_game()
	game_running = true
	move_timer.start()

func _draw() -> void:
	# Draw snake
	for i in range(snake.size()):
		var color: Color = Color.GREEN if i == 0 else Color.DARK_GREEN
		_draw_cell(snake[i], color)
	
	# Draw food
	_draw_cell(food_position, Color.RED, true)

func _draw_cell(pos: Vector2, color: Color, is_circle: bool = false) -> void:
	var rect := Rect2(
		pos.x * CELL_SIZE + 1,
		pos.y * CELL_SIZE + 1,
		CELL_SIZE - 2,
		CELL_SIZE - 2
	)
	if is_circle:
		draw_circle(rect.get_center(), CELL_SIZE / 2 - 2, color)
	else:
		draw_rect(rect, color)
