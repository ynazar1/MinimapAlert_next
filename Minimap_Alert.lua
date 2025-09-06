minimapAlert = {}
local addonVersion = 28
local foundNode = false
local minimapSettings = {}
local timeElapsed = 0
local framesElapsed = 0
local mX, mY = -1, -1
local minimapAlertState = 'DISABLED'
local stateList = {}
local extraDelay = 0
local oldZoom = 0
local autoResume = false
local autoResumeLoot = ''
local minimapChildren = {}
local restore_gathermate = false
local preCombatScanning = false -- Remember if scanning was active before combat
local preCombatGathering = false -- Remember if we were gathering when combat started
local lootCooldown = 0 -- Prevent detection for a few seconds after loot
local forceFreshMinimap = false -- Force fresh minimap state on next scan after loot

-- Helper Functions
-- ===============

--[[
    Shared button click handler for minimap buttons
    Handles left-click (toggle UI) and right-click (open options)
    @param button: The button that was clicked ("LeftButton" or "RightButton")
--]]
local function handleMinimapButtonClick(button)
    if button == "LeftButton" then
        local guiFrame = _G["MinimapAlert_Interface"]
        if guiFrame then
            if guiFrame:IsVisible() then
                guiFrame:Hide()
            else
                guiFrame:Show()
            end
        end
    elseif button == "RightButton" then
        Settings.OpenToCategory(MinimapAlert_OptionsFrame.name)
    end
end

--[[
    Shared tooltip creation for minimap buttons
    Sets up consistent tooltip text and formatting
    @param tooltip: The tooltip frame to configure
--]]
local function setupMinimapButtonTooltip(tooltip)
    tooltip:SetText("Minimap Alert")
    tooltip:AddLine("Left-click to toggle the Minimap Alert interface", 1, 1, 1)
    tooltip:AddLine("Right-click to open options", 1, 1, 1)
end

--[[
    Reset common state variables to default values
    Used across multiple state transitions for consistency
    @param includeDetection: Whether to clear detection-related variables
--]]
local function resetStateVariables(includeDetection)
    timeElapsed = 0
    framesElapsed = 0
    extraDelay = 0
    
    if includeDetection then
        foundNode = false
        autoResume = false
        autoResumeLoot = ''
        mX = 9999
        mY = 9999
        forceFreshMinimap = false -- Clear fresh minimap flag
    end
end

--[[
    Set GUI frame to scanning mode (elevated level/strata)
    Used when starting scanning or resuming from loot
--]]
local function setGUIFrameScanningMode()
    local guiFrame = _G["MinimapAlert_Interface"]
    if guiFrame then
        guiFrame:SetFrameLevel(5)
        guiFrame:SetFrameStrata("DIALOG")
    end
end

--[[
    Set GUI frame to normal mode (restored level/strata)
    Used when stopping scanning
--]]
local function setGUIFrameNormalMode()
    local guiFrame = _G["MinimapAlert_Interface"]
    if guiFrame then
        guiFrame:SetFrameLevel(guiFrame.frameLevel)
        guiFrame:SetFrameStrata(guiFrame.frameStrata)
    end
end

--[[
    Safe execution wrapper with error handling
    Executes function and prints error if it fails
    @param func: Function to execute
    @param errorMsg: Error message to print on failure
    @return: success, result
--]]
local function safeExecute(func, errorMsg)
    local success, result = pcall(func)
    if not success then
        print("Minimap Alert: " .. (errorMsg or "Error in operation"))
    end
    return success, result
end

local function switchState(newState)
    if stateList[newState] then
        local success = pcall(function()
            minimapAlertState = newState
            stateList[newState]()
            lastStateChange = GetTime() -- Reset timeout timer
        end)
        if not success then
            print("Minimap Alert: Error in state transition to " .. tostring(newState) .. ", resetting to DISABLED")
            minimapAlertState = 'DISABLED'
            stateList['DISABLED']()
            lastStateChange = GetTime()
        end
    else
        print("Minimap Alert: Invalid state " .. tostring(newState) .. ", resetting to DISABLED")
        minimapAlertState = 'DISABLED'
        stateList['DISABLED']()
        lastStateChange = GetTime()
    end
end

if BackdropTemplateMixin then
    backdropStuff = "BackdropTemplate"
else
    backdropStuff = nil
end

local clickFrame = CreateFrame("Button", "MinimapAlert_ClickOverlay", Minimap)
clickFrame:SetFrameLevel(9001)
clickFrame:SetFrameStrata("HIGH")
clickFrame:SetAllPoints()
clickFrame:SetScript("OnMouseDown", function(self, button)
    if (minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW') then
        if button == 'RightButton' then       
            MouselookStart()    
        elseif button == 'LeftButton' then
            extraDelay = 1.5
        end
        switchState('RESET_STATE')
    end
end)
clickFrame:Hide()

local guiFrame = CreateFrame('Frame', "MinimapAlert_Interface", UIParent, backdropStuff)
guiFrame:SetSize(148, 66)
guiFrame:SetBackdrop({
      bgFile = 'Interface/FrameGeneral/UI-Background-Rock',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile = true, tileSize = 192, edgeSize = 16,
      insets = {left = 4, right = 4, top = 4, bottom = 4}})
guiFrame:ClearAllPoints()
guiFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
guiFrame:EnableMouse(true)
guiFrame:SetMovable(true)
guiFrame:SetFrameStrata("HIGH")
guiFrame.frameStrata = guiFrame:GetFrameStrata()
guiFrame.frameLevel = guiFrame:GetFrameLevel()
guiFrame:SetScript('OnMouseDown', function(self)
    self:StartMoving()
end)

guiFrame:SetScript('OnMouseUp', function(self)
    self:StopMovingOrSizing()
end)

guiFrame.glow = guiFrame:CreateTexture(nil, 'OVERLAY')
--guiFrame.glow:SetColorTexture(0.2, 0.8, 0.2, 0.8)
guiFrame.glow:SetTexture('Interface/FrameGeneral/UI-Background-Rock')
--guiFrame.glow:SetVertexColor(0.2, 1, 0.2)
guiFrame.glow:SetBlendMode('ADD')
guiFrame.glow:SetPoint('TOPLEFT', 6, -6)
guiFrame.glow:SetPoint('BOTTOMRIGHT', -6, 6)
guiFrame.glow:SetAlpha(0)

guiFrame.glowAnimation = guiFrame.glow:CreateAnimationGroup()
guiFrame.glowAnimation[1] = guiFrame.glowAnimation:CreateAnimation("Alpha")
guiFrame.glowAnimation[1]:SetDuration(0.25)
guiFrame.glowAnimation[1]:SetFromAlpha(1)
guiFrame.glowAnimation[1]:SetToAlpha(0)
--[[
guiFrame.glowAnimation[2] = guiFrame.glowAnimation:CreateAnimation("Alpha")
guiFrame.glowAnimation[2]:SetDuration(0.25)
guiFrame.glowAnimation[2]:SetFromAlpha(1)
guiFrame.glowAnimation[2]:SetToAlpha(0)
guiFrame.glowAnimation[2]:SetStartDelay(0.25)
--]]
local optionsButton = CreateFrame('Button', nil, guiFrame, 'GameMenuButtonTemplate')
optionsButton:SetSize(64, 24)
optionsButton:ClearAllPoints()
optionsButton:SetPoint('BOTTOMRIGHT', -8, 8)
optionsButton:SetText('Config')
optionsButton:SetScript('OnClick', function()
    --InterfaceOptionsFrame_OpenToCategory("Minimap Alert")
    --InterfaceOptionsFrame_OpenToCategory("Minimap Alert")
    Settings.OpenToCategory(MinimapAlert_OptionsFrame.name)
end)

local startButton = CreateFrame('Button', nil, guiFrame, 'GameMenuButtonTemplate')
startButton:SetSize(64, 24)
startButton:ClearAllPoints()
startButton:SetPoint('BOTTOMLEFT', 8, 8)
startButton:SetText('Start')
startButton.frameStrata = startButton:GetFrameStrata()
startButton.frameLevel = startButton:GetFrameLevel()

local spinner = CreateFrame('Frame', nil, guiFrame, "LoadingSpinnerTemplate")
spinner:ClearAllPoints()
spinner:SetPoint('TOPLEFT', 2, 2)
spinner:SetScale(0.9, 0.9)
spinner.AnimFrame.Circle:SetVertexColor(0.3, 0.3, 0.3)

local statusText = guiFrame:CreateFontString()
statusText:SetFontObject("GameFontNormal")
statusText:SetText('Inactive')
statusText:ClearAllPoints()
statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 0)

local lootText = guiFrame:CreateFontString()
lootText:SetFontObject("GameFontNormalSmall")
lootText:SetText('Waiting for loot')
lootText:SetTextColor(1, 1, 1)
lootText:SetPoint('TOPLEFT', statusText, 'BOTTOMLEFT', 0, 0)
lootText.oldShow = lootText.Show
lootText.Show = function(self)
    statusText:ClearAllPoints()
    statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 5)
    self:oldShow()
end

lootText.oldHide = lootText.Hide
lootText.Hide = function(self)
    statusText:ClearAllPoints()
    statusText:SetPoint('LEFT', spinner, 'RIGHT', -4, 0)
    self:oldHide()
end
lootText:Hide()


local tabFrame = CreateFrame('Frame', nil, guiFrame)
tabFrame:SetSize(140, 16)
tabFrame:SetPoint('TOP', 0, 12)
tabFrame:SetFrameLevel(guiFrame:GetFrameLevel()-1)
tabFrame:EnableMouse(true)
tabFrame:SetScript('OnMouseDown', function()
    guiFrame:StartMoving()
end)

tabFrame:SetScript('OnMouseUp', function()
    guiFrame:StopMovingOrSizing()
end)

tabFrame.l = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.l:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.l:SetSize(8, 1)
tabFrame.l:ClearAllPoints()
tabFrame.l:SetPoint('LEFT')
tabFrame.l:SetPoint('TOP')
tabFrame.l:SetPoint('BOTTOM')
tabFrame.l:SetTexCoord(0.03125, 0.140625, 0.28125, 1.0)

tabFrame.m = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.m:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.m:SetSize(124, 1)
tabFrame.m:ClearAllPoints()
tabFrame.m:SetPoint('LEFT', tabFrame.l, 'RIGHT')
tabFrame.m:SetPoint('TOP')
tabFrame.m:SetPoint('BOTTOM')
tabFrame.m:SetTexCoord(0.140625, 0.859375, 0.28125, 1.0)

tabFrame.r = tabFrame:CreateTexture(nil, 'BACKGROUND')
tabFrame.r:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
tabFrame.r:SetSize(8, 1)
tabFrame.r:ClearAllPoints()
tabFrame.r:SetPoint('LEFT', tabFrame.m, 'RIGHT')
tabFrame.r:SetPoint('TOP')
tabFrame.r:SetPoint('BOTTOM')
tabFrame.r:SetTexCoord(0.859375, 0.96875, 0.28125, 1.0)

tabFrame.t = tabFrame:CreateFontString()
tabFrame.t:SetFontObject("GameFontNormalSmall")
tabFrame.t:SetPoint('TOP', 0, -3)
tabFrame.t:SetText('Minimap Alert')

tabFrame.closeButton = CreateFrame('Button', nil, tabFrame, "UIPanelCloseButton")
tabFrame.closeButton:SetSize(18, 18)
tabFrame.closeButton:SetPoint('TOPRIGHT', 0, 0)
tabFrame.closeButton:SetFrameLevel(guiFrame:GetFrameLevel()+1)

local fullscreenGlow = CreateFrame('Frame', nil, UIParent)
fullscreenGlow:SetAllPoints()

fullscreenGlow.t = fullscreenGlow:CreateTexture(nil, 'BACKGROUND')
fullscreenGlow.t:SetAllPoints()
fullscreenGlow.t:SetTexture("Interface\\AddOns\\Minimap_Alert\\Fullscreen_Flash")
fullscreenGlow.t:SetBlendMode('ADD')
fullscreenGlow.t:SetVertexColor(0.6, 0.45, 1)
fullscreenGlow.t:SetAlpha(0)

fullscreenGlow.Anim = fullscreenGlow.t:CreateAnimationGroup()
fullscreenGlow.Anim[1] = fullscreenGlow.Anim:CreateAnimation("Alpha")
fullscreenGlow.Anim[1]:SetDuration(0.5)
fullscreenGlow.Anim[1]:SetFromAlpha(1)
fullscreenGlow.Anim[1]:SetToAlpha(0)

local function setSpinnerColor(r,g,b)
    spinner.AnimFrame.Circle:SetVertexColor(r,g,b)
end

local function startSpinner()
    setSpinnerColor(0.1, 1, 0.1)
    spinner.Anim:Play()
end

local function pauseSpinner()
    setSpinnerColor(1, 1, 0.1)
    spinner.Anim:Pause()
end

local function stopSpinner()
    setSpinnerColor(0.3, 0.3, 0.3)
    spinner.Anim:Stop()
end

local function updateAddonSettings()
    for k,v in pairs(minimapAlert.defaultData.settings) do
        if not minimapAlert.saveData.settings[k] then
            minimapAlert.saveData.settings[k] = v
        end
    end
end

local function restoreMinimap()
    local success = pcall(function()
        local m = minimapSettings
        
        -- Validate minimap settings exist
        if not m or not m.alpha then
            print("Minimap Alert: Warning - minimap settings corrupted, using defaults")
            m = {
                alpha = 1,
                scale = 1,
                point = "CENTER",
                relativeTo = "UIParent",
                relativePoint = "CENTER",
                x = 0,
                y = 0,
                frameLevel = 1,
                frameStrata = "BACKGROUND",
                GameTooltipScale = 1,
                MiniMapTrackingVisible = true,
                MiniMapMailFrameVisible = true
            }
        end
        
        Minimap:SetAlpha(m.alpha or 1)
        Minimap:SetScale(m.scale or 1)
        Minimap:ClearAllPoints()
        Minimap:SetPoint(m.point or "CENTER", m.relativeTo or "UIParent", m.relativePoint or "CENTER", m.x or 0, m.y or 0)
        MinimapCluster:SetFrameLevel(m.frameLevel or 1)
        MinimapCluster:SetFrameStrata(m.frameStrata or "BACKGROUND")
        GameTooltip:SetScale(m.GameTooltipScale or 1)

        -- Restore minimap children with error handling
        if minimapChildren then
            for k,v in pairs(minimapChildren) do
                if v and v.MMA_VISIBLE ~= nil then
                    if v.MMA_VISIBLE then 
                        v:Show() 
                    else
                        v:Hide()
                    end
                end
                if v and v.MMA_FRAME_STRATA then
                    v:SetFrameStrata(v.MMA_FRAME_STRATA)
                end
                if v and v.MMA_FRAME_LEVEL then
                    v:SetFrameLevel(v.MMA_FRAME_LEVEL)
                end
            end
        end

        -- Restore tracking and mail frames with error handling
        if m.MiniMapTrackingVisible and MiniMapTracking then
            MiniMapTracking:Show()
        end
        if m.MiniMapMailFrameVisible and MiniMapMailFrame then
            MiniMapMailFrame:Show()
        end

        -- Re-enable mouse interaction
        Minimap:SetMouseClickEnabled(true)
        MinimapCluster:SetMouseClickEnabled(true)
        clickFrame:Hide()

        --Gathermate fix
        if restore_gathermate and GatherMate2 then
            restore_gathermate = false
            GatherMate2:Enable()
        end
    end)
    
    if not success then
        print("Minimap Alert: Error restoring minimap, forcing reset")
        -- Force reset to safe defaults
        Minimap:SetAlpha(1)
        Minimap:SetScale(1)
        Minimap:ClearAllPoints()
        Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        MinimapCluster:SetFrameLevel(1)
        MinimapCluster:SetFrameStrata("BACKGROUND")
        GameTooltip:SetScale(1)
        Minimap:SetMouseClickEnabled(true)
        MinimapCluster:SetMouseClickEnabled(true)
        clickFrame:Hide()
    end
end

local function storeMinimap()
    local m = minimapSettings
    m.point, m.relativeTo, m.relativePoint, m.x, m.y = Minimap:GetPoint()
    m.parent = Minimap:GetParent()
    m.alpha = Minimap:GetAlpha()
    m.scale = Minimap:GetScale()
    --m.zoom = Minimap:GetZoom()
    m.GameTooltipScale = GameTooltip:GetScale()
    m.frameLevel = MinimapCluster:GetFrameLevel()
    m.frameStrata = MinimapCluster:GetFrameStrata()
   -- Minimap:SetMouseClickEnabled(false)

    minimapChildren = {Minimap:GetChildren()}
    for k,v in pairs(minimapChildren) do
        v.MMA_VISIBLE = v:IsVisible()
        v.MMA_FRAME_LEVEL = v:GetFrameLevel()
        v.MMA_FRAME_STRATA = v:GetFrameStrata()
    end

    m.MiniMapTrackingVisible = MiniMapTracking and MiniMapTracking:IsVisible()
    m.MiniMapMailFrameVisible =  MiniMapMailFrame and MiniMapMailFrame:IsVisible()

    --Gathermate fix
    if GatherMate2 and GatherMate2:IsEnabled() then
        restore_gathermate = true
        GatherMate2:Disable()
    end
end

guiFrame:SetScript('OnShow', function(self)
    if minimapAlert.saveData.showWhatsNew then MinimapAlert_WhatsNew:Show() end
    --if not minimapSettings.alpha then
    --   storeMinimap()
    --end
end)

local mainFrame = CreateFrame('Frame')
mainFrame:SetScript('OnEvent', function(self, event, ...)
    if event == 'CHAT_MSG_LOOT' then
        local lootstring = ...
        local itemID = string.match(lootstring, "Hitem:(%d+):")
        local itemName = string.lower(string.match(lootstring, "%[(.+)%]"))
        
        -- Only process loot if we're in AWAITING_LOOT state
        if minimapAlertState == 'AWAITING_LOOT' then
            -- Set loot cooldown to prevent immediate re-detection
            lootCooldown = GetTime()
            
            -- Hard reset: Force complete minimap restoration and state reset
            restoreMinimap()
            resetStateVariables(true) -- Clear all variables including detection
            foundNode = false
            autoResume = false
            autoResumeLoot = ''
            mX = 9999
            mY = 9999
            forceFreshMinimap = true -- Force fresh minimap state on next scan
            
            -- Force a complete reset by going to DISABLED then WAITING
            switchState('DISABLED')
            -- Use a small delay to ensure the state transition completes
            C_Timer.After(0.1, function()
                if minimapAlertState == 'DISABLED' then
                    startSearching()
                end
            end)
        end
    elseif event == 'ADDON_LOADED' then
        local name = ...
        if name == 'Minimap_Alert' then
            if MinimapAlert_Data then
                minimapAlert.saveData = MinimapAlert_Data
                
                -- Store the old version before updating it
                local oldVersion = minimapAlert.saveData.addonVersion or 0

                -- Version update logic removed - settings are handled by validateSettings()

                if oldVersion < 14 then
                    --Lets just clear people their tracking lists
                    minimapAlert.saveData.trackingList = {}
                    minimapAlert.saveData.showWhatsNew = true
                end
                
                -- Fix idleScan default - it should be false, not true (only for users upgrading from v25 or earlier)
                if oldVersion < 26 then
                    minimapAlert.saveData.settings.idleScan = false
                end
            else
                minimapAlert.saveData = minimapAlert.defaultData
            end

            minimapAlert.saveData.addonVersion = addonVersion

            -- Validate and fix settings
            minimapAlert.validateSettings()

            -- Initialize minimap button (show by default unless hidden)
            if not minimapAlert.saveData.minimapButton or not minimapAlert.saveData.minimapButton.hideMinimapButton then
                -- Try to create button immediately
                createMinimapButton()
                
                -- If that failed, try again after a short delay to ensure libraries are loaded
                C_Timer.After(1, function()
                    if not minimapButton then
                        createMinimapButton()
                    end
                end)
            end

            mainFrame:UnregisterEvent('ADDON_LOADED')
        end
    elseif event == 'PLAYER_LOGOUT' then
        
        MinimapAlert_Data = minimapAlert.saveData
    elseif event == 'PLAYER_REGEN_DISABLED' then
        -- Entering combat - save current state and stop scanning
        if minimapAlertState ~= 'DISABLED' then
            preCombatScanning = true
            -- Special handling for gathering state
            if minimapAlertState == 'AWAITING_LOOT' then
                preCombatGathering = true
                -- print("Minimap Alert: Entered combat while gathering, will resume after combat")
            else
                preCombatGathering = false
                -- print("Minimap Alert: Entered combat, stopping scan and resetting minimap")
            end
            
            -- Force immediate minimap restoration before state change
            -- This ensures the minimap is restored even if it's in a "flickered off" state
            restoreMinimap()
            switchState('DISABLED')
        end
    elseif event == 'PLAYER_REGEN_ENABLED' then
        -- Leaving combat - restore scanning if it was active before combat
        if preCombatScanning then
            -- print("Minimap Alert: Left combat, resuming scanning")
            startSearching()
            preCombatScanning = false
        else
            -- print("Minimap Alert: Left combat, minimap restored")
        end
    end
end)
mainFrame:RegisterEvent('ADDON_LOADED')
mainFrame:RegisterEvent('PLAYER_LOGOUT')
mainFrame:RegisterEvent('PLAYER_REGEN_DISABLED') -- Entering combat
mainFrame:RegisterEvent('PLAYER_REGEN_ENABLED')  -- Leaving combat

local function prepareMinimap()
    Minimap:SetAlpha(0)
    Minimap:SetScale(0.15)
    MinimapCluster:SetFrameLevel(9002)
    MinimapCluster:SetFrameStrata("HIGH")


    --[[
    t = {MinimapBackdrop:GetChildren()}
    MinimapBackdrop.visibleChildren = {}
    for k,v in pairs(t) do if v:IsVisible() then table.insert(MinimapBackdrop.visibleChildren, v) v:Hide() end end
    --]]

    if minimapSettings.MiniMapTrackingVisible then MiniMapTracking:Hide() end
    if minimapSettings.MiniMapMailFrameVisible then MiniMapMailFrame:Hide() end

    --Minimap.PingLocation = function() end
    Minimap:SetMouseClickEnabled(false)
    MinimapCluster:SetMouseClickEnabled(false)
    clickFrame:Show()
end

local function setMinimapLoc(xOffset, yOffset)
    prepareMinimap()
    local xOffset = xOffset or 0
    local yOffset = yOffset or 0
    local x,y = GetCursorPosition()
    local uiScale = Minimap:GetEffectiveScale()
    Minimap:ClearAllPoints()
    Minimap:SetPoint('CENTER', nil, 'BOTTOMLEFT', xOffset + x/uiScale, yOffset + y/uiScale)
    GameTooltip:SetScale(300)
end

local function isMatch()
    for i = 1, GameTooltip:NumLines() do
        local line = string.lower(_G['GameTooltipTextLeft'..i]:GetText())
        if line then
            for _, node in pairs(minimapAlert.saveData.trackingList) do
                local nodeName = node.nodeName
                --for w in string.gmatch(nodeName, "%S+") do
                for w in string.gmatch(nodeName, ".+") do
                    if string.find(line, string.lower(w), 1, true) then
                        statusText:SetText('[|cff00ff00'..nodeName..'|r]')
                        if node.autoResume then autoResume = true autoResumeLoot = node.lootName else autoResume = false end
                        return true               
                    end
                end
            end 
        end
    end
    return false
end

local function is_dragon_riding()
    if C_PlayerInfo.GetGlidingInfo then
        local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        return canGlide
    else
        return false
    end
end

local function get_player_speed()
    -- Check normal movement speed first
    local normalSpeed = GetUnitSpeed('player')
    if normalSpeed > 0 then
        return normalSpeed
    end
    
    -- Check dragon riding speed
    if C_PlayerInfo.GetGlidingInfo then
        local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        if canGlide and forwardSpeed and forwardSpeed > 0 then
            return forwardSpeed
        end
    end
    
    return 0
end

-- State change tracking for debugging
local lastStateChange = GetTime()

local function nodeUpdate(self, elapsed)
    local currentTime = GetTime()
    
    -- State timeout mechanism removed - scanning should only stop when manually stopped
    
    -- Don't scan while in combat
    if InCombatLockdown() then
        if minimapAlertState ~= 'DISABLED' then
            -- print("Minimap Alert: Entered combat, stopping scan and resetting minimap")
            switchState('DISABLED')
        end
        return
    end
    
    -- Don't scan during mouselook - tooltips are disabled
    if IsMouseButtonDown(2) or IsMouselooking() then
        -- Restore minimap to normal state during mouselook to prevent it getting stuck
        if minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW' then
            restoreMinimap()
        end
        return
    end
    
    
    -- Don't scan during loot cooldown to prevent double detection
    -- Two seconds seems like a good balance between preventing double detection and not being too restrictive
    -- this could be something where the minimap itself takes time to update and we don't want to detect it twice
    if currentTime - lootCooldown < 2 then
        return
    end
    
    if minimapAlertState == 'WAITING' then
        timeElapsed = timeElapsed + elapsed
        -- Only transition to scanning if moving or idleScan is enabled
        if timeElapsed >= minimapAlert.saveData.settings.intervalWhileMoving/10 then
            local speed = get_player_speed()
            local idleScanEnabled = minimapAlert.saveData.settings.idleScan
            if speed > 0 or idleScanEnabled then
                switchState('REPOSITION_MINIMAP')
            end
        end
    elseif minimapAlertState == 'REPOSITION_MINIMAP' then
        -- Use different scan types based on movement
        if get_player_speed() > 0 then
            -- Moving - use fast frame-based scan
            switchState('TOOLTIP_CHECK')
        else
            -- Idle - use slower time-based scan to allow minimap to update
            -- But only if we're not in the loot cooldown period to prevent double detection
            if currentTime - lootCooldown > 2 then
                switchState('TOOLTIP_CHECK_SLOW')
            else
                -- If in loot cooldown, go back to waiting to prevent double detection
                switchState('WAITING')
            end
        end
    elseif minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW' then
        local x, y = GetCursorPosition()

        -- Normal cursor movement logic
        if x == mX and y == mY then
            setMinimapLoc(math.random(-2, 2), math.random(-2, 2))
            mX = 9999
            mY = 9999
        else    
            setMinimapLoc()
            mX = x
            mY = y
        end
        

        if isMatch() then
            if minimapAlert.saveData.settings.flashScreen then fullscreenGlow.Anim:Play() end
            if minimapAlert.saveData.settings.flashTaskbar then FlashClientIcon() end
            if minimapAlert.saveData.settings.playSound then PlaySound(8959, "Master") end
            guiFrame.glowAnimation:Play()
            foundNode = true
            switchState('RESET_STATE')
        else       
            if minimapAlertState == 'TOOLTIP_CHECK' then
                -- Fast scan - use frame-based timing
                framesElapsed = framesElapsed + 1
                if framesElapsed >= 3 then
                    switchState('RESET_STATE')
                end
            else
                -- Slow scan - use time-based timing to allow minimap to update
                -- Use faster timing for idle scan to be more responsive
                timeElapsed = timeElapsed + elapsed
                if timeElapsed >= minimapAlert.saveData.settings.intervalWhileMoving/8 then
                    switchState('RESET_STATE')
                end
            end
        end
    elseif minimapAlertState == 'WAITING_AFTER_LOOT' then
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 1 then
            switchState('WAITING')
        end
    end
end

--[[
Minimap:HookScript('OnMouseDown', function(self, m)
    if (minimapAlertState == 'TOOLTIP_CHECK' or minimapAlertState == 'TOOLTIP_CHECK_SLOW') then
        if m == 'RightButton' then       
            MouselookStart()    
        elseif m == 'LeftButton' then
            extraDelay = 0.5
        end
        switchState('RESET_STATE')
    end
end)
--]]



function startSearching()
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage('Minimap Alert: Cannot start scanning while in combat!')
        return
    end
    
    if #minimapAlert.saveData.trackingList > 0 then
        switchState('WAITING')
        mainFrame:SetScript('OnUpdate', nodeUpdate)
        startButton:SetText('Stop')
        oldZoom = Minimap:GetZoom()
        Minimap:SetZoom(0)
    else
        DEFAULT_CHAT_FRAME:AddMessage('Minimap Alert: Add atleast 1 thing to track before starting!')
    end
end

local function stopSearching()
    -- First restore minimap to normal state before switching to DISABLED
    restoreMinimap()
    
    -- Force a complete minimap restoration to ensure it's back to original state
    if minimapSettings.alpha then
        Minimap:SetAlpha(minimapSettings.alpha)
        Minimap:SetScale(minimapSettings.scale)
        Minimap:ClearAllPoints()
        Minimap:SetPoint(minimapSettings.point, minimapSettings.relativeTo, minimapSettings.relativePoint, minimapSettings.x, minimapSettings.y)
        MinimapCluster:SetFrameLevel(minimapSettings.frameLevel)
        MinimapCluster:SetFrameStrata(minimapSettings.frameStrata)
        GameTooltip:SetScale(minimapSettings.GameTooltipScale)
        Minimap:SetMouseClickEnabled(true)
        MinimapCluster:SetMouseClickEnabled(true)
        clickFrame:Hide()
    end
    
    -- Then switch to disabled state
    switchState('DISABLED')
    mainFrame:SetScript('OnUpdate', nil)
    preCombatScanning = false -- Clear pre-combat scanning when manually stopped
    preCombatGathering = false -- Clear pre-combat gathering when manually stopped
    --Minimap:SetZoom(oldZoom)
end

local function startStopSearching()
    if minimapAlertState == 'DISABLED' or minimapAlertState == 'IDLE' then
        startSearching()
        setGUIFrameScanningMode()
    elseif minimapAlertState == 'AWAITING_LOOT' then
        -- Resume scanning when waiting for loot - do a proper reset first
        stopSearching()
        startSearching()
        setGUIFrameScanningMode()
    else
        minimapAlertState = 'DISABLED'
        stopSearching()
        setGUIFrameNormalMode()
    end
end



startButton:SetScript('OnClick', startStopSearching)
tabFrame.closeButton:SetScript('OnClick', function()
    stopSearching()
    guiFrame:Hide()
end)

-- Minimap Button Creation
local minimapButton = nil
function createMinimapButton()
    -- Prevent duplicate button creation
    if minimapButton then
        return
    end
    
    -- Create LibDataBroker object using embedded libraries
    local success, dataObj = safeExecute(function()
        return LibStub("LibDataBroker-1.1"):NewDataObject("MinimapAlert", {
            type = "launcher",
            icon = "Interface\\Icons\\INV_Misc_Spyglass_01",
            OnClick = function(self, button)
                -- LibDBIcon OnClick passes (self, button) parameters
                handleMinimapButtonClick(button)
            end,
            OnTooltipShow = function(tooltip)
                setupMinimapButtonTooltip(tooltip)
            end,
        })
    end, "Failed to create LibDataBroker object")
    
    if success and dataObj then
        -- Register with LibDBIcon
        local success2 = safeExecute(function()
            -- Ensure minimapButton settings exist
            if not minimapAlert.saveData.minimapButton then
                minimapAlert.saveData.minimapButton = {}
            end
            LibStub("LibDBIcon-1.0"):Register("MinimapAlert", dataObj, minimapAlert.saveData.minimapButton)
        end, "Failed to register LibDBIcon button")
        
        if success2 then
            minimapButton = LibStub("LibDBIcon-1.0")
        end
    end
end

-- Function to show minimap button
function showMinimapButton()
    -- First hide any existing button
    hideMinimapButton()
    -- Then create/show the button
    createMinimapButton()
    
    -- Also show LibDBIcon if it exists
    if LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        local LibDBIcon = LibStub("LibDBIcon-1.0")
        LibDBIcon:Show("MinimapAlert")
    end
end

-- Function to hide minimap button
function hideMinimapButton()
    local minimapButton = _G["MinimapAlert_MinimapButton"]
    if minimapButton then
        minimapButton:Hide()
    end
    -- Also hide LibDBIcon if it exists
    if LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        local LibDBIcon = LibStub("LibDBIcon-1.0")
        LibDBIcon:Hide("MinimapAlert")
    end
end

SLASH_MINIMAPALERT1 = '/minimapalert'
SlashCmdList["MINIMAPALERT"] = function(message)
    local guiFrame = _G["MinimapAlert_Interface"]
    if guiFrame then
        if guiFrame:IsVisible() then
            guiFrame:Hide()
        else
            guiFrame:Show()
        end
    end
end

stateList = {
    ['DISABLED'] = function()
        storeMinimap()
        restoreMinimap()
        mainFrame:UnregisterEvent('CHAT_MSG_LOOT')
        lootText:Hide()
        stopSpinner()  
        statusText:SetText('Inactive')
        startButton:SetText('Start')
    end,
    ['WAITING'] = function()
        resetStateVariables(true) -- Clear all variables including detection
        if extraDelay ~= 0 then timeElapsed = -extraDelay extraDelay = 0 end
        mainFrame:UnregisterEvent('CHAT_MSG_LOOT')
        lootText:Hide()
        startButton:SetText('Stop')
        startSpinner()
        statusText:SetText('Scanning...')
        
        -- Store minimap state immediately when scanning starts
        -- This ensures we always have the original state to restore to
        if not minimapSettings.alpha then
            storeMinimap()
        end
    end,
    ['WAITING_AFTER_LOOT'] = function()
        resetStateVariables(true) -- Clear all variables including detection
        -- Reset minimap to original state (same as combat reset)
        restoreMinimap()
    end,
    ['REPOSITION_MINIMAP'] = function()
        -- Force fresh minimap state if needed (after loot)
        if forceFreshMinimap then
            restoreMinimap()
            forceFreshMinimap = false
        end
        
        resetStateVariables(false) -- Clear timing variables only
        startButton:SetText('Stop')
    end,
    ['RESET_STATE'] = function() 
        restoreMinimap()
        
        if foundNode then
            if autoResume then
                switchState('AWAITING_LOOT')
            else
                switchState('IDLE')
            end
        else
            switchState('WAITING')
        end    
    end,
    ['AWAITING_LOOT'] = function() 
        -- Check if we're in combat - if so, don't auto-resume
        if InCombatLockdown() then
            -- print("Minimap Alert: Still in combat, waiting to resume...")
            return
        end
        
        -- Check if we were gathering when combat started
        if preCombatGathering then
            -- print("Minimap Alert: Gathering completed, resuming scanning after combat")
            preCombatGathering = false
            foundNode = false -- Clear detection state when resuming after combat
            switchState('IDLE')
            return
        end
        
        -- Normal auto-resume logic
        mainFrame:RegisterEvent('CHAT_MSG_LOOT')
        lootText:SetText('Waiting for loot')
        lootText:Show()
        startButton:SetText('Resume')
        pauseSpinner()
    end,
    ['TOOLTIP_CHECK'] = function() 
        setMinimapLoc() 
        startButton:SetText('Stop')
    end,
    ['TOOLTIP_CHECK_SLOW'] = function() 
        -- Force fresh minimap positioning for idle scan to prevent stale state
        restoreMinimap()
        setMinimapLoc() 
        startButton:SetText('Stop')
    end,
    ['IDLE'] = function() lootText:SetText('Found match') startButton:SetText("Start") lootText:Show() stopSpinner() mainFrame:SetScript('OnUpdate', nil) end
}

guiFrame:Hide()