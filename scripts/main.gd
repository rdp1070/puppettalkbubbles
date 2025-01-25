extends Node

# load in the file reference itself here
@onready
var textFile = $"res://assets/exampleText.txt"
var listScrollTexts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	scrollWords()
	pass # Replace with function body.

func setUp() -> void:
	print_debug("inside setup")
	
	$ScrollText.off_screen.connect(_on_scrollText_off_screen)
	# we are going to load in the text from the file here.
	# go into the text file, load all the words in it
	# split those words on the /n and the new line character
	# turn this into an array and save it globally.
	pass

func scrollWords() -> void:
	print_debug("inside scroll words")
	
	# in here we are goin to use the new array we just made in setup
	# we will use this array in order to create all the scrolling word child scenes.
	# those scrolling words will be their own children scenes, and they will signal when they are done
	# then we can set off the next one. 
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# we need some kind of event catcher so the children who are the scrolling text can call back to it.
# when that signal is recieved then start off the next one. Each child won't know about the next.
func _on_scrollText_off_screen(node: Node2D): 
	print_debug("inside _on_scrollText_off_screen")
	remove_child(node)
	node.queue_free()
	pass
