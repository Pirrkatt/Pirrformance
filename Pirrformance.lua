local Pirrformance = CreateFrame("Frame", "Pirrformance")

local defaultOptions = {
	someOption = true,
	-- someNewOption = "banana",
}

-- SetRaidTarget(unit, index) - Assigns a raid target icon to a unit.
-- CanBeRaidTarget(unit) - Returns true if the unit can be marked with a raid target icon.
-- ClearRaidMarker(index) - Removes a raid marker from the world.
-- GetRaidTargetIndex(unit) - Returns the raid target of a unit.

function Pirrformance:OnEvent(event, ...)
	self[event](self, event, ...)
end

function Pirrformance:ADDON_LOADED(event, addOnName)
    if addOnName == "Pirrformance" then
		PirrformanceDB = PirrformanceDB or CopyTable(defaultOptions)
		self.db = PirrformanceDB
		self:InitializeOptions()
		-- hooksecurefunc("JumpOrAscendStart", function()
		-- 	if self.db.someOption then
		-- 		print("Your character jumped.")
		-- 	end
		-- end)
    end
end

Pirrformance:RegisterEvent("ADDON_LOADED")
Pirrformance:SetScript("OnEvent", Pirrformance.OnEvent)