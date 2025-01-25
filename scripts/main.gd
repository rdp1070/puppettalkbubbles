extends Node

# preload the scene file we are making instances of
var ScrollText = preload("res://scenes/ScrollText.tscn")
var TextBubble = preload("res://scenes/TextBubble.tscn")

# load in the file reference itself here
var text_file_location = "res://assets/exampleText.txt"
var listScrollTexts :Array[ScrollText] = []
var dictTextBubbles : = {}
var score:int = 0
var base_score: int = 10

var current_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	scrollWords()
	pass # Replace with function body.

func reset():
	popAllBubbles()
pass

func setUp() -> void:
	print_debug("inside setup")
	# we are going to load in the text from the file here.
	# go into the text file, load all the words in it
	# split those words on the /n and the new line character
	# turn this into an array and save it globally.
	var file_text = load_text_file(text_file_location)
	if (file_text != null): 
		var textList = file_text.split("/n", false, 0)
		for text:String in textList:
			var scroll_text_instance = ScrollText.instantiate()
			scroll_text_instance.scrolling_text = text
			scroll_text_instance.off_screen.connect(_on_scrollText_off_screen)
			listScrollTexts.push_back(scroll_text_instance)
			pass
	pass

func load_text_file(path:String):
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func scrollWords() -> void:
	print_debug("inside scroll words")
	# in here we are goin to use the new array we just made in setup
	# we will use this array in order to create all the scrolling word child scenes.
	# those scrolling words will be their own children scenes, 
	# and they will signal when they are done then we can set off the next one. 
	
	if (listScrollTexts.size() > 0):
		add_child(listScrollTexts[0])
	else:
		activateSelectMode()
	pass

func makeBubbles(n:int) -> void: 
	#bubbles will be worth amount when popped
	#bubbles will contain text
	#buubles will have "correctness" on a scale of -2 to 2
	for x in n:
		var text_bubble_instance:TextBubble = TextBubble.instantiate()
		text_bubble_instance.bubble_text = "Default bubble text"
		text_bubble_instance.bubble_pop.connect(_on_bubble_pop)
		text_bubble_instance.select_bubble.connect(_on_select_bubble)
		text_bubble_instance.correctness = randi_range(-2, 2)
		text_bubble_instance.id = randi_range(-10000,10000)
		dictTextBubbles.get_or_add(text_bubble_instance.id, text_bubble_instance)
		add_child(text_bubble_instance)
		pass

func updateScore(newScore: int):
	print_debug(newScore)
	score = newScore
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func activateSelectMode(): 
#	 go over the remaining bubbles on the screen and turn score mode on
	for bubble:TextBubble in dictTextBubbles.values():
		bubble.score_mode = true
	pass

func playReaction(correctness:int):
	pass

func popAllBubbles():
	for bubble:TextBubble in dictTextBubbles.values():
		bubble.play_pop_anim()
		dictTextBubbles.erase(bubble.id)
		
	pass

# we need some kind of event catcher so the children who are the scrolling text can call back to it.
# when that signal is recieved then start off the next one. Each child won't know about the next.
func _on_scrollText_off_screen(node: Node2D): 
	print_debug("inside _on_scrollText_off_screen")
	remove_child(node)
	node.queue_free()
	listScrollTexts.remove_at(0)
	makeBubbles(randi_range(1,5))
	scrollWords()
	pass

func _on_bubble_pop(bubble: TextBubble):
	# add score and trigger it's pop anim
	bubble.play_pop_anim()
	updateScore(score+base_score)
	dictTextBubbles.erase(bubble.id)
	# play pop sound
	pass

func _on_select_bubble(bubble: TextBubble):
	print_debug("inside select bubble")
	playReaction(bubble.correctness)
	reset()
	pass
