extends Node3D

# Choose the star Modell i want to have
@export var star_mesh: Mesh
# Choose the path where the json file is
@export var json_file_path: String

# Covert GLON, GLAT and dist to x, y, z
func convertposition(gLat: float, gLong: float, dist: float) -> Vector3:
	
	# Convert angles from degrees to radians
	var gLongRad = deg_to_rad(gLong) 
	var gLatRad = deg_to_rad(gLat)

	# Cartesian coordinates conversion
	var x = dist * cos(gLatRad) * cos(gLongRad)
	var y = dist * cos(gLatRad) * sin(gLongRad)
	var z = dist * sin(gLatRad)
	
	return Vector3(x, y, z)

func _ready():
	
	# loading the JSON-File
	var json_file = FileAccess.open(json_file_path, FileAccess.READ)
	if json_file:
		var json_text = json_file.get_as_text()
		json_file.close()
		
		# JSON parsen
		var json_data = JSON.parse_string(json_text)
		# 
		# Überprüfen, ob das Parsing erfolgreich war und auf "stars" zugreifen
		if "stars" in json_data:
			var stars = json_data["stars"]
			for star_data in stars:
				# Stern instanziieren
				var star_instance = MeshInstance3D.new()
				star_instance.mesh = star_mesh
				
				# Galaktische Koordinaten aus der JSON-Datei lesen
				var gLat = float(star_data["GLAT"])
				var gLong = float(star_data["GLON"])
				var dist = float(star_data["dist"])
				
				# Berechnung der Position mit galacticToCartesian-Funktion
				var position = convertposition(gLat, gLong, dist)
				
				# Position des Sterns setzen
				star_instance.position = position
				
				# Farbe des Sterns setzen (Material erstellen und Farbe anwenden)
				var material = StandardMaterial3D.new()
				material.albedo_color = Color(
					float(star_data["kR"]),
					float(star_data["kG"]),
					float(star_data["kB"]),
				)
				star_instance.material_override = material
				# Emission aktivieren und auf Sternfarbe setzen
				material.emission_enabled = true
				material.emission = Color(
					float(star_data["kR"]),
					float(star_data["kG"]),
					float(star_data["kB"])
)
				material.emission_energy = 1.0  # Setze die Emissionsstärke, z.B. auf 2.0 für mehr Helligkeit
				# Stern zur Szene hinzufügen
				add_child(star_instance)
				
				# Beenden, wenn 100 Sterne erreicht sind
				if get_child_count() >= 100:
					break
		else:
			print("Fehler: 'stars' Schlüssel nicht in der JSON-Datei gefunden.")
	else:
		print("Fehler beim Laden der JSON-Datei: %s" % json_file_path)
