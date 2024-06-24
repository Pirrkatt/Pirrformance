Pirrformance = LibStub("AceAddon-3.0"):NewAddon("Pirrformance", "AceConsole-3.0", "AceEvent-3.0")

local defaults = {
	global = {
		autoMarkList = {
			[1] = {name = "", mark = 0},
			[2] = {name = "", mark = 0},
			[3] = {name = "", mark = 0},
			[4] = {name = "", mark = 0}},
		autoMarkEnabled = false,
		markSelfEnabled = false,
		markSelfMarker = 0,
	},
}

local GLOBAL_STORAGE
local CONFIG = {
	colorLight = "ffDA70D6",
	colorDark = "ff9147D0",
	colorDetail =  "ff8A6D92",
}

local markers = {
	[0] = "", -- None
	[1] = "1", -- Star
	[2] = "2", -- Circle
	[3] = "3", -- Diamond
	[4] = "4", -- Triangle
	[5] = "5", -- Moon
	[6] = "6", -- Square
	[7] = "7", -- Cross (X)
	[8] = "8", -- Skull
}

local options = {
	name = "|c" .. CONFIG.colorDark .. "Pirr|c" .. CONFIG.colorLight .. "formance|r",
	handler = Pirrformance,
	type = "group",
	args = {
		author = {
			type = "description",
			name = "|c" .. CONFIG.colorDetail .. "Author:|r Pirrkatt",
			fontSize = "medium",
			order = 1,
		},
		version = {
			type = "description",
			name = "|c" .. CONFIG.colorDetail .. "Version:|r 1.0",
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
							get = function() return GLOBAL_STORAGE.markSelfEnabled end,
							set = function(_, newValue) GLOBAL_STORAGE.markSelfEnabled = newValue end,
							width = 0.7,
							order = 4,
						},
						selfMark = {
							type = "select",
							name = "",
							values = markers,
							width = 0.3,
							get = function() return GLOBAL_STORAGE.markSelfMarker end,
							set = "AssignMarker",
							disabled = function() return not GLOBAL_STORAGE.markSelfEnabled end,
							order = 5,
						},
						player1 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return GLOBAL_STORAGE.autoMarkList[1].name end,
							order = 6,
							width = 0.9,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end;
						},
						mark1 = {
							type = "select",
							name = "",
							order = 7,
							values = markers,
							width = 0.3,
							set = "AssignMarker",
							get = function() return GLOBAL_STORAGE.autoMarkList[1].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player2 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return GLOBAL_STORAGE.autoMarkList[2].name end,
							order = 8,
							width = 0.9,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end;
						},
						mark2 = {
							type = "select",
							name = "",
							order = 9,
							values = markers,
							width = 0.3,
							set = "AssignMarker",
							get = function() return GLOBAL_STORAGE.autoMarkList[2].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player3 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return GLOBAL_STORAGE.autoMarkList[3].name end,
							order = 10,
							width = 0.9,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end;
						},
						mark3 = {
							type = "select",
							name = "",
							order = 11,
							values = markers,
							width = 0.3,
							set = "AssignMarker",
							get = function() return GLOBAL_STORAGE.autoMarkList[3].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
						player4 = {
							type = "input",
							name = "",
							set = "AddPlayerToList",
							get = function() return GLOBAL_STORAGE.autoMarkList[4].name end,
							order = 12,
							width = 0.9,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end;
						},
						mark4 = {
							type = "select",
							name = "",
							order = 13,
							values = markers,
							width = 0.3,
							set = "AssignMarker",
							get = function() return GLOBAL_STORAGE.autoMarkList[4].mark end,
							disabled = function() return not Pirrformance:IsAutoMarkEnabled() end,
						},
					},
				},
				resetDefaults = {
					type = "execute",
					name = "Reset to Default",
					func = "ResetDefaults",
					confirm = true,
					order = 5,
				},
			},
		},
	},
}

function Pirrformance:OnInitialize() -- Called when the addon is loaded
	self.db = LibStub("AceDB-3.0"):New("PirrformanceDB", defaults, true)
	GLOBAL_STORAGE = self.db.global

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Pirrformance", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Pirrformance", "Pirrformance")

	-- Slash Commands
	self:RegisterChatCommand("pf", "SlashCommand")
	self:RegisterChatCommand("pirr", "SlashCommand")
	self:RegisterChatCommand("pirrformance", "SlashCommand")
end

function Pirrformance:OnEnable() -- Called when the addon is enabled
	self:RegisterEvent("PLAYER_STARTED_MOVING")
end

function Pirrformance:PLAYER_STARTED_MOVING()
	if not self:IsAutoMarkEnabled() then
		return
	end

	if not IsInGroup() then
		return
	end

	if GLOBAL_STORAGE.markSelfEnabled then
		if GLOBAL_STORAGE.markSelfMarker then
			if CanBeRaidTarget("player") and not (GetRaidTargetIndex("player") == GLOBAL_STORAGE.markSelfMarker) then
				SetRaidTarget("player", GLOBAL_STORAGE.markSelfMarker)
			end
		end
	end

	for _, playerName in pairs(GetHomePartyInfo()) do
		for i = 1, #GLOBAL_STORAGE.autoMarkList do
			if GLOBAL_STORAGE.autoMarkList[i].name:len() > 0 and GLOBAL_STORAGE.autoMarkList[i].name == playerName then
				if not CanBeRaidTarget(playerName) then
					return
				end
				if GetRaidTargetIndex(playerName) == GLOBAL_STORAGE.autoMarkList[i].mark then
					return
				end

				SetRaidTarget(playerName, GLOBAL_STORAGE.autoMarkList[i].mark)
			end
		end
	end
end

function Pirrformance:SlashCommand(msg)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function Pirrformance:IsAutoMarkEnabled(info)
	return GLOBAL_STORAGE.autoMarkEnabled
end

function Pirrformance:ToggleAutoMark(info, value)
	GLOBAL_STORAGE.autoMarkEnabled = value
end

function Pirrformance:AddPlayerToList(info, newValue)
	local index = string.gsub(info[#info], "player", "")

	if newValue:len() > 0 then
		for i = 1, #GLOBAL_STORAGE.autoMarkList do
			if GLOBAL_STORAGE.autoMarkList[i].name:lower() == newValue:lower() then
				self:Print("That player is already added.")
				return
			end
		end
	end

	GLOBAL_STORAGE.autoMarkList[tonumber(index)].name = newValue
end

function Pirrformance:AssignMarker(info, newValue)
	if newValue > 0 then
		for i = 1, #GLOBAL_STORAGE.autoMarkList do
			if GLOBAL_STORAGE.autoMarkList[i].mark == newValue then
				self:Print("That marker is already assigned.")
				return
			end
		end

		if GLOBAL_STORAGE.markSelfMarker == newValue then
			self:Print("That marker is already assigned.")
			return
		end
	end

	local selfMark = info[#info] == "selfMark"
	if selfMark then
		GLOBAL_STORAGE.markSelfMarker = newValue
		return
	end

	local index = string.gsub(info[#info], "mark", "")
	GLOBAL_STORAGE.autoMarkList[tonumber(index)].mark = newValue
end

function Pirrformance:ResetDefaults()
	GLOBAL_STORAGE = CopyTable(defaults.global)
end