--[[
	Attached to https://www.hiveworkshop.com/threads/a-comprehensive-guide-to-mapping-in-lua.341880/
	Manually chosen collection of hidden natives and useful natives from common.ai
]]

---@meta
---@diagnostic disable

_GV = nil ---@type userdata
globals = _GV

---Converts a 4-digit string representing an object id (e.g 'hfoo') to an integer.
---@param typeId string
---@return integer
function FourCC(typeId) end

---Returns an empty table, where accessing any unused key will return the specified default value.
---The created table will have a metatable attached. Changing this metatable (or rather its __index metamethod) will break behaviour.
---@param defaultValue any
---@return table emptyTable
function __jarray(defaultValue) end

---Returns true, if the specified unit is alive, and false otherwise.
---Always use this over IsUnitAliveBJ (doesn't suffer from the known bugs of IsUnitAliveBJ).
---@param whichUnit unit
---@return boolean isUnitAlive
function UnitAlive(whichUnit) end

---Returns the gold cost for the specified unittype as set in the object editor.
---Using this on a hero unittype will crash the game.
---@param unitTypeId integer
---@return integer
function GetUnitGoldCost(unitTypeId) end

---Returns the wood cost for the specified unittype as set in the object editor.
---Using this on a hero unittype will crash the game.
---@param unitTypeId integer
---@return integer
function GetUnitWoodCost(unitTypeId) end

---Returns the build time in seconds for the specified unittype as set in the object editor.
---@param unitTypeId integer
---@return integer buildTimeInSeconds
function GetUnitBuildTime(unitTypeId) end

---Returns the number of living units of the specified unittype currently owned by the specified player.
---Counts units in training, heroes during revive and buildings in construction. Doesn't count dead units.
---Buildings in the process of upgrading count as the type they are upgrading to.
---@param p player
---@param unittypeid integer
---@return integer
function GetPlayerUnitTypeCount(p, unittypeid) end

---Unlearns the specified hero ability from the specified hero. Ability resets to level 0 and can be skilled again. Hero points previously spent on the ability are lost.
---Does not work on normal abilities.
---@param whichHero unit
---@param heroAbilCode integer object id of the hero ability to unlearn.
function BlzDeleteHeroAbility(whichHero, heroAbilCode) end

---Sets the primary attribute (str/int/agi) of the specified hero to the specified amount.
---@param whichHero unit
---@param amount integer
function BlzSetHeroPrimaryStat(whichHero, amount) end

---@alias heroattributeId
---| 1 # GetHandleId( HERO_ATTRIBUTE_STR )
---| 2 # GetHandleId( HERO_ATTRIBUTE_INT )
---| 3 # GetHandleId( HERO_ATTRIBUTE_AGI )

---Sets the specified attribute (str, int or dex) of the specified hero to the specified amount.
---The attribute is represented by an integer (see below).
---@param whichHero unit
---@param statId heroattributeId
---@param amount integer
function BlzSetHeroStatEx(whichHero, statId, amount) end

---Returns the integer representation of the primary attribute of the specified hero (not the amount of that stat owned by the hero!).
---Use ConvertHeroAttribute(i) on the return value to get the actual heroattribute (such as HERO_ATTRIBUTE_STR for the human paladin) and GetHandleId() to convert back.
---@param whichHero unit
---@return heroattributeId
function BlzGetHeroPrimaryStat(whichHero) end

---Returns the amount that the specified hero owns of the specified hero attribute (str/int/agi).
---The stat is represented by an integer.
---@param whichHero unit
---@param statId heroattributeId
---@return integer
function BlzGetHeroStat(whichHero, statId) end

---@alias armortypeId
---| 0 # GetHandleId( ARMOR_TYPE_WHOKNOWS )
---| 1 # GetHandleId( ARMOR_TYPE_FLESH )
---| 2 # GetHandleId( ARMOR_TYPE_METAL )
---| 3 # GetHandleId( ARMOR_TYPE_WOOD )
---| 4 # GetHandleId( ARMOR_TYPE_ETHREAL )
---| 5 # GetHandleId( ARMOR_TYPE_STONE )

---Returns the integer representation of the armortype of the specified unit.
---Use ConvertArmorType(i) on the return value to receive the actual armortype (such as ARMOR_TYPE_METAL for the human paladin) and GetHandleId() to convert back.
---@param whichUnit unit
---@return armortypeId
function BlzGetUnitArmorType(whichUnit) end

---@alias movetypeId
---| 0 # GetHandleId( MOVE_TYPE_UNKNOWN )
---| 1 # GetHandleId( MOVE_TYPE_FOOT )
---| 2 # GetHandleId( MOVE_TYPE_FLY )
---| 4 # GetHandleId( MOVE_TYPE_HORSE )
---| 8 # GetHandleId( MOVE_TYPE_HOVER )
---| 16 # GetHandleId( MOVE_TYPE_FLOAT )
---| 32 # GetHandleId( MOVE_TYPE_AMPHIBIOUS )
---| 64 # GetHandleId( MOVE_TYPE_UNBUILDABLE )

---Returns the integer representation of the movetype of the specified unit.
---Use ConvertMoveType(i) on the return value to receive the actual movetype (such as MOVE_TYPE_FOOT for the human paladin) and GetHandleId() to convert back.
---@param whichUnit unit
---@return movetypeId
function BlzGetUnitMovementType(whichUnit) end

---Sets the specified movetype (represented as integer) to the specified unit.
---Doesn't seem to properly apply the pathing properties of the new movetype (like setting a movetype to flying doesn't make the unit able to get across cliffs). Needs more testing.
---@param whichUnit unit
---@param movetypeId movetypeId
function BlzSetUnitMovementType(whichUnit, movetypeId) end
