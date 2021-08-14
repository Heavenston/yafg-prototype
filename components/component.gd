extends Spatial
class_name Component

var is_component := true

func _ready():
	assert(get_parent().name == "components", "Components parents must be called components")
	assert(get_parent() is Spatial, "Components parents must be a spatial")
