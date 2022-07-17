extends AudioStreamPlayer

func _on_Sound_finished():
    queue_free();
