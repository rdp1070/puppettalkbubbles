extends Node

# preload the scene file we are making instances of
var ScrollText = preload("res://scenes/ScrollText.tscn")
var TextBubble = preload("res://scenes/TextBubble.tscn")

@onready var belinda_anim:AnimationPlayer = $Sprite2D/AnimationPlayer

# reference to Options Menu 
@onready var optionsMenu = $OptionsMenu

@onready var questionText = $QuestionText
@onready var responseText = $ResponseText

# load in the file reference itself here
var sentence_text_file_location = "res://assets/text/sentences%s-%s.txt"
var bubbles_text_file_location = "res://assets/text/bubbles%s-%s.txt"
var listScrollTexts :Array[ScrollText] = []
var activeTextBubblesDict : = {}
var queuedTextBubbles = {}
var score:int = 0
var base_score: int = 10

@export var current_level: int = 1
@export var max_scenes = 2
@export var sentence_delay = 2
@export var bubble_delay = .3
var current_scene: int = 1
var current_phrase: int = 0
var last_sentence = ""

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUp()
	scrollWords()
	pass # Replace with function body.
	optionsMenu.z_index = 100

func reset():
	popAllBubbles()
	questionText.hide()
	responseText.hide()
	belinda_anim.stop()
	current_scene+=1
	setUp()
	scrollWords()
pass

func setUp() -> void:
	# we are going to load in the text from the file here.
	# go into the text file, load all the words in it
	# split those words on the /n and the new line character
	# turn this into an array and save it globally.
	if (current_scene <= max_scenes):
		questionText.hide()
		responseText.hide()
		current_phrase=0
		load_sentences()
		load_bubbles()
	else: 
		load_next()
	pass

func load_next():
	print_debug("inside load_next")
	#load the next level here
	pass
	
func load_text_file(path:String):
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func scrollWords() -> void:
	await get_tree().create_timer(sentence_delay).timeout
	print_debug("inside scroll words")
	# in here we are goin to use the new array we just made in setup
	# we will use this array in order to create all the scrolling word child scenes.
	# those scrolling words will be their own children scenes, 
	# and they will signal when they are done then we can set off the next one. 
	
	if (listScrollTexts.size() > 0):
		add_child(listScrollTexts[0])
		belinda_anim.play("talk")
	else:
		activateSelectMode()
	pass

func makeBubbles() -> void: 
	#bubbles will be worth amount when popped
	#bubbles will contain text
	var curPhrase = queuedTextBubbles.get(current_phrase, null)
	if curPhrase != null: 
		for textBubble:TextBubble in curPhrase:
			add_child(textBubble)
			activeTextBubblesDict.get_or_add(textBubble.id, textBubble)
			await get_tree().create_timer(bubble_delay).timeout

	pass
	current_phrase+=1

func updateScore(newScore: int):
	print_debug(newScore)
	score = newScore
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_optionsMenu()

func _optionsMenu():
	if paused:
		optionsMenu.hide()
		Engine.time_scale = 1
	else:
		optionsMenu.show()
		Engine.time_scale = 0
	
	paused = !paused

func activateSelectMode(): 
	belinda_anim.stop()
	questionText.text = last_sentence
	questionText.show()
#	 go over the remaining bubbles on the screen and turn score mode on
	for bubble:TextBubble in activeTextBubblesDict.values():
		bubble.score_mode = true
	pass

func playReaction(correctness:int):
	if correctness < 1:
		belinda_anim.play("talk_shocked")
	setResponseText(correctness)
	pass

func setResponseText(correctness:int):
	# we want to check which scene and sentence it is and do it manually here.
	# ain't got time for programmatically loading it from somewhere.
	if (current_level == 1):
		if (current_scene == 1):
			if correctness < 1:
				questionText.text = "Huh? Are you listening?"
			else:
				questionText.text = "Oh wonderful! The food here is great!"
		elif (current_scene == 2):
			if correctness < 1:
				questionText.text = "That’s a horrible suggestion."
			else:
				questionText.text = "Great idea! I should be able to print on time then."
		elif (current_scene == 3):
			if correctness < 1:
				questionText.text = "Maybe I’ll just travel alone..."
			else:
				questionText.text = "Yay, let’s plan together!"
	pass

func popAllBubbles():
	for bubble in activeTextBubblesDict.values():
		bubble.play_pop_anim()
		activeTextBubblesDict.erase(bubble.id)
	queuedTextBubbles = {}
	pass
	
func updateResponse(text:String):
	responseText.text = text
	responseText.show()
	pass

func load_sentences():
	var file_text = load_text_file(sentence_text_file_location % [current_level, current_scene])
	if (file_text != null): 
		var textList = file_text.split("/n", false, 0)
		for text:String in textList:
			var scroll_text_instance = ScrollText.instantiate()
			scroll_text_instance.scrolling_text = text
			scroll_text_instance.off_screen.connect(_on_scrollText_off_screen)
			listScrollTexts.push_back(scroll_text_instance)
			pass
		last_sentence = listScrollTexts[listScrollTexts.size()-1].scrolling_text
	pass
	
func load_bubbles():
	var file_text = load_text_file(bubbles_text_file_location % [current_level, current_scene])
	if (file_text != null): 
		# parse the string to get the parts out to fill the object
		# then when the object is created, add that to the dict
		var sceneList = file_text.split("/n", false, 0)
		var index = 0
		for scene:String in sceneList:
			var bubble_values = scene.split(";")
			var sceneBubbleArray = []
			for bubble in bubble_values:
				var text_bubble_instance:TextBubble = TextBubble.instantiate()
				var vals:PackedStringArray = bubble.split("|")
				if !vals[0].is_empty() and vals.size() > 1: 
					text_bubble_instance.bubble_text = vals[0]
					text_bubble_instance.bubble_pop.connect(_on_bubble_pop)
					text_bubble_instance.select_bubble.connect(_on_select_bubble)
					text_bubble_instance.correctness = int(vals[1])
					text_bubble_instance.id = randi_range(-10000,10000)
					sceneBubbleArray.append(text_bubble_instance)
				pass
			queuedTextBubbles.get_or_add(index, sceneBubbleArray)
			index+=1
			pass
		pass
	pass


# we need some kind of event catcher so the children who are the scrolling text can call back to it.
# when that signal is recieved then start off the next one. Each child won't know about the next.
func _on_scrollText_off_screen(node: Node2D): 
	print_debug("inside _on_scrollText_off_screen")
	remove_child(node)
	node.queue_free()
	listScrollTexts.remove_at(0)
	belinda_anim.stop()
	makeBubbles()
	scrollWords()
	pass

func _on_bubble_pop(bubble: TextBubble):
	# add score and trigger it's pop anim
	bubble.play_pop_anim()
	updateScore(score+base_score)
	activeTextBubblesDict.erase(bubble.id)
	# play pop sound
	pass

func _on_select_bubble(bubble: TextBubble):
	print_debug("inside select bubble")
	updateScore(score+(base_score*bubble.correctness))
	popAllBubbles()
	updateResponse(bubble.bubble_text)
	playReaction(bubble.correctness)
	await get_tree().create_timer(sentence_delay).timeout
	reset()
	
	pass
