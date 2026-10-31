extends CharacterBody2D

const HIZ = 120.0
var toplanan_cop = 0
var makine_envanteri = 0
var makine_kurma_suresi = 0.0

var aktif_makine_sayisi = 0
var hava_kalitesi = 0.0 
var oyun_bitti = false

@onready var kamera = $Camera2D
@onready var uretim_metni = $Label

# UI (Arayüz) Bağlantıları
@onready var UI_Hava = get_parent().get_node("Interface/air_label")
@onready var UI_Envanter = get_parent().get_node("Interface/inventory_label")
@onready var UI_Kazanma = get_parent().get_node("Interface/WinText") # Yeni dev yazı
@onready var global_isik = get_parent().get_node("CanvasModulate")

# Yeni kaydettiğin bağımsız filtre şablonu
var makine_sablonu = preload("res://filtre.tscn")

func _ready():
	# Oyunu doğrudan Tam Ekran (Full Screen) başlatır
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	uretim_metni.visible = false
	UI_Kazanma.visible = false # Başlangıçta dev yazıyı gizle
	guncelle_ui()
	# Koyu, kirli atmosfer
	global_isik.color = Color(0.4, 0.3, 0.1) 

func _physics_process(delta):
	if oyun_bitti:
		return 

	var yon = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = yon * HIZ
	move_and_slide()

	# Havayı Temizleme Matematiği
	if aktif_makine_sayisi > 0 and hava_kalitesi < 100.0:
		hava_kalitesi += (aktif_makine_sayisi * delta)
		
		if hava_kalitesi >= 100.0:
			hava_kalitesi = 100.0
			oyunu_kazandin()
			
		guncelle_ui()
		var aydinlik = 0.4 + (hava_kalitesi / 100.0) * 0.6
		global_isik.color = Color(aydinlik, aydinlik, aydinlik)

	# Çöpten Makine Üretme (Space)
	if Input.is_action_pressed("ui_accept"):
		if toplanan_cop >= 5:
			makine_kurma_suresi += delta
			uretim_metni.visible = true
			
			var kalan = 5.0 - makine_kurma_suresi
			uretim_metni.text = "Filtre Uretiliyor: " + str("%.1f" % kalan) + "s"
			
			if makine_kurma_suresi >= 5.0:
				makine_uret()
				makine_kurma_suresi = 0.0
				uretim_metni.visible = false
	else:
		makine_kurma_suresi = 0.0
		uretim_metni.visible = false

	# Makineyi Haritaya Koyma (E Tuşu)
	if Input.is_action_just_pressed("ui_accept") == false:
		if Input.is_physical_key_pressed(KEY_E):
			if makine_envanteri > 0:
				makine_yerlestir()

func cop_topla():
	toplanan_cop += 1
	guncelle_ui()

func makine_uret():
	toplanan_cop -= 5
	makine_envanteri += 1
	guncelle_ui()

func makine_yerlestir():
	makine_envanteri -= 1
	aktif_makine_sayisi += 1
	guncelle_ui()
	
	var yeni_makine = makine_sablonu.instantiate()
	yeni_makine.global_position = self.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	get_parent().add_child(yeni_makine)

func guncelle_ui():
	UI_Hava.text = "Hava Kalitesi: %" + str(int(hava_kalitesi))
	UI_Envanter.text = "Envanter: " + str(makine_envanteri) + " Filtre | Cop: " + str(toplanan_cop)

func oyunu_kazandin():
	oyun_bitti = true
	# Sol üstteki ufak yazıları gizle
	UI_Hava.visible = false 
	UI_Envanter.visible = false
	# Dev ekran yazısını göster
	UI_Kazanma.visible = true 

func _input(event):
	# Tam ekrandan çıkmak için ESC tuşunu kullan
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			kamera.zoom.x = clamp(kamera.zoom.x + 0.2, 1.0, 6.0)
			kamera.zoom.y = clamp(kamera.zoom.y + 0.2, 1.0, 6.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			kamera.zoom.x = clamp(kamera.zoom.x - 0.2, 1.0, 6.0)
			kamera.zoom.y = clamp(kamera.zoom.y - 0.2, 1.0, 6.0)
