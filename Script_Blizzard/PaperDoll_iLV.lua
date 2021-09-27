local setFont, _, setFontFlags = NumberFontNormal:GetFont()

local slot = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger0",
    [12] = "Finger1",
    [13] = "Trinket0",
    [14] = "Trinket1",
    [15] = "Back",
    [16] = "MainHand",
    [17] = "SecondaryHand"
}

local f = {
    player = CreateFrame("Frame"),
    target = CreateFrame("Frame"),
}
f.player:SetParent(PaperDollItemsFrame)

local iLvlText = {
    player = {},
    target = {},
}

local function GetLevels(target)
    local button
    if target == "player" then
        button = "Character"
    else
        button = "Inspect"
        if not iLvlText[target].ilvl then
            iLvlText[target].ilvl = f.target:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        end
        iLvlText[target].ilvl:SetText("iLV " .. C_PaperDollInfo.GetInspectItemLevel(target))
        iLvlText[target].ilvl:SetPoint("RIGHT", InspectPaperDollItemsFrame, "TOPRIGHT", -5, -45)
    end
    local _, averageILvl = GetAverageItemLevel()
    for k = 1, 17 do
        if slot[k] then
            if not iLvlText[target][k] then
                iLvlText[target][k] = f[target]:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
            end
            local itemLink = GetInventoryItemLink(target, k)
            if itemLink then
                local itemLevel = GetDetailedItemLevelInfo(itemLink)
                local itemQuality = GetInventoryItemQuality(target, k)
                local colorR, colorG, colorB = GetItemQualityColor(itemQuality)
                iLvlText[target][k]:SetFont(setFont, 11, setFontFlags)
                iLvlText[target][k]:SetText(itemLevel)
                iLvlText[target][k]:SetTextColor(colorR, colorG, colorB)
                if k == 2 and itemQuality == 6 and target == "player" then
                    iLvlText[target][k]:SetPoint("TOP", button .. slot[k] .. "Slot", "TOP", 0, -2)
                else
                    iLvlText[target][k]:SetPoint("BOTTOM", button .. slot[k] .. "Slot", "BOTTOM", 0, 2)
                end
            elseif iLvlText[target][k] then
                iLvlText[target][k]:SetText("")
            end
        end
    end
end

-- Character
f.player:RegisterEvent("ITEM_UNLOCKED")
f.player:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f.player:SetScript("OnEvent", function() GetLevels("player") end)
PaperDollItemsFrame:HookScript("OnShow", function() GetLevels("player") end)
PaperDollItemsFrame:HookScript("OnHide", function() collectgarbage() end)

-- Inspect
f.target:RegisterEvent("ADDON_LOADED")
f.target:RegisterEvent("INSPECT_READY")
f.target:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "Blizzard_InspectUI" then
        self:SetParent(InspectPaperDollItemsFrame)
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "INSPECT_READY" and InspectPaperDollItemsFrame then
        GetLevels("target")
    end
end)
