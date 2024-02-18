local L = BigWigs:NewBossLocale("Grubbis Discovery", "itIT")
if not L then return end
if L then
	--L.bossName = "Grubbis"
	--L.aoe = "AoE melee damage"
	--L.cloud = "A cloud reached the boss"
	--L.cone = "\"Frontal\" cone" -- "Frontal" Cone, it's a rear cone (he's farting)
	--L.warmup_say_chat_trigger = "Gnomeregan" -- There are still ventilation shafts actively spewing radioactive material throughout Gnomeregan.
	--L.interruptable = "Interruptible"
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "itIT")
if L then
	--L.bossName = "Viscous Fallout"
	--L.desiccated_fallout = "Desiccated Fallout" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "itIT")
if L then
	--L.bossName = "Crowd Pummeler 9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "itIT")
if L then
	--L.bossName = "Electrocutioner 6000"
	L.ready = "|cff20ff20Pronto|r"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "itIT")
if L then
	--L.bossName = "Mechanical Menagerie"
	--L.attack_buff = "+50% attack speed"
	--L.boss_at_hp = "%s at %d%%" -- BOSS_NAME at 50%

	--L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|tDragon"
	--L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|tSheep"
	--L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|tSquirrel"
	--L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|tChicken"
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "itIT")
if L then
	--L.bossName = "Mekgineer Thermaplugg"
	L.ready = "|cff20ff20Pronto|r"
	--L.red_button = "Red Button"
end
