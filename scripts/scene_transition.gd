extends CanvasLayer

const FADE_TIME := 0.5

var _transitioning := false
var _cover: ColorRect

func _ready() -> void:
	layer = 100
	_cover = ColorRect.new()
	_cover.color = Color(0.01, 0.012, 0.02, 0.0)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_cover)


func change_scene(scene_path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await _fade_to(0.0)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false


func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_cover, "color:a", target_alpha, FADE_TIME)
	await tween.finished
