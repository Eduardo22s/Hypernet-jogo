extends Node3D

var SpectrumAnalyzer: AudioEffectSpectrumAnalyzerInstance
var IsPlaying = false

# Intervalo entre ondas: menor = mais ondas por segundo
var WaveInterval = 0.1

# Temporizador usado para controlar o intervalo entre ondas
var WaveTimer = 0.0

# Tempo que cada onda permanece na cena antes de ser destruída
var WaveLifetime = 1.1


func _ready():
	var BusIndex = AudioServer.get_bus_index("Master")

	SpectrumAnalyzer = AudioServer.get_bus_effect_instance(
		BusIndex,
		0
	)


func _process(Delta):
	if SpectrumAnalyzer == null:
		return

	if IsPlaying == false:
		CheckAudioStarted()
	else:
		UpdateWaveGeneration(Delta)


func CheckAudioStarted():
	var Magnitude = SpectrumAnalyzer.get_magnitude_for_frequency_range(
		20.0,
		20000.0
	).length()

	if Magnitude > 0.0001:
		IsPlaying = true
		CreateWave()


func UpdateWaveGeneration(Delta):
	WaveTimer += Delta

	if WaveTimer >= WaveInterval:
		WaveTimer = 0.0
		CreateWave()


func CreateWave():
	if SpectrumAnalyzer == null:
		return

	# Quantidade de pontos: maior = círculo mais suave
	var PointCount = 64

	# Tamanho inicial do círculo
	var Radius = 5.0

	# Altura mínima das ondas - NÃO MEXER NESSE!!!
	var MinHeight = 1.0

	# Altura máxima das ondas = Mais esticadas / Altas
	var MaxHeight = 6.0

	# Quantidade de repetições do padrão de áudio no círculo 
	var WaveRepetitions = 8

	# Quantidade de pontos usados para suavizar a forma = Menos Pontiagudo
	var SmoothRadius = 5

	var PatternPointCount = PointCount / WaveRepetitions

	var Magnitudes = []
	var HighestMagnitude = 0.0


	# =========================================================
	# CAPTURA DO ESPECTRO
	# =========================================================

	for Index in PatternPointCount:
		var FrequencyStart = 20.0 * pow(
			20000.0 / 20.0,
			float(Index) / float(PatternPointCount)
		)

		var FrequencyEnd = 20.0 * pow(
			20000.0 / 20.0,
			float(Index + 1) / float(PatternPointCount)
		)

		var Magnitude = SpectrumAnalyzer.get_magnitude_for_frequency_range(
			FrequencyStart,
			FrequencyEnd
		).length()

		Magnitudes.append(Magnitude)

		if Magnitude > HighestMagnitude:
			HighestMagnitude = Magnitude


	# =========================================================
	# REPETIÇÃO DO PADRÃO AO REDOR DO CÍRCULO
	# =========================================================

	var RepeatedMagnitudes = []

	for Index in PointCount:
		var PatternIndex = Index % PatternPointCount

		RepeatedMagnitudes.append(
			Magnitudes[PatternIndex]
		)


	# =========================================================
	# SUAVIZAÇÃO
	# =========================================================

	var SmoothedMagnitudes = []

	for Index in PointCount:
		var TotalMagnitude = 0.0
		var TotalWeight = 0.0

		for Offset in range(
			-SmoothRadius,
			SmoothRadius + 1
		):
			var SampleIndex = (
				Index
				+ Offset
				+ PointCount
			) % PointCount

			var Distance = abs(Offset)

			var Weight = 1.0 / (
				1.0
				+ float(Distance)
			)

			TotalMagnitude += (
				RepeatedMagnitudes[SampleIndex]
				* Weight
			)

			TotalWeight += Weight

		var SmoothedMagnitude = (
			TotalMagnitude
			/ TotalWeight
		)

		SmoothedMagnitudes.append(
			SmoothedMagnitude
		)


	# =========================================================
	# CRIAÇÃO DO CÍRCULO
	# =========================================================

	var Vertices = PackedVector3Array()

	for Index in PointCount + 1:
		var Angle = (
			float(Index)
			/ float(PointCount)
		) * TAU

		# O raio permanece sempre igual.
		# O áudio altera somente a altura Y.
		var X = cos(Angle) * Radius
		var Z = sin(Angle) * Radius

		var SpectrumIndex = Index % PointCount

		var NormalizedMagnitude = 0.0

		if HighestMagnitude > 0.0:
			NormalizedMagnitude = (
				SmoothedMagnitudes[SpectrumIndex]
				/ HighestMagnitude
			)

		NormalizedMagnitude = clamp(
			NormalizedMagnitude,
			0.0,
			1.0
		)

		var Height = lerp(
			MinHeight,
			MaxHeight,
			NormalizedMagnitude
		)

		Height = clamp(
			Height,
			MinHeight,
			MaxHeight
		)

		var Position = Vector3(
			X,
			Height,
			Z
		)

		Vertices.append(Position)


	CreateMesh(
		Vertices,
		Radius
	)


func CreateMesh(
	Vertices: PackedVector3Array,
	Radius: float
):
	var SurfaceArray = []

	SurfaceArray.resize(
		Mesh.ARRAY_MAX
	)

	SurfaceArray[Mesh.ARRAY_VERTEX] = Vertices


	var WaveMesh = ArrayMesh.new()

	WaveMesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_LINE_STRIP,
		SurfaceArray
	)


	var WaveInstance = MeshInstance3D.new()

	WaveInstance.mesh = WaveMesh


	var WaveMaterial = preload(
		"res://global/cenas/VFX/_Shaders/ShaderSonoro/SM_Wave.tres"
	).duplicate()


	WaveMaterial.set_shader_parameter(
		"WaveRadius",
		Radius
	)


	WaveMaterial.set_shader_parameter(
		"WaveStartTime",
		Time.get_ticks_msec() / 1000.0
	)


	WaveMaterial.set_shader_parameter(
		"ExpansionOffset",
		0.7
	)


	WaveInstance.material_override = WaveMaterial

	add_child(WaveInstance)


	# =========================================================
	# DESTRUIÇÃO AUTOMÁTICA DA ONDA
	# =========================================================

	await get_tree().create_timer(
		WaveLifetime
	).timeout

	if is_instance_valid(WaveInstance):
		WaveInstance.queue_free()
