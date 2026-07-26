
class_name LamaCppHelloWorld
extends Node


signal on_request_sent(user_question: String)
signal on_response_received(response_text: String)

@export var _server_url_and_port: String = "http://zbook:9000/v1/chat/completions"
@export var _model_name: String = "GLM-5.2_Nanbeige-4.1"

@export_multiline()
var _user_question_at_ready: String = "Hello, Lama.cpp!"

var _http_request: HTTPRequest
func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)
	if _user_question_at_ready != "":
		push_request(_user_question_at_ready)



func push_request(user_question: String):
	var url = _server_url_and_port
	
	var payload = {
		"model": _model_name,
		"messages": [
			{
				"role": "user",
				"content": user_question
			}
		],
		"temperature": 0
	}
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(payload)
	
	_http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	on_request_sent.emit(user_question)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		var response_text = body.get_string_from_utf8()
		on_response_received.emit(response_text)
		print("Status:", response_code)
		print(response_text)
	
