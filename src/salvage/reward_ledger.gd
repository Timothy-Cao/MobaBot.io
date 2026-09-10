class_name RewardLedger
extends RefCounted
## Saveable simulation data. Presentation cannot claim or roll rewards.
static func empty() -> Dictionary:
	return {"chests":0,"points":0,"credits":0,"items":{}}

static func valid(data: Variant) -> bool:
	if not data is Dictionary or not data.get("items") is Dictionary: return false
	for key in ["chests","points","credits"]:
		if not ForgeEquipment.integer(data.get(key),0,10000000): return false
	for id in data.items:
		if not ForgeEquipment.ITEMS.has(id) or not ForgeEquipment.integer(data.items[id],1,100000): return false
	return true

static func merge(into: Dictionary, receipt: Dictionary) -> void:
	for key in ["chests","points","credits"]: into[key]+=receipt[key]
	for id in receipt.items: into.items[id]=int(into.items.get(id,0))+int(receipt.items[id])
