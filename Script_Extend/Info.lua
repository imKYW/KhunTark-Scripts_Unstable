-- CONFIG
---------------------------------------------

local addonList = 50
local font = 'Fonts\\FRIZQT__.ttf'
local fontSize = 12
local fontFlag = nil
local textAlign = 'RIGHT'
local position = { "BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, 3 }
local customColor = false
local useShadow = true

-- CODE ITSELF
---------------------------------------------

local KTinfoFrame = CreateFrame('Frame', 'KTinfo', UIParent)

local color
if customColor then
	color = { r = 0, g = 1, b = 0.7 }
else
	local _, class = UnitClass("player")
	color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
end

local gradientColor = {
    0, 1, 0,
    1, 1, 0,
    1, 0, 0
}

local function memFormat(number)
	if number > 1024 then
		return string.format("%.2f mb", (number / 1024))
	else
		return string.format("%.1f kb", floor(number))
	end
end

-- http://www.wowwiki.com/ColorGradient
local function ColorGradient(perc, ...)
    if (perc >= 1) then
        local r, g, b = select(select('#', ...) - 2, ...)
        return r, g, b
    elseif (perc <= 0) then
        local r, g, b = ...
        return r, g, b
    end

    local num = select('#', ...) / 3

    local segment, relperc = math.modf(perc*(num-1))
    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

    return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function RGBGradient(num)
    local r, g, b = ColorGradient(num, unpack(gradientColor))
    return r, g, b
end

local function addonCompare(a, b)
	return a.memory > b.memory
end

local function clearGarbage()
	UpdateAddOnMemoryUsage()
	local before = gcinfo()
	collectgarbage()
	UpdateAddOnMemoryUsage()
	local after = gcinfo()
	print("|c0000ddffCleaned:|r "..memFormat(before-after))
end

KTinfoFrame:EnableMouse(true)
KTinfoFrame:SetScript("OnMouseDown", function()
	clearGarbage()
end)

local function getFPS()
	return "|c00ffffff" .. floor(GetFramerate()) .. " fps|r"
end

local function getMemory()
	local total = 0
	UpdateAddOnMemoryUsage()
	for i=1, GetNumAddOns(), 1 do
		total = total + GetAddOnMemoryUsage(i)
	end
	return "|c00ffffff"..memFormat(total).."|r"
end

local function getLatencyWorldRaw()
	return select(4, GetNetStats())
end

local function getLatencyWorld()
	return "|c00ffffffW:" .. getLatencyWorldRaw() .. "|r"
end

local function getLatencyRaw()
	return select(3, GetNetStats())
end

local function getLatency()
	return "|c00ffffffH:" .. getLatencyRaw() .. "|r"
end

local function addonTooltip(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	local blizz = collectgarbage("count")
	local addons = {}
	local enry, memory
	local total = 0
	local nr = 0
	UpdateAddOnMemoryUsage()
	GameTooltip:AddLine("AddOns", color.r, color.g, color.b)
	--GameTooltip:AddLine(" ")
	for i=1, GetNumAddOns(), 1 do
		if (GetAddOnMemoryUsage(i) > 0 ) then
			memory = GetAddOnMemoryUsage(i)
			entry = {name = GetAddOnInfo(i), memory = memory}
			table.insert(addons, entry)
			total = total + memory
		end
	end
	table.sort(addons, addonCompare)
	for _, entry in pairs(addons) do
		if nr < addonList then
			GameTooltip:AddDoubleLine(entry.name, memFormat(entry.memory), 1, 1, 1, RGBGradient(entry.memory / 800))
			nr = nr+1
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Total", memFormat(total), 1, 1, 1, RGBGradient(total / (1024*10)))
	GameTooltip:AddDoubleLine("Total incl. Blizzard", memFormat(blizz), 1, 1, 1, RGBGradient(blizz / (1024*10)))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Network", color.r, color.g, color.b)
	--GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Home", getLatencyRaw().." ms", 1, 1, 1, RGBGradient(getLatencyRaw()/ 100))
	GameTooltip:AddDoubleLine("World", getLatencyWorldRaw().." ms", 1, 1, 1, RGBGradient(getLatencyWorldRaw()/ 100))
	GameTooltip:Show()
end

KTinfoFrame:SetScript("OnEnter", function()
	addonTooltip(KTinfoFrame)
end)
KTinfoFrame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

KTinfoFrame:SetPoint(unpack(position))
KTinfoFrame:SetWidth(50)
KTinfoFrame:SetHeight(fontSize)

KTinfoFrame.text = KTinfoFrame:CreateFontString(nil, 'BACKGROUND')
KTinfoFrame.text:SetPoint(textAlign, KTinfoFrame)
KTinfoFrame.text:SetFont(font, fontSize, fontFlag)
if useShadow then
	KTinfoFrame.text:SetShadowOffset(1, -1)
	KTinfoFrame.text:SetShadowColor(0, 0, 0)
end
KTinfoFrame.text:SetTextColor(color.r, color.g, color.b)

local lastUpdate = 0

local function update(self,elapsed)
	lastUpdate = lastUpdate + elapsed
	if lastUpdate > 1 then
		lastUpdate = 0
		KTinfoFrame.text:SetText(getFPS().." # "..getMemory().." # "..getLatency().." "..getLatencyWorld())
		self:SetWidth(KTinfoFrame.text:GetStringWidth())
		self:SetHeight(KTinfoFrame.text:GetStringHeight())
	end
end

KTinfoFrame:SetScript("OnEvent", function(self, event)
	if(event=="PLAYER_LOGIN") then
		self:SetScript("OnUpdate", update)
	end
end)
KTinfoFrame:RegisterEvent("PLAYER_LOGIN")
