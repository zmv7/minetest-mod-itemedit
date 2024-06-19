local F = minetest.formspec_escape

local function iefs(name, witem, index)
	local start = index - 1
	local meta = witem:get_meta()
	if not meta then return end
	local toolcaps = dump(witem:get_tool_capabilities(),"")
	local descr = meta:get("description") or witem:get_description()
	local color = meta:get_string("color")
	local count_meta = meta:get_string("count_meta")
	local count_alignment = meta:get_string("count_alignment")
	local range = meta:get_string("range")
	local inventory_image = meta:get_string("inventory_image")
	local inventory_overlay = meta:get_string("inventory_overlay")
	local wield_image = meta:get_string("wield_image")
	local wield_overlay = meta:get_string("wield_overlay")
	local wield_scale = meta:get_string("wield_scale")

	minetest.show_formspec(name, "itemedit", "size[16,9.1]" ..
	"style[toolcaps;font=mono]" ..
	"list[current_player;main;0.2,0.2;1,1;"..tostring(start).."]" ..
	"textarea[1.4,0.1;3,1.3;description;;"..descr.."]" ..
	"field[0.5,1.7;2.5,1;color;Color;"..color.."]" ..
	"field_close_on_enter[color;false]" ..
	"field[3,1.7;1.4,1;range;Range;"..range.."]" ..
	"field_close_on_enter[range;false]" ..
	"field[0.5,2.7;2.5,1;count_meta;Count meta;"..count_meta.."]" ..
	"field_close_on_enter[count_meta;false]" ..
	"field[3,2.7;1.4,1;count_meta_alignment;Alignment;"..count_alignment.."]" ..
	"field_close_on_enter[count_meta_alignment;false]" ..
	"field[0.5,3.7;3.9,1;inventory_image;Inventory image;"..inventory_image.."]" ..
	"field_close_on_enter[inventory_image;false]" ..
	"field[0.5,4.7;3.9,1;inventory_overlay;Inventory overlay;"..inventory_overlay.."]" ..
	"field_close_on_enter[inventory_overlay;false]" ..
	"field[0.5,5.7;3.9,1;wield_image;Wield image;"..wield_image.."]" ..
	"field_close_on_enter[wield_image;false]" ..
	"field[0.5,6.7;3.9,1;wield_overlay;Wield overlay;"..wield_overlay.."]" ..
	"field_close_on_enter[wield_overlay;false]" ..
	"field[0.5,7.7;3.9,1;wield_scale;Wield scale (X, Y, Z);"..wield_scale.."]" ..
	"field_close_on_enter[wield_scale;false]" ..
	"textarea[4.6,0.4;11.5,9.1;toolcaps;Tool capabilities;"..F(toolcaps).."]" ..
	"button[0.2,8.2;3.9,1;apply;Apply]" ..
	"button[4.3,8.2;11.5,1;apply_toolcaps;Apply toolcaps]")
end

minetest.register_privilege("itemedit","Allows to use item editor")
minetest.register_chatcommand("itemedit",{
  description = "Modify a wielded item",
  privs = {itemedit=true},
  func = function(name,param)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false, "Error getting player"
	end
	local witem = player:get_wielded_item()
	local index = player:get_wield_index()
	if not (witem and index) then
		return false, "Error getting wielded item"
	end
	if witem:get_name() == "" then
		return false, "Please take item in the hand"
	end
	iefs(name,witem,index)
end})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "itemedit" then return end
	local witem = player:get_wielded_item()
	local meta = witem:get_meta()
	if fields.apply then
		meta:set_string("description",fields.description)
		meta:set_string("color",fields.color)
		meta:set_string("range",tonumber(fields.range))
		meta:set_string("count_meta",fields.count_meta)
		meta:set_string("count_alignment",tonumber(fields.count_alignment))
		meta:set_string("inventory_image",fields.inventory_image)
		meta:set_string("inventory_overlay",fields.inventory_overlay)
		meta:set_string("wield_image",fields.wield_image)
		meta:set_string("wield_overlay",fields.wield_overlay)
		meta:set_string("wield_scale",fields.wield_scale)
		meta:set_tool_capabilities(out)
		player:set_wielded_item(witem)
	end
	if fields.apply_toolcaps then
		if not fields.toolcaps or fields.toolcaps == "" then
			meta:set_tool_capabilities(nil)
			player:set_wielded_item(witem)
			return
		end
		local good, out = pcall(loadstring("return "..fields.toolcaps))
		if not good or type(out) ~= "table" then
			minetest.chat_send_player(player:get_player_name(), "There is an error in toolcaps: "..tostring(out))
			return
		end
		meta:set_tool_capabilities(out)
		player:set_wielded_item(witem)
	end
end)
