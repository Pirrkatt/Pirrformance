local addonName, addon = ...

Pirrformance = LibStub("AceAddon-3.0"):NewAddon("Pirrformance", "AceConsole-3.0", "AceEvent-3.0")

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
	},
	global = {
		sounds = {
			customSoundsEnabled = false,
		},
	},
}

local STORAGE_GLOBAL = {
	sounds = {},
}
local STORAGE_CHAR = {
	autoMark = {},
}

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
		tools = {
			type = "group",
			name = "Tools",
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
				CustomSounds = {
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
							get = function() return STORAGE_GLOBAL.sounds.BL_Hagge end,
							set = function(_, newValue) STORAGE_GLOBAL.sounds.BL_Hagge = newValue end,
							disabled = function() return not Pirrformance:IsCustomSoundsEnabled() end,
							order = 3,
						},
					},
				},
			},
		}
	},
}

function Pirrformance:OnInitialize() -- Called when the addon is loaded
	self.db = LibStub("AceDB-3.0"):New("PirrformanceDB", defaults, true)

	STORAGE_GLOBAL = self.db.global

	STORAGE_CHAR.autoMark = self.db.char.autoMark
	STORAGE_CHAR.sounds = self.db.char.sounds

	OPTIONS_MARK_LIST = options.args.tools.args.autoMarkPlayers.args

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Pirrformance", options)
	self.optionsFrame, self.settingsCategoryId = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Pirrformance", "|c" .. CONFIG.colorDark .. "Pirr|c" .. CONFIG.colorLight .. "formance|r")

	-- Slash Commands
	self:RegisterChatCommand("pf", "SlashCommand")
	self:RegisterChatCommand("pirr", "SlashCommand")
	self:RegisterChatCommand("pirrformance", "SlashCommand")

	self:LoadExtraEntries()
end

function Pirrformance:OnEnable() -- Called when the addon is enabled
	-- AutoMark
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")

	-- Sounds
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Pirrformance:SlashCommand(msg)
	Settings.OpenToCategory(self.settingsCategoryId)
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

function Pirrformance:COMBAT_LOG_EVENT_UNFILTERED()
	local haggeChars = {["Haggerid"] = true, ["Hâg"] = true}
	local spellId_Heroism, spellId_PrimalRage = 32182, 264667

	if not self:IsCustomSoundsEnabled() then
		return
	end

	if not STORAGE_GLOBAL.sounds.BL_Hagge then
		return
	end

	local _, subevent, _, _, sourceName, _, _, _, destName, _, _, spellId = CombatLogGetCurrentEventInfo()

	if subevent == "SPELL_AURA_APPLIED" and (spellId == spellId_Heroism or spellId == spellId_PrimalRage) then
		if haggeChars[sourceName] then
			PlaySoundFile("Interface\\AddOns\\Pirrformance\\Sounds\\BL-Hagge.ogg", "SFX")
			return
		end
	end
end

function Pirrformance:IsCustomSoundsEnabled(info)
	return STORAGE_GLOBAL.sounds.customSoundsEnabled
end

function Pirrformance:ToggleCustomSounds(info, value)
	STORAGE_GLOBAL.sounds.customSoundsEnabled = value
end