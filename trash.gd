extends Area2D

@onready var sure_metni = $Label
var icerideki_oyuncu = null
var gecen_sure = 0.0

func _ready():
	sure_metni.visible = false

func _process(delta):
	if icerideki_oyuncu != null:
		gecen_sure += delta
		
		var kalan_sure = 5.0 - gecen_sure
		sure_metni.text = str("%.1f" % kalan_sure) + "s"
		
		if gecen_sure >= 5.0:
			icerideki_oyuncu.cop_topla()
			queue_free()

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		icerideki_oyuncu = body
		gecen_sure = 0.0
		sure_metni.visible = true

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		icerideki_oyuncu = null
		gecen_sure = 0.0
		sure_metni.visible = false
