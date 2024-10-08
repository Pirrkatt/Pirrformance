local addonName, addon = ...

Pirrformance = LibStub("AceAddon-3.0"):NewAddon("Pirrformance", "AceConsole-3.0", "AceEvent-3.0")

local DisabledFeatures = {
    AutoMarking = true,
    RangeIndicator = true,
    SpellGlow = true,
}

local defaults = {
	char = {
		autoMark = {
			autoMarkList = {
				["entry1"] = {name = "", mark = 0},
				["entry2"] = {name = "", mark = 0},
				["entry3"] = {name = "", mark = 0},
				["entry4"] = {name = "", mark = 0}},
			autoMarkEnabled = false,
			markSelfEnabled = false,
			markSelfMarker = 0,
		},
		spellGlow = {
			spellGlowEnabled = false,
			spellList = {
				[1] = false,
			}
		}
	},
	global = {
		sounds = {
			customSoundsEnabled = false,
			soundList = {
				[1] = {enabled = false, volume = 1},
				[2] = {enabled = false, volume = 1}, -- All of Jens Death sounds
			}
		},
		tools = {
			autoDelete = false,
			rangeIndicator = false,
		}
	},
}

local STORAGE_GLOBAL = CopyTable(defaults.global)
local STORAGE_CHAR = CopyTable(defaults.char)

local OPTIONS_MARK_LIST

local CONFIG = {
	colorLight = "ffDA70D6",
	colorDark = "ff9C59D4",
	colorDetail =  "ff8A6D92",
}

local MARKERS_MAP = {
	[0] = "", -- None
	[1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t", -- Star
	[2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t", -- Circle
	[3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t", -- Diamond
	[4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t", -- Triangle
	[5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t", -- Moon
	[6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t", -- Square
	[7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t", -- Cross (X)
	[8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t", -- Skull
}

local SOUND_FILES = {
	[1] = {file = "BL-Hagge.ogg", channel = "SFX"},
	[2] = {file = "Death-Jens1.ogg", channel = "SFX"},
	[3] = {file = "Death-Jens2.ogg", channel = "SFX"},
	[4] = {file = "Death-Jens3.ogg", channel = "SFX"},
	[5] = {file = "Death-Jens4.ogg", channel = "SFX"},
}

local GLOW_FRAMES = {}
local SPELL_GLOWS_IDS = {
	[1] = 195182, -- Marrowrend
	[2] = 195292, -- Death's Caress
	[3] = 219809, -- Tombstone
	[4] = 194844, -- Bonestorm
	[5] = 343294, -- Soul Reaper
}

local PLAYER_CLASS

local itemRanges = {
	[5] = 16114, -- Foremans Blackjack (TBC)
	[10] = 8149, -- Voodoo Charm
	[15] = 33069, -- Sturdy Rope
	[20] = 10645, -- Gnomish Death Ray
	[25] = 13289,--Egan's Blaster
	[30] = 835, -- Large Rope Net
	[35] = 24269, -- Heavy Netherweave Net
	[40] = 28767, -- The Decapitator
	[45] = 32698,-- Wrangling Rope
	[60] = 32825, -- Soul Cannon
	[80] = 35278,-- Reinforced Net (WotLK)
	[100] = 41058, -- Hyldnir Harpoon (WotLK)
}

local options = {
	name = "|c" .. CONFIG.colorDark .. "Pirr|c" .. CONFIG.colorLight .. "formance|r",
	handler = Pirrformance,
	type = "group",
	args = {
		author = {
			type = "description",
			name = "|c" .. CONFIG.colorDetail .. "Author:|r " .. C_AddOns.GetAddOnMetadata(addonName, "Author"),
			fontSize = "medium",
			order = 1,
		},
		version = {
			type = "description",
			name = "|c" .. CONFIG.colorDetail .. "Version:|r " .. C_AddOns.GetAddOnMetadata(addonName, "Version"),
			fontSize = "medium",
			order = 2,
		},
		linebreaks = {
			type = "description",
			name = "\n\n\n",
			fontSize = "large",
			order = 3,
		},
		autoMark = {
			type = "group",
			name = "AutoMark",
			order = 4,
			args = {
				autoMarkPlayers = {
					name = "AutoMark Players",
					type = "group",
					inline = true,
					order = 1,
					args = {
						autoMarkToggle = {
							type = "toggle",
							name = "Enabled",
							desc = "Automatically mark pre-configured players.",
							get = "IsAutoMarkEnabled",
							set = "ToggleAutoMark",
							disabled = function() return DisabledFeatures.AutoMarking end,
							order = 1,
						},
						header = {
							type = "header",
							name = "Player List",
							order = 2,
						},
						spaces = {
							type = "description",
							name = " ",
							fontSize = "medium",
							width = 0.8,
							order = 3,
						},
						autoMarkSelf = {
							type = "toggle",
							name = "AutoMark Self",
							descStyle = "none",
							get = function() return STORAGE_CHAR.autoMark.markSelfEnabled end,
							set = function(_, newValue) STORAGE_CHAR.autoMark.markSelfEnabled = newValue end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
							width = 0.7,
							order = 4,
						},
						selfMark = {
							type = "select",
							name = "",
							values = MARKERS_MAP,
							width = 0.35,
							get = function() return STORAGE_CHAR.autoMark.markSelfMarker end,
							set = "AssignMarkerToList",
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
							order = 5,
						},
						player1 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry1"].name end,
							order = 6,
							width = 0.85,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						mark1 = {
							type = "select",
							name = "",
							order = 7,
							values = MARKERS_MAP,
							width = 0.35,
							set = "AssignMarkerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry1"].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player2 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry2"].name end,
							order = 8,
							width = 0.85,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						mark2 = {
							type = "select",
							name = "",
							order = 9,
							values = MARKERS_MAP,
							width = 0.35,
							set = "AssignMarkerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry2"].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player3 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry3"].name end,
							order = 10,
							width = 0.85,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						mark3 = {
							type = "select",
							name = "",
							order = 11,
							values = MARKERS_MAP,
							width = 0.35,
							set = "AssignMarkerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry3"].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player4 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry4"].name end,
							order = 12,
							width = 0.85,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						mark4 = {
							type = "select",
							name = "",
							order = 13,
							values = MARKERS_MAP,
							width = 0.35,
							set = "AssignMarkerToList",
							get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry4"].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
					},
				},
				addEntry = {
					type = "execute",
					name = "Add Entry",
					func = "AddEmptyEntry",
					confirm = false,
					order = 5,
					width = 0.6,
					disabled = function() return Pirrformance:GetDatabaseEntriesAmount() >= 18 end,
				},
				removeEntry = {
					type = "execute",
					name = "Remove Entry",
					func = "RemoveEntry",
					confirm = false,
					order = 6,
					width = 0.7,
					disabled = function() return Pirrformance:GetDatabaseEntriesAmount() <= 4 end,
				},
				spaces = {
					type = "description",
					name = " ",
					fontSize = "medium",
					width = 0.8,
					order = 7,
				},
				resetDefaults = {
					type = "execute",
					name = "Reset to Default",
					func = "ResetAutomarkDefaults",
					confirm = true,
					order = 8,
				},
			},
		},
		sounds = {
			type = "group",
			name = "Sounds",
			order = 5,
			args = {
				customSounds = {
					name = "Custom Sounds",
					type = "group",
					inline = true,
					order = 1,
					args = {
						autoMarkToggle = {
							type = "toggle",
							name = "Enabled",
							desc = "Enable Custom Sounds.",
							get = "IsCustomSoundsEnabled",
							set = "ToggleCustomSounds",
							order = 1,
						},
						header = {
							type = "header",
							name = "Sound List",
							order = 2,
						},
						sound1 = {
							type = "toggle",
							name = "BloodLust - Hagge",
							descStyle = "none",
							get = function() return STORAGE_GLOBAL.sounds.soundList[1].enabled end,
							set = function(_, newValue) STORAGE_GLOBAL.sounds.soundList[1].enabled = newValue end,
							disabled = function() return not Pirrformance:IsCustomSoundsEnabled() end,
							order = 3,
						},
						volumeSound1 = {
							type = "range",
							name = "Volume",
							min = 1,
							max = 5,
							step = 1,
							width = 0.8,
							get = function() return STORAGE_GLOBAL.sounds.soundList[1].volume end,
							set = function(_, newValue) STORAGE_GLOBAL.sounds.soundList[1].volume = newValue end,
							order = 4,
						},
						spaces1 = {
							type = "description",
							name = " ",
							fontSize = "medium",
							width = 0.15,
							order = 5,
						},
						testSound1 = {
							type = "execute",
							name = "Test",
							func = "TestSound",
							width = 0.4,
							order = 6,
						},
						sound2 = {
							type = "toggle",
							name = "Death - Jens",
							descStyle = "none",
							get = function() return STORAGE_GLOBAL.sounds.soundList[2].enabled end,
							set = function(_, newValue) STORAGE_GLOBAL.sounds.soundList[2].enabled = newValue end,
							disabled = function() return not Pirrformance:IsCustomSoundsEnabled() end,
							order = 7,
						},
						volumeSound2 = {
							type = "range",
							name = "Volume",
							min = 1,
							max = 5,
							step = 1,
							width = 0.8,
							get = function() return STORAGE_GLOBAL.sounds.soundList[2].volume end,
							set = function(_, newValue) STORAGE_GLOBAL.sounds.soundList[2].volume = newValue end,
							order = 8,
						},
						spaces2 = {
							type = "description",
							name = " ",
							fontSize = "medium",
							width = 0.15,
							order = 9,
						},
						-- testSound2 = {
						-- 	type = "execute",
						-- 	name = "Test",
						-- 	func = "TestSound",
						-- 	width = 0.4,
						-- 	order = 10,
						-- },
					},
				},
			},
		},
		spellGlowCategory = {
			type = "group",
			name = "Spell Glow",
			order = 6,
			args = {
				spellGlow = {
					name = "Spell Button Glow",
					type = "group",
					inline = true,
					order = 1,
					args = {
						spellGlowToggle = {
							type = "toggle",
							name = "Enabled",
							desc = "Enable Spell Glow.",
							get = "IsSpellGlowEnabled",
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellGlowEnabled = newValue end,
							disabled = function() return DisabledFeatures.SpellGlow end,
							order = 1,
						},
						header = {
							type = "header",
							name = "Spell List",
							order = 2,
						},
						spell1 = {
							type = "toggle",
							name = function() return Pirrformance:GetNameWithIconString("Marrowrend", "Ability_DeathKnight_Marrowrend", 22, true) end,
							desc = "Helps with upkeeping at least 6 Bone Shield charges.",
							get = function() return STORAGE_CHAR.spellGlow.spellList[1] end,
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellList[1] = newValue end,
							disabled = function() return not Pirrformance:IsSpellGlowEnabled() or PLAYER_CLASS ~= "DEATHKNIGHT" end,
							order = 3,
						},
						spell2 = {
							type = "toggle",
							name = function() return Pirrformance:GetNameWithIconString("Death's Caress", "Ability_DeathKnight_DeathsCaress", 22, true) end,
							desc = "Helps with upkeeping at least 6 Bone Shield charges.",
							get = function() return STORAGE_CHAR.spellGlow.spellList[2] end,
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellList[2] = newValue end,
							disabled = function() return not Pirrformance:IsSpellGlowEnabled() or PLAYER_CLASS ~= "DEATHKNIGHT" end,
							order = 4,
						},
						spell3 = {
							type = "toggle",
							name = function() return Pirrformance:GetNameWithIconString("Tombstone", "Ability_FiegnDead", 22, true) end,
							desc = "Triggers when Runic Power is 95 or below and at least 6 Bone Shield charges.",
							get = function() return STORAGE_CHAR.spellGlow.spellList[3] end,
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellList[3] = newValue end,
							disabled = function() return not Pirrformance:IsSpellGlowEnabled() or PLAYER_CLASS ~= "DEATHKNIGHT" end,
							order = 5,
						},
						spell4 = {
							type = "toggle",
							name = function() return Pirrformance:GetNameWithIconString("Bonestorm", "Achievement_Boss_LordMarrowgar", 22, true) end,
							desc = "Triggers when at least 6 Bone Shield charges and more than 2 enemies in range.",
							get = function() return STORAGE_CHAR.spellGlow.spellList[4] end,
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellList[4] = newValue end,
							disabled = function() return not Pirrformance:IsSpellGlowEnabled() or PLAYER_CLASS ~= "DEATHKNIGHT" end,
							order = 6,
						},
						spell5 = {
							type = "toggle",
							name = function() return Pirrformance:GetNameWithIconString("Soul Reaper", "Ability_DeathKnight_SoulReaper", 22, true) end,
							desc = "Triggers when at least 1 rune and target has less than 35% health.",
							get = function() return STORAGE_CHAR.spellGlow.spellList[5] end,
							set = function(_, newValue) STORAGE_CHAR.spellGlow.spellList[5] = newValue end,
							disabled = function() return not Pirrformance:IsSpellGlowEnabled() or PLAYER_CLASS ~= "DEATHKNIGHT" end,
							order = 7,
						},
					},
				},
			},
		},
		toolsCategory = {
			type = "group",
			name = "Tools",
			order = 7,
			args = {
				tools = {
					name = "Tools",
					type = "group",
					inline = true,
					order = 1,
					args = {
						autoDelete = {
							type = "toggle",
							name = "Auto Delete",
							desc = "Automatically puts 'DELETE' into text field when attempting to delete an item.",
							get = function() return STORAGE_GLOBAL.tools.autoDelete end,
							set = function(_, newValue) STORAGE_GLOBAL.tools.autoDelete = newValue end,
							order = 1,
						},
						rangeIndicator = {
							type = "toggle",
							name = "Range Indicator",
							desc = "Shows approximate range to target in yards.",
							get = function() return STORAGE_GLOBAL.tools.rangeIndicator end,
							set = "ToggleRangeIndicator",
							disabled = function() return DisabledFeatures.RangeIndicator end,
							order = 2,
						},
					},
				},
			},
		},
	},
}

function Pirrformance:OnInitialize() -- Called when the addon is first loaded (Some addons & systems may not be fully available yet)
	self.db = LibStub("AceDB-3.0"):New("PirrformanceDB", defaults, true)

	STORAGE_GLOBAL = self.db.global
	STORAGE_CHAR = self.db.char

	OPTIONS_MARK_LIST = options.args.autoMark.args.autoMarkPlayers.args

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Pirrformance", options)
	self.optionsFrame, self.settingsCategoryId = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Pirrformance", "|c" .. CONFIG.colorDark .. "Pirr|c" .. CONFIG.colorLight .. "formance|r")

	-- Slash Commands
	self:RegisterChatCommand("pf", "SlashCommand")
	self:RegisterChatCommand("pirr", "SlashCommand")
	self:RegisterChatCommand("pirrformance", "SlashCommand")

	_, PLAYER_CLASS = UnitClass("player")

	self:LoadExtraEntries()
	self:HookAutoDelete()
	self:SetupRangeFrame()
end

function Pirrformance:OnEnable() -- Called when the addon is enabled (All addons loaded & player entering world)
	-- AutoMark
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")

	-- Sounds/Spell Glow
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	-- Spell Glow
	self:SetupGlowButtons()

	self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
	if PLAYER_CLASS == "DEATHKNIGHT" then -- Only works for DKs at the moment
		self:RegisterEvent("RUNE_POWER_UPDATE")
		self:RegisterEvent("UNIT_POWER_UPDATE")
	end
	self:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end

function Pirrformance:SlashCommand(msg)
	Settings.OpenToCategory(self.settingsCategoryId)
end

function Pirrformance:GetNameWithIconString(name, iconPath, size, cropped)
	local str = ""
	if iconPath then
		str = str .. "|TInterface/Icons/" .. iconPath .. ":"
		if size then
			str = str .. size .. ":" .. size
			if cropped then
				str = str .. ":0:0:64:64:8:56:8:56"
			end
		else
			str = str .. "0"
		end
	end

	str = str .. "|t " .. name
	return str
end

--------------------- AUTOMARK ---------------------

function Pirrformance:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	self:AutoMarkPlayers()
end

function Pirrformance:GROUP_JOINED(event, category, partyGUID)
	self:AutoMarkPlayers()
end

function Pirrformance:GROUP_ROSTER_UPDATE(event)
	self:AutoMarkPlayers()
end

function Pirrformance:IsAutoMarkEnabled(info)
	return STORAGE_CHAR.autoMark.autoMarkEnabled
end

function Pirrformance:ToggleAutoMark(info, value)
	STORAGE_CHAR.autoMark.autoMarkEnabled = value
end

function Pirrformance:AutoMarkPlayers()
	if not self:IsAutoMarkEnabled() then
		return
	end

	if not IsInGroup(1) then
		return
	end

	-- Mark Self
	if STORAGE_CHAR.autoMark.markSelfEnabled then
		if STORAGE_CHAR.autoMark.markSelfMarker then
			if CanBeRaidTarget("player") and not (GetRaidTargetIndex("player") == STORAGE_CHAR.autoMark.markSelfMarker) then
				SetRaidTarget("player", STORAGE_CHAR.autoMark.markSelfMarker)
			end
		end
	end

	-- Mark PlayerList
	for _, playerName in pairs(GetHomePartyInfo()) do
		for i = 1, self:GetDatabaseEntriesAmount() do
			if STORAGE_CHAR.autoMark.autoMarkList["entry" .. i].name:len() > 0 and STORAGE_CHAR.autoMark.autoMarkList["entry" .. i].name == playerName then
				if not CanBeRaidTarget(playerName) then
					return
				end
				if GetRaidTargetIndex(playerName) == STORAGE_CHAR.autoMark.autoMarkList["entry" .. i].mark then
					return
				end

				SetRaidTarget(playerName, STORAGE_CHAR.autoMark.autoMarkList["entry" .. i].mark)
			end
		end
	end
end

function Pirrformance:AddPlayerToList(info, newValue)
	local index = string.gsub(info[#info], "player", "")

	if newValue:len() > 0 then
		for key, entry in pairs(STORAGE_CHAR.autoMark.autoMarkList) do
			if type(key) == "string" and key:find("entry") then
				if entry.name:lower() == newValue:lower() then
					self:Print("That player is already added.")
					return
				end
			end
		end
	end

	STORAGE_CHAR.autoMark.autoMarkList["entry" .. index].name = newValue
end

function Pirrformance:AssignMarkerToList(info, newValue)
	if newValue > 0 then
		for key, entry in pairs(STORAGE_CHAR.autoMark.autoMarkList) do
			if type(key) == "string" and key:find("entry") then
				if entry.mark == newValue then
					self:Print("That marker is already assigned.")
					return
				end
			end
		end

		if STORAGE_CHAR.autoMark.markSelfMarker == newValue then
			self:Print("That marker is already assigned.")
			return
		end
	end

	local selfMark = info[#info] == "selfMark"
	if selfMark then
		STORAGE_CHAR.autoMark.markSelfMarker = newValue
		return
	end

	local index = string.gsub(info[#info], "mark", "")
	STORAGE_CHAR.autoMark.autoMarkList["entry" .. index].mark = newValue
end

function Pirrformance:AddEntry(entryNum, lastOrder)
	OPTIONS_MARK_LIST["player" .. entryNum] = {
		type = "input",
		name = "",
		set = "AddPlayerToList",
		get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry" .. entryNum].name end,
		order = lastOrder + 1,
		width = 0.85,
		disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
	}
	OPTIONS_MARK_LIST["mark" .. entryNum] = {
		type = "select",
		name = "",
		order = lastOrder + 2,
		values = MARKERS_MAP,
		width = 0.35,
		set = "AssignMarkerToList",
		get = function() return STORAGE_CHAR.autoMark.autoMarkList["entry" .. entryNum].mark end,
		disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
	}
end

function Pirrformance:AddEmptyEntry()
	local dbAmount = self:GetDatabaseEntriesAmount()
	local entryNum = dbAmount + 1
	local lastOrder = OPTIONS_MARK_LIST["mark" .. dbAmount].order

	STORAGE_CHAR.autoMark.autoMarkList["entry" .. entryNum] = {name = "", mark = 0}
	Pirrformance:AddEntry(entryNum, lastOrder)
end

function Pirrformance:RemoveEntry()
	local dbAmount = self:GetDatabaseEntriesAmount()

	STORAGE_CHAR.autoMark.autoMarkList["entry" .. dbAmount] = nil
	OPTIONS_MARK_LIST["player" .. dbAmount] = nil
	OPTIONS_MARK_LIST["mark" .. dbAmount] = nil
end

function Pirrformance:GetOptionsEntriesAmount()
	local amountOfEntries = 0
	for k,_ in pairs(OPTIONS_MARK_LIST) do
		if k:find("player") then
			amountOfEntries = amountOfEntries + 1
		end
	end
	return amountOfEntries
end

function Pirrformance:GetDatabaseEntriesAmount()
	local amountOfEntries = 0
	for _ in pairs(STORAGE_CHAR.autoMark.autoMarkList) do
		amountOfEntries = amountOfEntries + 1
	end
	return amountOfEntries
end

function Pirrformance:LoadExtraEntries()
	local totalEntries = self:GetDatabaseEntriesAmount()
	if totalEntries <= 4 then
		return
	end

	for num = 5, totalEntries do
		local lastOrder = OPTIONS_MARK_LIST["mark" .. self:GetOptionsEntriesAmount()].order
		Pirrformance:AddEntry(num, lastOrder)
	end
end

function Pirrformance:ResetAutomarkDefaults()
	while self:GetOptionsEntriesAmount() > 4 do
		self:RemoveEntry()
	end

	STORAGE_CHAR.autoMark = CopyTable(defaults.char.autoMark)
	self:Print("AutoMark settings have been reset!")
end

--------------------- SOUNDS ---------------------

local function PlaySound(soundFile, channel, volume)
	local soundDir = "Interface\\AddOns\\Pirrformance\\Sounds\\"
	local sound = soundDir .. soundFile

	local soundChannel = channel or "Master"
	local soundVolume = volume or 1

	for _ = 1, soundVolume * 2 do
		PlaySoundFile(sound, soundChannel)
	end
end

function Pirrformance:HaggeBL()
	local haggeChars = {["Haggerid"] = true, ["Hâg"] = true}
	local spellId_Heroism, spellId_PrimalRage = 32182, 264667
	local haggeBL_index = 1

	if not self:IsCustomSoundsEnabled() then
		return
	end

	if not STORAGE_GLOBAL.sounds.soundList[haggeBL_index] or not STORAGE_GLOBAL.sounds.soundList[haggeBL_index].enabled then
		return
	end

	if not SOUND_FILES[haggeBL_index] then
		self:Print("Error: Sound File does not exist.")
		return
	end

	local _, subevent, _, _, sourceName, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()

	if subevent == "SPELL_AURA_APPLIED" and (spellId == spellId_Heroism or spellId == spellId_PrimalRage) then
		if haggeChars[sourceName] then
			local soundFile = SOUND_FILES[haggeBL_index].file
			local soundChannel = SOUND_FILES[haggeBL_index].channel
			local soundVolume = STORAGE_GLOBAL.sounds.soundList[haggeBL_index].volume

			PlaySound(soundFile, soundChannel, soundVolume)
		end
	end
end

function Pirrformance:JensDeath()
	local jensChars = {["Steroid"] = true, ["Jagclearar"] = true, ["Jensuz"] = true, ["Snoopdog"] = true}

	local _, subevent, _, _, _, _, _, playerGUID, playerName = CombatLogGetCurrentEventInfo()

	if not self:IsCustomSoundsEnabled() then
		return
	end

	if not STORAGE_GLOBAL.sounds.soundList[2] or not STORAGE_GLOBAL.sounds.soundList[2].enabled then -- Index 2 is a collection of all sound files (only enabled check)
		return
	end


	if subevent == "UNIT_DIED" then
		-- local inGroup = IsGUIDInGroup(playerGUID) -- Only apply if player is in the same party
		if jensChars[playerName] then
			local startIndex, endIndex = 2, 5 -- Indexes of sound files for this event in SOUND_FILES table
			local randomFile = math.random(startIndex, endIndex)

			if not SOUND_FILES[randomFile] then
				self:Print("Error: Sound File does not exist.")
				return
			end

			local soundFile = SOUND_FILES[randomFile].file
			local soundChannel = SOUND_FILES[randomFile].channel
			local soundVolume = STORAGE_GLOBAL.sounds.soundList[2].volume

			PlaySound(soundFile, soundChannel, soundVolume)
		end
	end
end

function Pirrformance:COMBAT_LOG_EVENT_UNFILTERED()
	self:HaggeBL()
	self:UpdateSpellGlow()
	self:JensDeath()
end

function Pirrformance:IsCustomSoundsEnabled(info)
	return STORAGE_GLOBAL.sounds.customSoundsEnabled
end

function Pirrformance:ToggleCustomSounds(info, value)
	STORAGE_GLOBAL.sounds.customSoundsEnabled = value
end

function Pirrformance:TestSound(info)
	local button = info[#info]
	local num = tonumber(button:match("testSound(%d+)"))

	if not num or not SOUND_FILES[num] then
		return
	end

	local soundFile = SOUND_FILES[num].file
	local soundChannel = SOUND_FILES[num].channel
	local soundVolume = STORAGE_GLOBAL.sounds.soundList[num].volume

	PlaySound(soundFile, soundChannel, soundVolume)
end

--------------------- SPELL GLOW ---------------------

local defaultBars = {"Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft"}

local function scanDefaultBars()
	local buttonMap = {}

	for _, barName in pairs(defaultBars) do
		for i = 1, 12 do
			local button = _G[barName .. "Button" .. i]
			if button then
				local slot = button.action or 0
				if slot and HasAction(slot) then
					local actionType, spellId = GetActionInfo(slot)
					if actionType == "spell" then
						if not buttonMap[spellId] then
							buttonMap[spellId] = {}
						end
						table.insert(buttonMap[spellId], button)
					end
				end
			end
		end
	end
	return buttonMap
end

local function scanElvUIBars()
	local buttonMap = {}

	for bar = 1, 15 do
		for slotNum = 1, 12 do
			local button = _G["ElvUI_Bar" .. bar .. "Button" .. slotNum]
			if button then
				local slot = button._state_action;
				if slot and HasAction(slot) then
					local actionType, spellId = GetActionInfo(slot)
					if actionType == "spell" then
						if not buttonMap[spellId] then
							buttonMap[spellId] = {}
						end
						table.insert(buttonMap[spellId], button)
					end
				end
			end
		end
	end
	return buttonMap
end

function Pirrformance:SetupGlowButtons()
	GLOW_FRAMES = {}

	local buttonMap = {}
	if ElvUI then
		buttonMap = scanElvUIBars()
	else
		buttonMap = scanDefaultBars()
	end

	for _, spellId in pairs(SPELL_GLOWS_IDS) do
		if IsSpellKnown(spellId) then
			if not GLOW_FRAMES[spellId] then
				GLOW_FRAMES[spellId] = {}
			end

			local glowFrame = CreateFrame("Frame")

			local buttons = buttonMap[spellId] or {}

			for _, button in pairs(buttons) do
				glowFrame.SpellActivationAlert = CreateFrame("Frame", nil, button, "ActionBarButtonSpellActivationAlert");
				local frameWidth, frameHeight = button:GetSize();
				glowFrame.SpellActivationAlert:SetSize(frameWidth + 10, frameHeight + 10);
				glowFrame.SpellActivationAlert:SetPoint("CENTER", button, "CENTER", 0, 0);
				glowFrame.SpellActivationAlert:Hide();
				table.insert(GLOW_FRAMES[spellId], glowFrame)
			end
		end
	end
end

function Pirrformance:ACTIVE_PLAYER_SPECIALIZATION_CHANGED(event)
	self:StopAllGlowButtons()
	self:SetupGlowButtons()
end

function Pirrformance:RUNE_POWER_UPDATE(event, runeIndex, added)
	self:UpdateSpellGlow()
end

function Pirrformance:UNIT_POWER_UPDATE(event, unitTarget, powerType)
	if unitTarget == "player" then
		self:UpdateSpellGlow()
	end
end

function Pirrformance:ACTION_RANGE_CHECK_UPDATE(event, slot, isInRange, checksRange)
	self:UpdateSpellGlow()
end

function Pirrformance:SPELL_UPDATE_COOLDOWN(event)
	self:UpdateSpellGlow()
end

function Pirrformance:IsSpellGlowEnabled(info)
	return STORAGE_CHAR.spellGlow.spellGlowEnabled
end

local function GetNearbyCreatures()
    local nearbyCount = 0
    local nameplates = C_NamePlate.GetNamePlates()
	-- local sapId = 6770

    for _, nameplate in ipairs(nameplates) do
        local unit = nameplate.UnitFrame.unit
		if UnitCanAttack("player", unit) then
			-- local inRange = C_Spell.IsSpellInRange(sapId, unit) -- Might need to use this instead if CheckInteractDistance does not work in combat
			if CheckInteractDistance(unit, 3) then -- 3 means within 10 yards
				nearbyCount = nearbyCount + 1
			end
		end
    end

    return nearbyCount
end

local function CheckSpellGlow(dbIndex, spellId, runesRequired, missingBoneShieldCharges, minBoneShieldCharges, maxRunicPower, healthThreshold, minNearbyCreatures, inRangeCheck)
	if PLAYER_CLASS ~= "DEATHKNIGHT" or not STORAGE_CHAR.spellGlow.spellList[dbIndex] then
		return false
	end

	-- Check Runes
	local totalRunes = 0
	for i = 1, 6 do
        local runeCount = GetRuneCount(i)
        if runeCount then -- Fixes weird bug when loading between zones
            totalRunes = totalRunes + runeCount
        end
	end
	if totalRunes < runesRequired then
		return false
	end

	-- Check Bone Shield Charges
	local boneShield_AuraId = 195181
	local chargeInfo = C_UnitAuras.GetPlayerAuraBySpellID(boneShield_AuraId)
	local boneShieldCharges = (chargeInfo and chargeInfo.applications) or 0
	if missingBoneShieldCharges and boneShieldCharges > missingBoneShieldCharges then
		return false
	end
	if minBoneShieldCharges and boneShieldCharges < minBoneShieldCharges then
		return false
	end

	-- Check Runic Power
	local runicPower = UnitPower("player", Enum.PowerType.RunicPower)
	if maxRunicPower and runicPower > maxRunicPower then
		return false
	end

	-- Check Health Threshold
	if healthThreshold then
		local health = UnitHealth("target")
		local maxHealth = UnitHealthMax("target")
		local percentHealth = (health / maxHealth) * 100
		if percentHealth >= healthThreshold then
			return false
		end
	end

	-- Check Nearby Creatures
	if minNearbyCreatures then
		local nearbyCreatures = GetNearbyCreatures()
		if nearbyCreatures < minNearbyCreatures then
			return false
		end
	end

	-- Check if in Range
	if inRangeCheck and not C_Spell.IsSpellInRange(spellId, "target") then
		return false
	end

	-- Check Cooldown
	local spellCooldownInfo = C_Spell.GetSpellCooldown(spellId)
	local cooldown = spellCooldownInfo.duration
	if cooldown > 5 then
		return false
	end

	return true
end

local function startGlow(frame)
	if frame and not frame.isRunning then
        frame.SpellActivationAlert:Show()
        frame.SpellActivationAlert.ProcStartAnim:Play()
        frame.isRunning = true
	end
end

local function stopGlow(frame)
	if frame and frame.isRunning then
    	frame.isRunning = false
        frame.SpellActivationAlert.ProcStartAnim:Stop()
        frame.SpellActivationAlert:Hide()
	end
end

function Pirrformance:StopAllGlowButtons()
	for _, spellId in pairs(SPELL_GLOWS_IDS) do
		local activeFrames = GLOW_FRAMES[spellId] or {}
		for _, frame in pairs(activeFrames) do
			stopGlow(frame)
		end
	end
end

local function HandleGlow(dbIndex, spellId, runesRequired, missingBoneShieldCharges, minBoneShieldCharges, maxRunicPower, healthThreshold, minNearbyCreatures, inRangeCheck)
	if not IsSpellKnown(spellId) then
		return
	end

	if not GLOW_FRAMES[spellId] then
		return
	end

	local shouldGlow = CheckSpellGlow(dbIndex, spellId, runesRequired, missingBoneShieldCharges, minBoneShieldCharges, maxRunicPower, healthThreshold, minNearbyCreatures, inRangeCheck)
	for _, frame in pairs(GLOW_FRAMES[spellId]) do
		if shouldGlow then
			startGlow(frame)
		else
			stopGlow(frame)
		end
	end
end

function Pirrformance:UpdateSpellGlow()
	if not self:IsSpellGlowEnabled() then
		return
	end

	-- Marrowrend
	HandleGlow(1, SPELL_GLOWS_IDS[1], 2, 5, nil, nil, nil, nil, true)

	-- Death's Caress
	HandleGlow(2, SPELL_GLOWS_IDS[2], 1, 5, nil, nil, nil, nil, true)

	-- Tombstone
	HandleGlow(3, SPELL_GLOWS_IDS[3], 0, nil, 6, 95, nil, nil, nil)

	-- Bonestorm
	HandleGlow(4, SPELL_GLOWS_IDS[4], 0, nil, 6, nil, nil, 2, nil)

	-- Soul Reaper
	HandleGlow(5, SPELL_GLOWS_IDS[5], 1, nil, nil, nil, 35, nil, true)
end

--------------------- TOOLS ---------------------

-- Auto Delete
function Pirrformance:HookAutoDelete()
	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(s)
		if not STORAGE_GLOBAL.tools.autoDelete then
			return
		end

		s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)

	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow", function(s)
		if not STORAGE_GLOBAL.tools.autoDelete then
			return
		end

		s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)
end

-- Range Indicator
function Pirrformance:SetupRangeFrame()
	local rangeFrame = CreateFrame("Frame", "RangeFrame", UIParent, "BackdropTemplate")

	rangeFrame:SetSize(180, 36)
	rangeFrame:SetPoint("CENTER", UIParent, "CENTER") -- Position at the center of the screen

	local backdropInfo = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", -- Background texture
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Border texture
		tile = true,
		tileSize = 8,
		edgeSize = 8,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	}
	rangeFrame:SetBackdrop(backdropInfo)
	rangeFrame:SetBackdropColor(0, 0, 0, 1)
	rangeFrame:SetBackdropBorderColor(1, 1, 1, 1)

	-- Create a FontString for the text
	rangeFrame.text = rangeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	rangeFrame.text:SetPoint("CENTER", rangeFrame, "CENTER")
	rangeFrame.text:SetText("Range: <No Target>")
	rangeFrame.text:SetTextColor(1, 1, 1, 1)

	rangeFrame:SetMovable(true)
	rangeFrame:EnableMouse(true)

	if STORAGE_GLOBAL.tools.rangeIndicator then
		rangeFrame:Show()
	else
		rangeFrame:Hide()
	end

	-- Make the frame draggable
	rangeFrame:RegisterForDrag("LeftButton")
	rangeFrame:SetScript("OnDragStart", rangeFrame.StartMoving)
	rangeFrame:SetScript("OnDragStop", rangeFrame.StopMovingOrSizing)

	local timeElapsed = 0
	rangeFrame:HookScript("OnUpdate", function(self, elapsed)
		if not STORAGE_GLOBAL.tools.rangeIndicator then
			return
		end

		timeElapsed = timeElapsed + elapsed
		if timeElapsed > 0.2 then -- 0.2 seconds
			timeElapsed = 0

			local range = Pirrformance:GetRangeToTarget()
			self.text:SetText("Range: " .. range)
			-- self:SetSize(rangeFrame.text:GetStringWidth() + 20, rangeFrame.text:GetStringHeight() + 20)
		end
	end)
end

function Pirrformance:GetRangeToTarget()
	if UnitIsUnit("target", "player") or not UnitExists("target") then
		return "<No Target>"
	end

	local shortestRange = math.huge
	for range, itemId in pairs(itemRanges) do
		if C_Item.IsItemInRange(itemId, "target") then
			if range < shortestRange then
				shortestRange = range
			end
		end
	end

	if shortestRange <= 5 then
		return "Melee"
	end

	return (shortestRange < math.huge) and tostring(shortestRange) or "<Out of Range>"
end

function Pirrformance:ToggleRangeIndicator(info, value)
	local rangeFrame = _G["RangeFrame"]

	if not rangeFrame then
        self:Print("Error: rangeFrame is not initialized.")
        return
    end

	STORAGE_GLOBAL.tools.rangeIndicator = value

	if value then
		rangeFrame:Show()
	else
		rangeFrame:Hide()
	end
end