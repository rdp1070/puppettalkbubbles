extends Node
class_name TextBubble

@export var bubble_text:String = "Default Button Text"
@onready var text_Label:RichTextLabel = $TextureButton/RichTextLabel
@export var correctness:int = 0
var disabled:bool = false
@export var wiggle_speed:float = .02
var max_wiggle = .15
var score_mode:bool = false
var startingPosition:Vector2 = Vector2.ZERO
var id = -1

signal bubble_pop
signal select_bubble

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wiggle(delta)
	pass

func wiggle(delta: float) -> void: 
	# wiggle on direction until you meet the target, then go the other direction.
	if (abs(self.rotation) >= abs(max_wiggle)):
		max_wiggle = -1 * max_wiggle
	self.rotation = lerpf(self.rotation, PI/max_wiggle, (wiggle_speed * delta))
	pass

func setUp() -> void:
	var vpsize = get_viewport().get_visible_rect().size
	self.global_position = Vector2(randi() % int(vpsize.x), randi() % int(vpsize.y))
	setText(bubble_text)
	var rand_scale = (randf_range(.8, 1.5))
	self.scale.x = rand_scale
	self.scale.y = rand_scale
	self.z_index = randi_range(-4,4)
	pass

func setText(newText: String) -> void:
	# set the textLabel to have the text assigned to it.
	print_debug("in setText")
	text_Label.text = newText
	pass

func _on_texture_button_pressed() -> void:
	if score_mode == false: 
		if disabled == false:
			bubble_pop.emit(self)
			disabled = true
	else:
		select_bubble.emit(self)
		disabled = true
	pass # Replace with function body.

func play_pop_anim():
	# play the pop animation somehow
	# when the animation ends, die?? 
	self.queue_free()
	pass
