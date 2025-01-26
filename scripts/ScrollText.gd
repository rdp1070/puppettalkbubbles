extends Node
class_name ScrollText 

signal off_screen

@onready var textLabel = $RichTextLabel

@export var speed:int = 300
@export var scrolling_text:String = "This is the default text."
@export_color_no_alpha var text_color:Color = Color.BLACK

var position:Vector2 = Vector2.ZERO

var going_left:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	pass # Replace with function body.

func setUp() -> void:
	
	going_left = randi() & 1
	# we setting up all the variables here.
	var vpsize = get_viewport().get_visible_rect().size
	# this sets it's initial position to the full width by something 
	# in the top 3rd of the screen
	if going_left:
		position = Vector2(vpsize.x, randi() % int(vpsize.y/3))
		speed = speed * -1
	if not going_left:
		position = Vector2(0-textLabel.get_content_width(), randi() % int(vpsize.y/3))
		speed = abs(speed)
	
	self.global_position = position
	self.z_index = 0
	
	setText(scrolling_text)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isPositionOffScreen()):
		off_screen.emit(self)
	else: 
		moving(delta)
	pass

func setText(newText: String) -> void:
	# set the textLabel to have the text assigned to it.
	textLabel.text = newText
	pass

func moving(delta: float) -> void:
	#print_debug("in moving")
	# I feel like delta is supposed to be involved in this calculation of movement somehow :?
	self.global_position.x = self.global_position.x + (speed) * delta
	pass

func isPositionOffScreen() -> bool:
	# check if the textbox is offscreen
	var offscreenXLeft = 0-textLabel.get_content_width()
	var offscreenXRight = get_viewport().get_visible_rect().size.x
	var isOffscreen = false
	if going_left:
		isOffscreen = self.global_position.x <= offscreenXLeft
	else:
		isOffscreen = self.global_position.x >= offscreenXRight
	return isOffscreen
