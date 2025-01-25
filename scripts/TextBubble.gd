extends Node

@export var bubble_text:String = "Default Button Text"
@onready var text_Label:RichTextLabel = $TextureButton/RichTextLabel
@export var correctness:int = 0
var disabled:bool = false

var startingPosition:Vector2 = Vector2.ZERO

signal bubble_pop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wiggle()
	pass

func wiggle() -> void: 
	pass

func setUp() -> void:
	var vpsize = get_viewport().get_visible_rect().size
	self.global_position = Vector2(randi() % int(vpsize.x), randi() % int(vpsize.y))
	setText(bubble_text)
	pass

func setText(newText: String) -> void:
	# set the textLabel to have the text assigned to it.
	print_debug("in setText")
	text_Label.text = newText
	pass

func _on_texture_button_pressed() -> void:
	if disabled == false:
		bubble_pop.emit(self)
		disabled = true
	pass # Replace with function body.

func play_pop_anim():
	# play the pop animation somehow
	# when the animation ends, die?? 
	self.queue_free()
	pass
