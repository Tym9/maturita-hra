extends Node2D

const Level1Scene = preload("res://level1.tscn")

func _ready():
	print("=== SPUŠTĚNÍ AUTOMATICKÉHO TESTU NPC A DIALOGOVÉHO SYSTÉMU ===")
	
	# Test 1: Ověření existence DialogueManager autoloadu
	assert(DialogueManager != null, "DialogueManager autoload musí existovat v projektu")
	assert(DialogueManager.dialogue_box != null, "DialogueManager musí mít inicializované DialogueBox")
	print("[PASS] TEST 1: DialogueManager autoload funkční")
	
	# Test 2: Ověření přítomnosti NPC a EventTriggeru napříč kapitolami
	var level = Level1Scene.instantiate()
	add_child(level)
	
	var npcs_node = level.get_node_or_null("NPCs")
	assert(npcs_node != null, "Uzel NPCs musí existovat v level1")
	
	var otis = npcs_node.get_node_or_null("Otis")
	var trigger = npcs_node.get_node_or_null("EventTrigger_ShaftWarning")
	
	assert(otis != null, "Otis musí existovat v Levelu 1")
	assert(trigger != null, "EventTrigger musí existovat v Levelu 1")
	
	var level2 = preload("res://level2.tscn").instantiate()
	assert(level2.get_node_or_null("NPCs/Rusty") != null, "Rusty musí existovat v Levelu 2")
	level2.queue_free()
	
	var level3 = preload("res://level3.tscn").instantiate()
	assert(level3.get_node_or_null("NPCs/Vesper") != null, "Vesper musí existovat v Levelu 3")
	level3.queue_free()
	print("[PASS] TEST 2: Všechna 3 NPC i EventTrigger správně rozmístěna v kapitolách 1, 2 a 3")
	
	# Test 3: Zahájení dialogu s Otisem
	var player = level.get_node("Player")
	assert(player != null, "Player musí existovat")
	assert(player.is_talking == false, "Hráč na začátku nemluví")
	
	otis.talk()
	assert(DialogueManager.is_active == true, "DialogueManager musí být aktivní po zahájení dialogu")
	assert(player.is_talking == true, "Hráč musí mít is_talking == true během rozhovoru")
	assert(DialogueManager.dialogue_box.visible == true, "DialogueBox musí být viditelné")
	assert(DialogueManager.dialogue_box.current_pages.size() == 3, "Otis má mít 3 stránky dialogu")
	print("[PASS] TEST 3: Zahájení dialogu s Otisem a pozastavení hráče OK")
	
	# Test 4: Simulace proklikání všech stránek dialogu
	# Stránka 0: okamžité dokončení psacího stroje + přechod
	DialogueManager.dialogue_box.handle_input() # Dokončí psací stroj
	DialogueManager.dialogue_box.handle_input() # Přejde na stranu 1
	assert(DialogueManager.dialogue_box.current_page_idx == 1, "Přešli jsme na stranu 1")
	
	DialogueManager.dialogue_box.handle_input()
	DialogueManager.dialogue_box.handle_input() # Přejde na stranu 2
	assert(DialogueManager.dialogue_box.current_page_idx == 2, "Přešli jsme na stranu 2")
	
	DialogueManager.dialogue_box.handle_input()
	DialogueManager.dialogue_box.handle_input() # Ukončení dialogu
	
	assert(DialogueManager.is_active == false, "DialogueManager musí být neaktivní po skončení")
	assert(player.is_talking == false, "Hráč musí mít is_talking == false po skončení")
	assert(otis.has_talked == true, "Otis má mít has_talked == true")
	print("[PASS] TEST 4: Proklikání stránek a obnovení pohybu hráče OK")
	
	# Test 5: Druhý rozhovor s Otisem použije opakovaný dialog
	otis.talk()
	assert(DialogueManager.is_active == true, "Druhý rozhovor zahájen")
	assert(DialogueManager.dialogue_box.current_pages == otis.repeat_dialogue_pages, "Použit repeat_dialogue_pages")
	DialogueManager.dialogue_box.handle_input()
	DialogueManager.dialogue_box.handle_input()
	assert(DialogueManager.is_active == false, "Druhý rozhovor ukončen")
	print("[PASS] TEST 5: Opakovaný rozhovor (repeat dialogue) funkční")
	
	# Test 6: Vyzkoušení EventTriggeru
	trigger._on_body_entered(player)
	assert(DialogueManager.is_active == true, "EventTrigger spustil dialog")
	assert(DialogueManager.dialogue_box.name_label.text.begins_with("Pohled do propasti"), "Správný název triggeru")
	DialogueManager.close_dialogue()
	assert(DialogueManager.is_active == false, "EventTrigger dialog ukončen")
	print("[PASS] TEST 6: EventTrigger automatický dialog funkční")
	
	print("=== VŠECHNY TESTY NPC A DIALOGŮ ÚSPĚŠNĚ PROŠLY (100% OK) ===")
	get_tree().quit(0)
