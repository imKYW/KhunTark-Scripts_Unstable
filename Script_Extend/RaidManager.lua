
-- rRaidManager: core
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, L = ...

local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = false,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local TEX_WORLD_RAID_MARKERS = {
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t",
  "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t",
}

local button, leftButton, previousButton

local manager = CreateFrame("Frame", A.."Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate", "SecureHandlerStateTemplate")

-----------------------------
-- Functions
-----------------------------

--ButtonOnEnter
local function ButtonOnEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
  GameTooltip:AddLine(self.tooltipText, 0, 1, 0.5, 1, 1, 1)
  GameTooltip:Show()
end

--ButtonOnLeave
local function ButtonOnLeave(self)
  GameTooltip:Hide()
end

--manager:CreateButton
function manager:CreateButton(name, text, tooltipText)
  local button = CreateFrame("Button", name, self, "SecureActionButtonTemplate, UIPanelButtonTemplate")
  button.text = _G[button:GetName().."Text"]
  button.text:SetText(text)
  button.tooltipText = tooltipText
  button:SetWidth(30)
  button:SetHeight(30)
  button:SetScript("OnEnter", ButtonOnEnter)
  button:SetScript("OnLeave", ButtonOnLeave)
  return button
end

--manager:CreateWorldMarkerButtons
function manager:CreateWorldMarkerButtons()
  for i=1, #TEX_WORLD_RAID_MARKERS do
    local text = TEX_WORLD_RAID_MARKERS[i]
    local button = self:CreateButton(A.."Button"..i, text, "WorldMarker"..i)
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", format("/wm %d", i))
    if not previousButton then
      button:SetPoint("TOPRIGHT", manager, -25, -10)
    else
      button:SetPoint("TOP", previousButton, "BOTTOM", 0, 0)
    end
    local cancelButton = self:CreateButton(A.."Button"..i.."Cancel", "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:14:14:0:0|t", "Clear WorldMarker"..i)
    cancelButton:SetAttribute("type", "macro")
    cancelButton:SetAttribute("macrotext", format("/cwm %d", i))
    cancelButton:SetPoint("RIGHT", button, "LEFT", 0, 0)
    previousButton = button
  end
end

--DisableBlizzard
local function DisableBlizzard()
  local needReload = false
  if (LoadAddOn("Blizzard_CUFProfiles")) then print("|cffffff00"..A.."|r Blizzard_CUFProfiles is loadable") needReload = true end
  if (LoadAddOn("Blizzard_CompactRaidFrames")) then print("|cffffff00"..A.."|r Blizzard_CompactRaidFrames is loadable") needReload = true end
  if needReload then
    DisableAddOn("Blizzard_CUFProfiles")
    DisableAddOn("Blizzard_CompactRaidFrames")
    StaticPopupDialogs["RRAIDMANAGER_RELOADUI_REQUEST"] = {
      text = "rRaidFrameManager needs a reload to fully disable the Blizzard raid addons. Reload now?",
      button1 = "Yes",
      button2 = "No",
      OnAccept = function()
        ReloadUI()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show ("RRAIDMANAGER_RELOADUI_REQUEST")
  else
    print("|cffffff00"..A.."|r Blizzard_CUFProfiles and Blizzard_CompactRaidFrames are disabled properly.")
  end
end

---------------------------
-- INIT
---------------------------

--create manager frame

manager:SetFrameStrata("DIALOG")
manager:SetSize(200,290)
manager:SetPoint("TOPLEFT", -190, -300)
manager:SetAlpha(0.4)
manager:SetBackdrop(backdrop)
manager:SetBackdropColor(0.1,0.1,0.1,0.9)
manager:SetBackdropBorderColor(0.7,0.7,0.7)
manager:RegisterEvent("PLAYER_LOGIN")
manager:SetScript("OnEvent", DisableBlizzard)
RegisterStateDriver(manager, "visibility", "[group] show; hide")

manager:CreateWorldMarkerButtons()

--cancel all world markers button
button = manager:CreateButton(A.."ButtonWMCancel", "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:14:14:0:0|t", "Clear all world markers")
button:SetScript("OnClick", ClearRaidMarker)
button:SetPoint("TOP", previousButton, "BOTTOM", 0, 0)
previousButton = button

--toggleButton
local toggleButton = CreateFrame("BUTTON", A.."ToggleButton", manager, "SecureHandlerClickTemplate")
toggleButton:SetPoint("TOPRIGHT",-3,-3)
toggleButton:SetPoint("BOTTOMRIGHT",-3,3)
toggleButton:SetWidth(15)
--toggleButton bg
local bg = toggleButton:CreateTexture(nil, "BACKGROUND", nil, -8)
bg:SetAllPoints()
bg:SetColorTexture(1,1,1)
bg:SetAlpha(0.05)
toggleButton.bg = bg
toggleButton.tooltipText = "Toggle "..A
toggleButton:SetScript("OnEnter", ButtonOnEnter)
toggleButton:SetScript("OnLeave", ButtonOnLeave)
--toggleButton secure onclick
toggleButton:SetAttribute("_onclick", [=[
  local ref = self:GetFrameRef("manager")
  if not ref:GetAttribute("state") then
    ref:SetAttribute("state","closed")
  end
  local state = ref:GetAttribute("state")
  if state == "closed" then
    ref:SetAlpha(1)
    ref:SetWidth(275)
    ref:SetAttribute("state","open")
  else
    ref:SetAlpha(0.4)
    ref:SetWidth(200)
    ref:SetAttribute("state","closed")
  end
]=])
--toggleButton frame reference
toggleButton:SetFrameRef("manager", manager)
