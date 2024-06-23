Pirrformance.defaults = {
	autoMark = false,
	player1 = "",
	player2 = "",
}

local CONFIG = {
	colorLight = "ffDA70D6",
	colorDark = "ff9147D0",
	colorDetail =  "ff8A6D92",
}

function Pirrformance:CreateCheckbox(option, label, parent, updateFunc)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb.Text:SetText("  " .. label)

	local function UpdateOption(value)
		self.db[option] = value
		cb:SetChecked(value)
		if updateFunc then
			updateFunc(value)
		end
	end

	UpdateOption(self.db[option])

	cb:HookScript("OnClick", function(_, btn, down)
		UpdateOption(cb:GetChecked())
	end)

	EventRegistry:RegisterCallback("Pirrformance.OnReset", function()
		UpdateOption(self.defaults[option])
	end, cb)
	return cb
end

function Pirrformance:InitializeOptions()
	self.panel_main = CreateFrame("Frame")
	self.panel_main.name = "Pirrformance"

	local title = self.panel_main:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("|c" .. CONFIG.colorDark .. "Pirr|c" .. CONFIG.colorLight .. "formance|r")

	local function GetInfo(field)
		return GetAddOnMetadata("Pirrformance", field) or "N/A"
	end

	local author = self.panel_main:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	author:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
	author:SetFormattedText("|c" .. CONFIG.colorDetail .. "Author:|r %s", GetInfo("Author"))

	local version = self.panel_main:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, 0)
	version:SetFormattedText("|c" .. CONFIG.colorDetail .. "Version:|r %s", GetInfo("Version"))

	local cb_automark = self:CreateCheckbox("autoMark", "AutoMark Friends", self.panel_main)
	cb_automark:SetPoint("TOPLEFT", 20, -200)

	local btn_reset = CreateFrame("Button", nil, self.panel_main, "UIPanelButtonTemplate")
	btn_reset:SetPoint("TOPLEFT", cb_automark, 0, -40)
	btn_reset:SetText("Reset Settings")
	btn_reset:SetWidth(150)
	btn_reset:SetHeight(25)
	btn_reset:SetScript("OnClick", function()
		-- Todo: Confirm Popup
		PirrformanceDB = CopyTable(Pirrformance.defaults)
		self.db = PirrformanceDB
		EventRegistry:TriggerEvent("Pirrformance.OnReset")
	end)

	InterfaceOptions_AddCategory(Pirrformance.panel_main)
end

SLASH_PIRRFORMANCE1 = "/pirrformance"

SlashCmdList.PIRRFORMANCE = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(Pirrformance.panel_main)
end