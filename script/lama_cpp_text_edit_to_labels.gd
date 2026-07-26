
class_name LamaCppTextEditToLabels
extends Node

signal on_request_sent(user_question: String)
signal on_response_received_text(response_text: String)
signal on_response_received_json(response_text: String)
signal on_response_received_token_as_string(token_cound_as_string:String)
signal on_response_received_token_as_integer(token_cound:int)

@export var _lama_ask_server: LamaCppAskServer
@export var _text_edit: TextEdit
@export var _button_submit: Button
@export var _label_request: Label
@export var _label_response: TextEdit
@export var _label_response_in_json: TextEdit
@export var _label_response_token_count: Label
@export var _rich_text_label_response: RichTextLabel
@export var _use_sub_viewport: bool = false
@export var _sub_view: SubViewport

func _ready() -> void:
	if _button_submit != null:
		_button_submit.pressed.connect(submit_text)
	if _lama_ask_server != null:
		_lama_ask_server.on_response_received.connect(_on_response_received)
		_lama_ask_server.on_request_sent.connect(_on_request_sent)	

func submit_text() -> void:
	if _text_edit == null or _label_request == null or _label_response == null:
		return

	var user_question = _text_edit.text
	_label_request.text = "Request: " + user_question
	_label_response.text = "Response: ..."
	if _lama_ask_server != null:
		if not _use_sub_viewport:
			_lama_ask_server.push_request(user_question)
		else :
			var texture = _sub_view.get_texture()
			_lama_ask_server.push_request_with_a_texture(user_question, texture)

func _on_response_received(response_text: String) -> void:
	var json:String = response_text
	var json_obj = JSON.new()
	if json_obj.parse(response_text) == OK:
		json = JSON.stringify(json_obj.data, "\t")
		
	on_response_received_json.emit(json)
	if _label_response_in_json!=null:
		_label_response_in_json.text = json
	
	if _label_response != null:
		if json_obj.parse(response_text) == OK and json_obj.data.has("choices"):
			var choices = json_obj.data.get("choices", [])
			if choices.size() > 0 and choices[0].has("message"):
				var display_text = choices[0]["message"].get("content", response_text)
				_label_response.text =  display_text
				if _rich_text_label_response != null:
					_rich_text_label_response.bbcode_text = ""+display_text
				on_response_received_text.emit(display_text)

	if _label_response_token_count != null:
		var token_count :int= _fetch_token_in_json(json_obj)
		if _label_response_token_count != null:
			_label_response_token_count.text = "Token: " + str(token_count)
		on_response_received_token_as_string.emit(str(token_count))
		on_response_received_token_as_integer.emit(token_count)


func is_numeric_value(text: String) -> bool:
	if text.is_valid_float():
		return true
	if text.is_valid_int():
		return true
	return false

func _on_request_sent(user_question: String) -> void:
	if _label_request != null:
		_label_request.text = "Request: " + user_question

func _fetch_token_in_json(json:JSON) -> int:
	#"total_tokens": 1088.0
	if json.data.has("usage"):
		var usage = json.data.get("usage", {})
		if usage.has("total_tokens"):
			var total_tokens = usage.get("total_tokens", 0)
			return total_tokens
	return 0
