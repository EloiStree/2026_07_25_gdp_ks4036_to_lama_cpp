extends Node


@export var _ks4036: SensorKS4036InOutFacade

@export_multiline var _text_context_fixed:String
@export_multiline var _text_context_changing:String
@export var _refresh_time_seconds:float =1



func  _ready() -> void:
	## create a timer
	var timer = Timer.new()
	timer.wait_time = _refresh_time_seconds
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)


func build_fixed_text_context() -> void:
	var sb = ""
	sb += "KS4036: \n"
	## Local position of ks4036 element
	## To add later.

	_text_context_fixed = sb

	
func _on_timer_timeout() -> void:
	if _ks4036 != null:
		var sb = ""
		sb += "KS4036: \n"
		sb += "  left_motor_percent_11: " + str(_ks4036.get_motor_left_percent_11()) + "\n"
		sb += "  right_motor_percent_11: " + str(_ks4036.get_motor_right_percent_11()) + "\n"
		sb += "  led_left_color: " + str(_ks4036.get_led_left_color()) + "\n"
		sb += "  led_right_color: " + str(_ks4036.get_led_right_color()) + "\n"
		sb += "  display_ssd1306_128x64: " + str(_ks4036.get_display_ssd1306_128x64()) + "\n"
		_text_context_changing = sb	


