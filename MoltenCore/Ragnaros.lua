--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ragnaros Classic", 409, 1528)
if not mod then return end
mod:RegisterEnableMob(
	11502, -- Ragnaros
	12143, -- Son of Flame
	12018, -- Majordomo Executus
	54404, -- Majordomo Executus (Retail)
	228438, -- Ragnaros (Season of Discovery)
	228437 -- Majordomo Executus (Season of Discovery)
)
mod:SetEncounterID(672)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local sonsDead = 0
local timer = nil
local warmupTimer = mod:Retail() and 74 or 84
local sonsTracker = {}
local sonsMarker = 8
local lineCount = 3
local UpdateInfoBoxList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.submerge_trigger = "COME FORTH,"

	L.warmup_icon = "Achievement_boss_ragnaros"

	L.submerge = "Submerge"
	L.submerge_desc = "Warn for Ragnaros' submerge."
	L.submerge_icon = "Achievement_boss_ragnaros"
	L.submerge_message = "Ragnaros down for 90 sec!"
	L.submerge_bar = "Submerge"

	L.emerge = "Emerge"
	L.emerge_desc = "Warn for Ragnaros' emerge."
	L.emerge_icon = "Achievement_boss_ragnaros"
	L.emerge_message = "Ragnaros emerged, 3 mins until submerge!"
	L.emerge_bar = "Emerge"

	L.son = "Son of Flame" -- NPC ID 12143
end

--------------------------------------------------------------------------------
-- Initialization
--

local sonOfFlameMarker = mod:AddMarkerOption(true, "npc", 8, "son", 8, 7, 6, 5, 4, 3, 2, 1) -- Son of Flame
function mod:GetOptions()
	return {
		"warmup",
		"submerge",
		"emerge",
		"adds",
		sonOfFlameMarker,
		{"health", "INFOBOX"},
		20566, -- Wrath of Ragnaros
	},nil,{
		[20566] = CL.knockback, -- Wrath of Ragnaros (Knockback)
	}
end

function mod:OnRegister()
	-- Delayed for custom locale
	sonOfFlameMarker = mod:AddMarkerOption(true, "npc", 8, "son", 8, 7, 6, 5, 4, 3, 2, 1) -- Son of Flame
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 11502 or mobId == 228438 or mobId == 12143 then -- Ragnaros, Ragnaros (Season of Discovery), Son of Flame
		return true
	else -- Majordomo Executus
		return not UnitCanAttack(unit, "player")
	end
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterMessage("BigWigs_BossComm")

	self:Log("SPELL_CAST_SUCCESS", "WrathOfRagnaros", 20566)
	self:Log("SPELL_CAST_START", "SummonRagnarosStart", 19774)
	self:Log("SPELL_CAST_SUCCESS", "SummonRagnaros", 19774)
	self:Log("SPELL_CAST_SUCCESS", "ElementalFire", 19773)

	self:Death("SonDeaths", 12143)
end

function mod:OnEngage()
	sonsDead = 0
	timer = nil
	sonsTracker = {}
	sonsMarker = 8
	lineCount = 3
	self:SetStage(1)
	self:CDBar(20566, 26, CL.knockback) -- Wrath of Ragnaros
	if self:GetSeason() == 2 then
		self:RegisterEvent("UNIT_HEALTH")
	else
		self:Bar("submerge", 180, L.submerge_bar, L.submerge_icon)
		self:Message("submerge", "yellow", CL.custom_min:format(L.submerge, 3), L.submerge_icon)
		self:DelayedMessage("submerge", 60, "yellow", CL.custom_min:format(L.submerge, 2))
		self:DelayedMessage("submerge", 120, "yellow", CL.custom_min:format(L.submerge, 1))
		self:DelayedMessage("submerge", 150, "yellow", CL.custom_sec:format(L.submerge, 30))
		self:DelayedMessage("submerge", 170, "orange", CL.custom_sec:format(L.submerge, 10), false, "alarm")
		self:DelayedMessage("submerge", 175, "orange", CL.custom_sec:format(L.submerge, 5), false, "alarm")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.submerge_trigger, nil, true) then
		self:Submerge()
	end
end

function mod:WrathOfRagnaros(args)
	self:Message(args.spellId, "red", CL.knockback)
	self:CDBar(args.spellId, 27, CL.knockback)
	self:PlaySound(args.spellId, "info")
end

function mod:SummonRagnarosStart()
	self:Sync("RagWarmup") -- Speedrunners like to have someone start it as soon as the Executus encounter ends
end

do
	local prev = 0
	function mod:BigWigs_BossComm(_, msg)
		local t = GetTime()
		if msg == "RagWarmup" and t - prev > 20 and not self:IsEngaged() then
			prev = t
			self:Bar("warmup", warmupTimer, CL.active, L.warmup_icon)
		end
	end

	function mod:SummonRagnaros()
		prev = GetTime()+100 -- No more sync allowed
		self:Bar("warmup", {warmupTimer-10, warmupTimer}, CL.active, L.warmup_icon)
	end
end

function mod:ElementalFire()
	-- it takes exactly 10 seconds for combat to start after Majodromo dies, while
	-- the time between starting the RP/summon and killing Majordomo varies
	self:Bar("warmup", {10, warmupTimer}, CL.active, L.warmup_icon)
end

function mod:Emerge()
	sonsDead = 10 -- Block this firing again if sons are killed after he emerges
	timer = nil
	self:SetStage(1)
	self:CloseInfo("health")
	self:CDBar(20566, 27, CL.knockback)
	if self:GetSeason() == 2 then
		self:Message("emerge", "yellow", L.emerge_bar, L.emerge_icon)
	else
		self:Message("emerge", "yellow", L.emerge_message, L.emerge_icon)
		self:Bar("submerge", 180, L.submerge_bar, L.submerge_icon)
		self:DelayedMessage("submerge", 60, "yellow", CL.custom_min:format(L.submerge, 2))
		self:DelayedMessage("submerge", 120, "yellow", CL.custom_min:format(L.submerge, 1))
		self:DelayedMessage("submerge", 150, "yellow", CL.custom_sec:format(L.submerge, 30))
		self:DelayedMessage("submerge", 170, "orange", CL.custom_sec:format(L.submerge, 10), false, "alarm")
		self:DelayedMessage("submerge", 175, "orange", CL.custom_sec:format(L.submerge, 5), false, "alarm")
	end
	self:RemoveLog("SWING_DAMAGE", "*")
	self:RemoveLog("RANGE_DAMAGE", "*")
	self:RemoveLog("SPELL_DAMAGE", "*")
	self:RemoveLog("SPELL_PERIODIC_DAMAGE", "*")
	self:PlaySound("emerge", "long")
end

function mod:Submerge()
	sonsDead = 0 -- reset counter
	sonsTracker = {}
	sonsMarker = 8
	lineCount = 3
	self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
	self:SetInfo("health", 1, L.son)
	-- No SUMMON events unfortunately, using CLEU damage events so that everyone assigns markers in the same (combat log) order
	self:Log("SWING_DAMAGE", "Damage", "*")
	self:Log("RANGE_DAMAGE", "Damage", "*")
	self:Log("SPELL_DAMAGE", "Damage", "*")
	self:Log("SPELL_PERIODIC_DAMAGE", "Damage", "*")
	self:SetStage(2)
	timer = self:ScheduleTimer("Emerge", 90)
	self:StopBar(CL.knockback)
	if self:GetSeason() == 2 then
		self:Message("submerge", "yellow", CL.percent:format(50, L.submerge_bar), L.submerge_icon)
	else
		self:Message("submerge", "yellow", L.submerge_message, L.submerge_icon)
	end
	self:Bar("emerge", 90, L.emerge_bar, L.emerge_icon)
	self:DelayedMessage("emerge", 30, "yellow", CL.custom_sec:format(L.emerge, 60))
	self:DelayedMessage("emerge", 60, "yellow", CL.custom_sec:format(L.emerge, 30))
	self:DelayedMessage("emerge", 80, "orange", CL.custom_sec:format(L.emerge, 10), false, "alarm")
	self:DelayedMessage("emerge", 85, "orange", CL.custom_sec:format(L.emerge, 5), false, "alarm")
	self:SimpleTimer(UpdateInfoBoxList, 1)
	self:PlaySound("submerge", "long")
end

function mod:SonDeaths(args)
	sonsDead = sonsDead + 1
	if sonsDead < 9 then
		self:Message("adds", "green", CL.add_killed:format(sonsDead, 8), "spell_fire_elemental_totem")
		local tbl = sonsTracker[args.destGUID]
		if tbl then
			sonsTracker[args.destGUID] = nil
			local line = tbl[1]
			local marker = tbl[2]
			local icon = self:GetIconTexture(marker)
			self:SetInfo("health", line, ("%s %s"):format(icon, CL.dead))
		end
	end
	if sonsDead == 8 then
		self:CancelTimer(timer)
		self:StopBar(L.emerge_bar)
		self:CancelDelayedMessage(CL.custom_sec:format(L.emerge, 60))
		self:CancelDelayedMessage(CL.custom_sec:format(L.emerge, 30))
		self:CancelDelayedMessage(CL.custom_sec:format(L.emerge, 10))
		self:CancelDelayedMessage(CL.custom_sec:format(L.emerge, 5))
		self:Emerge()
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 228438 then -- Ragnaros
		local hp = self:GetHealth(unit)
		if hp < 56 then
			self:UnregisterEvent(event)
			if hp > 50 then
				self:Message("submerge", "cyan", CL.soon:format(L.submerge_bar), false)
			end
		end
	end
end

function mod:Damage(args)
	if not sonsTracker[args.destGUID] and self:MobId(args.destGUID) == 12143 then -- Son of Flame
		sonsTracker[args.destGUID] = {lineCount, sonsMarker}
		self:SetInfo("health", lineCount, ("%s 99%%"):format(self:GetIconTexture(sonsMarker)))
		lineCount = lineCount + 1
		sonsMarker = sonsMarker - 1
		if sonsMarker == 0 then
			self:RemoveLog("SWING_DAMAGE", "*")
			self:RemoveLog("RANGE_DAMAGE", "*")
			self:RemoveLog("SPELL_DAMAGE", "*")
			self:RemoveLog("SPELL_PERIODIC_DAMAGE", "*")
		end
	end
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() or mod:GetStage() == 1 then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.5)

	for guid, tbl in next, sonsTracker do
		local unitToken = tbl[3]
		if not unitToken or mod:UnitGUID(unitToken) ~= guid then
			unitToken = mod:GetUnitIdByGUID(guid)
			tbl[3] = unitToken
		end
		if unitToken then
			local line = tbl[1]
			local marker = tbl[2]
			local currentHealthPercent = math.floor(mod:GetHealth(unitToken))
			local icon = mod:GetIconTexture(marker)
			mod:SetInfo("health", line, ("%s %d%%"):format(icon, currentHealthPercent))
			mod:CustomIcon(sonOfFlameMarker, unitToken, marker)
		end
	end
end
