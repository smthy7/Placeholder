local addonName, addonTable = ...
local AOEGuide = CreateFrame("Frame", "AOEGuideFrame", UIParent)
_G["AOEGuide"] = AOEGuide

local pins = {}
local lines = {}

AOEGuide:RegisterEvent("ADDON_LOADED")
AOEGuide:RegisterEvent("PLAYER_ENTERING_WORLD")
AOEGuide:RegisterEvent("PLAYER_LEVEL_UP")

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        AOEGuideDB = AOEGuideDB or { enabled = true, showAllLevels = false }
        print("|cFF00FF00AOE Guide loaded!|r Use /aoe to toggle, /aoe all to show all levels.")

        -- Hook map update for Retail/Classic modern clients
        if WorldMapFrame then
            if WorldMapFrame.RegisterCallback then
                 WorldMapFrame:RegisterCallback("WorldMapUpdate", function()
                    if AOEGuideDB.enabled then AOEGuide:RefreshMap() end
                end)
            else
                -- Fallback for some clients
                WorldMapFrame:HookScript("OnShow", function() AOEGuide:RefreshMap() end)
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEVEL_UP" then
        AOEGuide:RefreshMap()
    end
end

AOEGuide:SetScript("OnEvent", OnEvent)

SLASH_AOEGUIDE1 = "/aoe"
SlashCmdList["AOEGUIDE"] = function(msg)
    msg = msg:lower():trim()
    if msg == "all" then
        AOEGuideDB.showAllLevels = not AOEGuideDB.showAllLevels
        print("AOE Guide Show All Levels: " .. (AOEGuideDB.showAllLevels and "|cFF00FF00On|r" or "|cFFFF0000Off|r"))
    else
        AOEGuideDB.enabled = not AOEGuideDB.enabled
        print("AOE Guide " .. (AOEGuideDB.enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"))
    end
    AOEGuide:RefreshMap()
end

local function CreatePinFrame()
    local f = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer.Child)
    f:SetSize(20, 20)
    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints()
    f.tex:SetTexture("Interface\\Icons\\Ability_Mage_FrostNova")

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.text:SetPoint("BOTTOM", f, "TOP", 0, 2)

    f:SetScript("OnEnter", function(self)
        if self.description then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.name, 1, 1, 1)
            GameTooltip:AddLine("Level: " .. self.lvlRange, 0.7, 0.7, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.description, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    table.insert(pins, f)
    return f
end

local function GetPin()
    for _, pin in ipairs(pins) do
        if not pin:IsShown() then return pin end
    end
    return CreatePinFrame()
end

local function GetLine()
    for _, line in ipairs(lines) do
        if not line:IsShown() then return line end
    end
    local line = WorldMapFrame.ScrollContainer.Child:CreateLine(nil, "OVERLAY")
    line:SetThickness(2.5)
    line:SetColorTexture(1, 0.8, 0, 0.5)
    table.insert(lines, line)
    return line
end

function AOEGuide:ClearMap()
    for _, pin in ipairs(pins) do pin:Hide() end
    for _, line in ipairs(lines) do line:Hide() end
end

function AOEGuide:RefreshMap()
    self:ClearMap()
    if not AOEGuideDB or not AOEGuideDB.enabled or not WorldMapFrame:IsShown() then return end

    local mapID = WorldMapFrame:GetMapID()
    if not mapID or not addonTable.AOEData[mapID] then return end

    local playerLevel = UnitLevel("player")
    local canvas = WorldMapFrame.ScrollContainer.Child
    local mapWidth = canvas:GetWidth()
    local mapHeight = canvas:GetHeight()

    for _, spot in ipairs(addonTable.AOEData[mapID]) do
        -- Show if within 2 levels of range, or if 'showAllLevels' is true
        local isLevelAppropriate = (playerLevel >= spot.minLevel - 2 and playerLevel <= spot.maxLevel + 2)
        if AOEGuideDB.showAllLevels or isLevelAppropriate then
            -- Draw Pins
            for i, p in ipairs(spot.points) do
                local pin = GetPin()
                pin:SetPoint("CENTER", canvas, "TOPLEFT", (p.x / 100) * mapWidth, -(p.y / 100) * mapHeight)
                pin.name = spot.name
                pin.description = spot.description
                pin.lvlRange = spot.minLevel .. "-" .. spot.maxLevel
                pin.text:SetText(pin.lvlRange)
                pin:Show()
            end

            -- Draw Lines
            for _, arrow in ipairs(spot.arrows) do
                local from = spot.points[arrow[1]]
                local to = spot.points[arrow[2]]
                if from and to then
                    local line = GetLine()
                    -- Use canvas as relativeTo to be safe
                    line:SetStartPoint("TOPLEFT", canvas, (from.x / 100) * mapWidth, -(from.y / 100) * mapHeight)
                    line:SetEndPoint("TOPLEFT", canvas, (to.x / 100) * mapWidth, -(to.y / 100) * mapHeight)
                    line:Show()
                end
            end
        end
    end
end
