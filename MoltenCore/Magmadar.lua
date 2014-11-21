
--------------------------------------------------------------------------------
-- Module declaration
--

local mod = BigWigs:NewBoss("Magmadar", 696)
if not mod then return end
mod:RegisterEnableMob(11982)
mod.toggleOptions = {19408, 19451, "bosskill"}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.bossName = "Magmadar"
end
L = mod:GetLocale()
mod.displayName = L.bossName

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Fear", 19408)
	self:Log("SPELL_CAST_SUCCESS", "Frenzy", 19451)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 11982)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Fear(args)
	self:Bar(args.spellId, 30)
	self:Message(args.spellId, "Positive")
end

function mod:Frenzy(args)
	self:Bar(args.spellId, 8)
	self:Message(args.spellId, "Attention", "Info")
end

