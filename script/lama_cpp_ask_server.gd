
class_name LamaCppAskServer
extends Node

signal on_request_sent(user_question: String)
signal on_response_received(response_text: String)

@export var _server_url_and_port: String = "http://zbook:9000/v1/chat/completions"
@export var _model_name: String = "GLM-5.2_Nanbeige-4.1"

@export var _max_tokens: int = 28000
@export var _temperature: float = 0.5
@export var _top_p: float = 1.0
@export var _n: int = 1	

var _http_request: HTTPRequest

func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func push_request(user_question: String):
	push_request_async(user_question)


func push_request_async(user_question: String) -> void:
	var url = _server_url_and_port
	var payload = {
		"model": _model_name,
		"messages": [
			{
				"role": "user",
				"content": user_question
			}
		],
		"temperature": _temperature,
		"max_tokens": _max_tokens,
		"top_p": _top_p,
		"n": _n
	}
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(payload)
	
	on_request_sent.emit(user_question)
	
	var result = await _http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)



func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		var response_text = body.get_string_from_utf8()
		on_response_received.emit(response_text)
		print("Status:", response_code)
		print(response_text)


func push_request_with_a_texture(user_question:String, texture:Texture2D):
	var url = _server_url_and_port
	var image := texture.get_image()
	var png_bytes: PackedByteArray = image.save_png_to_buffer()
	var payload = {
		"model": _model_name,
		"messages": [
			{
				"role": "user",
				"content": user_question
			}
		],
		"temperature": _temperature,
		"max_tokens": _max_tokens,
		"top_p": _top_p,
		"n": _n,
		"image": Marshalls.raw_to_base64(png_bytes)
	}
	
	var headers = ["Content-Type: application/json"]
	var json_string = JSON.stringify(payload)
	
	var result = await _http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	on_request_sent.emit(user_question)
	
