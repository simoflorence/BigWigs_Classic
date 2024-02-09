--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Mechanical Menagerie Discovery", 90, -2935)
if not mod then return end
mod:RegisterEnableMob(218242, 218243, 218244, 218245) -- STX-04/BD (Dragon), STX-13/LL (Sheep), STX-25/NB (Squirrel), STX-37/CN (Chicken)
mod:SetEncounterID(2935)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Mechanical Menagerie"
	L.attack_buff = "+50% attack speed"
	L.dont_attack = "Don't attack the sheep"
	L.sheep_safe = "Sheep is safe to attack"
end

--------------------------------------------------------------------------------
-- Initialization
--

local explosiveEggMarker = mod:AddMarkerOption(true, "npc", 8, 436692, 8) -- Explosive Egg
function mod:GetOptions()
	return {
		436692, -- Explosive Egg
		explosiveEggMarker,
		436570, -- Cluck!
		436833, -- Widget Volley
		436836, -- Widget Fortress
		436816, -- Sprocketfire Breath
		436741, -- Overheat
		436825, -- Frayed Wiring
		440073, -- Self Repair
	},nil,{
		[436570] = L.attack_buff, -- Cluck! (+50% attack speed)
		[436836] = CL.shield, -- Widget Fortress (Shield)
		[436816] = CL.breath, -- Sprocketfire Breath (Breath)
		[436741] = CL.weakened, -- Overheat (Weakened)
		[436825] = L.dont_attack, -- Frayed Wiring (Don't attack the sheep)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_SUMMON", "ExplosiveEggSummon", 436692)
	self:Log("SPELL_CAST_SUCCESS", "Cluck", 436570)
	self:Log("SPELL_CAST_START", "WidgetVolley", 436833)
	self:Log("SPELL_INTERRUPT", "WidgetVolleyInterrupted", "*")
	self:Log("SPELL_CAST_START", "WidgetFortress", 436836)
	self:Log("SPELL_AURA_APPLIED", "WidgetFortressApplied", 436837)
	self:Log("SPELL_CAST_START", "SprocketfireBreath", 436816)
	self:Log("SPELL_AURA_APPLIED", "SprocketfireBreathApplied", 440014)
	self:Log("SPELL_AURA_APPLIED", "SprocketfireBreathAppliedDose", 440014)
	self:Log("SPELL_AURA_APPLIED", "OverheatApplied", 436741)
	self:Log("SPELL_AURA_APPLIED", "FrayedWiringApplied", 436825)
	self:Log("SPELL_AURA_REMOVED", "FrayedWiringRemoved", 436825)
	self:Log("SPELL_CAST_START", "SelfRepair", 440073)
end

function mod:OnEngage()
	self:CDBar(436816, 11.6, CL.breath) -- Sprocketfire Breath
	self:CDBar(436692, 12.2) -- Explosive Egg
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local eggGUID = nil

	function mod:ExplosiveEggSummon(args)
		self:Message(args.spellId, "yellow", CL.spawned:format(args.spellName))
		self:CDBar(args.spellId, 21)
		self:PlaySound(args.spellId, "info")
		-- register events to auto-mark egg
		if self:GetOption(explosiveEggMarker) then
			eggGUID = args.destGUID
			self:RegisterTargetEvents("MarkExplosiveEgg")
		end
	end

	function mod:MarkExplosiveEgg(_, unit, guid)
		if eggGUID == guid then
			eggGUID = nil
			self:CustomIcon(explosiveEggMarker, unit, 8)
			self:UnregisterTargetEvents()
		end
	end
end

function mod:Cluck(args)
	self:Message(args.spellId, "orange", CL.buff_boss:format(L.attack_buff))
	self:Bar(args.spellId, 15, L.attack_buff)
end

function mod:WidgetVolley(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	if self:Interrupter() then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:WidgetVolleyInterrupted(args)
	if args.extraSpellName == self:SpellName(436833) then
		self:Message(436833, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:WidgetFortress(args)
	self:Message(args.spellId, "red", CL.incoming:format(CL.shield))
	self:CDBar(args.spellId, 50.1)
	self:PlaySound(args.spellId, "long")
end

function mod:WidgetFortressApplied(args)
	self:Message(args.spellId, "red", CL.on:format(CL.shield, args.destName))
	self:PlaySound(args.spellId, "info")
end

function mod:SprocketfireBreath(args)
	self:Message(args.spellId, "yellow", CL.breath)
	self:CDBar(args.spellId, 20.5, CL.breath)
	self:PlaySound(args.spellId, "alarm")
end

function mod:SprocketfireBreathApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, CL.breath)
	end
end

function mod:SprocketfireBreathAppliedDose(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", CL.breath, args.amount, 1)
	end
end

do
	local prev = 0
	function mod:OverheatApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			self:Message(args.spellId, "red", CL.duration:format(CL.weakened, 15))
			self:Bar(args.spellId, 15, CL.weakened)
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:FrayedWiringApplied(args)
	self:Message(args.spellId, "red", CL.other:format(args.spellName, L.dont_attack))
	self:Bar(args.spellId, 15, L.dont_attack)
end

function mod:FrayedWiringRemoved(args)
	self:StopBar(L.dont_attack)
	self:Message(args.spellId, "green", L.sheep_safe)
end

function mod:SelfRepair(args)
	self:TargetMessage(args.spellId, "cyan", args.sourceName)
	self:TargetBar(args.spellId, 20, args.sourceName)
	self:PlaySound(args.spellId, "long")
end
