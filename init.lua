local function FE(text)
  return core.formspec_escape(text)
end
local function get_fs(name, witem,index)
  local start = index - 1 or 0
  local meta = witem:get_meta()
  if not meta then return end
  local toolcaps = witem:get_tool_capabilities()
  if not toolcaps then return end
  local descr = meta:get("description") or witem:get_description()
  local color = meta:get_string("color",'')
  local count_meta = meta:get_string("count_meta")
  local full_punch_interval = dump(toolcaps.full_punch_interval,'')
  local max_drop_level = dump(toolcaps.max_drop_level,'')
  local groupcaps = FE(core.serialize(toolcaps.groupcaps))
  local damage_groups = FE(core.serialize(toolcaps.damage_groups))

  local fs = "size[10.2,12]" ..
"list[current_player;main;9,0.1;1,1;"..start.."]" ..
"field[0.4,0.6;3,1;description;Description;"..descr.."]" ..
"field_close_on_enter[description;false]" ..
"field[0.4,1.6;3,1;color;Color;"..color.."]" ..
"field_close_on_enter[color;false]" ..
"field[0.4,2.6;3,1;count_meta;Count_meta;"..count_meta.."]" ..
"field_close_on_enter[count_meta;false]" ..
"field[3.4,0.6;2.5,1;full_punch_interval;Full punch interval;"..full_punch_interval.."]" ..
"field_close_on_enter[full_punch_interval;false]" ..
"field[3.4,1.6;2.5,1;max_drop_level;Max drop level;"..max_drop_level.."]" ..
"field_close_on_enter[max_drop_level;false]" ..
"textarea[0.4,3.5;10,4.8;groupcaps;Groupcaps;"..groupcaps.."]" ..
"textarea[0.4,7.9;10,4.8;damage_groups;Damage groups;"..damage_groups.."]" ..
"button[3.1,2.3;2.2,1;apply;Apply]"
  core.show_formspec(name,"itemeditor",fs)
end

core.register_privilege("itemedit","Allows to use item editor")
core.register_chatcommand("itemedit",{
  description = "Modify a wielded item",
  privs = {itemedit=true},
  func = function(name,param)
    local player = core.get_player_by_name(name)
    if not player then return false, "No Player" end
    local witem = player:get_wielded_item()
    local index = player:get_wield_index()
    if not witem then return false, "Error getting wielded item" end
    if witem:get_name() == "" then return false, "Please take item in hand" end
    get_fs(name,witem,index)
end})

core.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "itemeditor" then return end
  local name = player:get_player_name()
  if not name then return end
  local witem = player:get_wielded_item()
  local meta = witem:get_meta()
  if fields.apply then
    meta:set_string("description",fields.description)
    meta:set_string("color",fields.color)
    meta:set_string("count_meta",fields.count_meta)
    meta:set_tool_capabilities({full_punch_interval=fields.full_punch_interval,max_drop_level=fields.max_drop_level,groupcaps=core.deserialize(fields.groupcaps),damage_groups=core.deserialize(fields.damage_groups)})
    player:set_wielded_item(witem)
  end
end)
