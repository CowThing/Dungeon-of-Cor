
extends HScrollBar


func _on_Settings_Slider_value_changed( value ):
	get_node("SpinBox").set_value(value)


func _on_SpinBox_value_changed( value ):
	set_value(value)


