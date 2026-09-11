class_name SupplyArt
extends RefCounted
## Shared world pickup silhouettes; no presentation RNG or collision changes.
static func draw(c, p: Vector2, kind: String) -> void:
	var tint:=Color("8ed6e8") if kind=="energy" else Color("87d69f")
	c.draw_rect(Rect2(p+Vector2(-12,7),Vector2(24,7)),Color("14242c99"))
	c.draw_rect(Rect2(p-Vector2(10,12),Vector2(20,24)),Color("14242c"))
	c.draw_rect(Rect2(p-Vector2(8,10),Vector2(16,20)),Color("46636a"))
	c.draw_rect(Rect2(p-Vector2(6,8),Vector2(12,16)),Color("243d46"))
	c.draw_line(p+Vector2(-8,-10),p+Vector2(8,-10),Color("bdd3ce"),2)
	if kind=="repair":
		c.draw_rect(Rect2(p-Vector2(2,6),Vector2(4,12)),tint)
		c.draw_rect(Rect2(p-Vector2(6,2),Vector2(12,4)),tint)
	else:
		c.draw_rect(Rect2(p+Vector2(-4,-14),Vector2(8,3)),Color("efc16b"))
		c.draw_colored_polygon(PackedVector2Array([p+Vector2(2,-8),p+Vector2(-5,2),p+Vector2(-1,2),p+Vector2(-2,8),p+Vector2(6,-2),p+Vector2(1,-2)]),tint)
