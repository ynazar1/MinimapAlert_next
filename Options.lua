--[[
    Create a checkbox with text label
    @param text: Display text for the checkbox
    @param parent: Parent frame to attach to
    @return: Checkbox frame
--]]
local function createCheckButton(text, parent)
    local frame = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
    frame:SetSize(26, 26)
    
    frame.text = frame:CreateFontString()
    frame.text:SetFontObject('GameFontNormal')
    frame.text:SetText(text)
    frame.text:SetTextColor(1, 1, 1)
    frame.text:SetPoint('LEFT', frame, 'RIGHT', 4, 0)

    return frame    
end

--[[
    Create multiple checkboxes from a configuration array
    @param configArray: Array of {text, param} pairs
    @param parent: Parent frame to attach to
    @param startY: Y offset for first checkbox
    @param settingsTable: Settings table to read/write values
    @param clickHandler: Optional custom click handler function
    @return: Array of created checkbox frames
--]]
local function createCheckboxGroup(configArray, parent, startY, settingsTable, clickHandler)
    local checkButtons = {}
    for i = 1, #configArray do
        local checkButton = createCheckButton(configArray[i][1], parent)
        if i == 1 then
            checkButton:SetPoint('TOPLEFT', startY, 'BOTTOMLEFT', 0, -20)
        else
            checkButton:SetPoint('TOPLEFT', checkButtons[i-1], 'BOTTOMLEFT', 0, -4)
        end
        
        local param = configArray[i][2]
        
        -- Initialize checkbox with current value from settings
        checkButton:SetChecked(settingsTable[param] or false)
        
        checkButton:SetScript('OnClick', function()
            if clickHandler then
                clickHandler(checkButton, param, settingsTable)
            else
                -- Default click handler - always use current MinimapAlert_Data.settings
                local currentSettings = MinimapAlert_Data and MinimapAlert_Data.settings
                if not currentSettings then
                    -- Fallback to settingsTable if MinimapAlert_Data.settings doesn't exist
                    currentSettings = settingsTable
                end
                
                currentSettings[param] = not currentSettings[param]
                checkButton:SetChecked(currentSettings[param])
                
            end
            
            -- Save to MinimapAlert_Data as well for persistence
            if minimapAlert.saveData then
                MinimapAlert_Data = minimapAlert.saveData
            else
                -- If minimapAlert.saveData doesn't exist yet, ensure MinimapAlert_Data is properly initialized
                if not MinimapAlert_Data then
                    MinimapAlert_Data = {}
                end
                if not MinimapAlert_Data.settings then
                    MinimapAlert_Data.settings = {}
                end
            end
        end)
        
        checkButtons[i] = checkButton
    end
    return checkButtons
end

-- Create options frame with compatibility for different WoW versions
local parentFrame = InterfaceOptionsFramePanelContainer or UIParent
local optionsFrame = CreateFrame('Frame', 'MinimapAlert_OptionsFrame', parentFrame)
optionsFrame.name = 'Minimap Alert'

local titleText = optionsFrame:CreateFontString()
titleText:SetPoint('TOPLEFT', 16, -16)
titleText:SetFontObject('GameFontNormalLarge')
titleText:SetText('Minimap Alert')

local subText = optionsFrame:CreateFontString()
subText:SetFontObject('GameFontHighlightSmall')
subText:SetText('Options for Minimap Alert, this scans while moving or while stopped if idleScan is enabled\n \
                Addon is automatically disabled during combat. ')
subText:SetPoint('TOPLEFT', titleText, 'BOTTOMLEFT', 0, -8)


-- Main addon settings
local mainSettings = {
    {'Flash World of Warcraft in the taskbar when a match is found', 'flashTaskbar'},
    {'Play a sound when a match is found', 'playSound'},
    {'Flash screen when a match is found', 'flashScreen'},
    {'Also search for a match while not moving (slower)', 'idleScan'}
}

-- Minimap button settings
local minimapButtonSettings = {
    {'Hide minimap button', 'hideMinimapButton'}
}

-- Custom click handler for minimap button settings
local function handleMinimapButtonClick(checkButton, param, settingsTable)
    settingsTable[param] = not settingsTable[param]
    checkButton:SetChecked(settingsTable[param])
    
    -- Handle show/hide minimap button (reversed logic)
    if param == 'hideMinimapButton' then
        if settingsTable[param] then
            hideMinimapButton()
        else
            showMinimapButton()
        end
    end
end

-- Ensure MinimapAlert_Data and settings table exist
if not MinimapAlert_Data then
    MinimapAlert_Data = minimapAlert.defaultData or {}
end
if not MinimapAlert_Data.settings then
    MinimapAlert_Data.settings = minimapAlert.defaultData.settings or {}
end

-- Create main settings checkboxes - always use MinimapAlert_Data.settings directly
local checkButtons = createCheckboxGroup(mainSettings, optionsFrame, subText, MinimapAlert_Data.settings)

-- Create minimap button checkboxes with custom handler - always use MinimapAlert_Data directly
if not MinimapAlert_Data.minimapButton then
    MinimapAlert_Data.minimapButton = {}
end
local minimapButtonCheckButtons = createCheckboxGroup(
    minimapButtonSettings, 
    optionsFrame, 
    checkButtons[#checkButtons], 
    MinimapAlert_Data.minimapButton,
    handleMinimapButtonClick
)

-- Add Reset Search Frame Position button
local resetFrameButton = CreateFrame('Button', nil, optionsFrame, 'GameMenuButtonTemplate')
resetFrameButton:SetSize(140, 24)
resetFrameButton:SetPoint('TOPLEFT', minimapButtonCheckButtons[#minimapButtonCheckButtons], 'BOTTOMLEFT', 0, -8)
resetFrameButton:SetText('Reset Frame Position')
resetFrameButton:SetScript('OnClick', function()
    local guiFrame = _G["MinimapAlert_Interface"]
    if guiFrame then
        guiFrame:ClearAllPoints()
        guiFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    end
end)

StaticPopupDialogs["MinimapAlert_AddCustomName"] = {
  text = "Enter the name or a part of it of the node you want to track.",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 26,
  OnAccept = function(self, ...)
    local text = self.editBox:GetText();
    optionsFrame.listFrame.addEntry(text)
    self:Hide()
  end,
  EditBoxOnEnterPressed = function(self)
    local text = self:GetParent().editBox:GetText();
    optionsFrame.listFrame.addEntry(text)
    self:GetParent():Hide()
  end,
  OnShow = function(self)
    self.editBox:SetText("");
    self.editBox:SetFocus();
  end,
  timeout = 0,
  exclusive = true,
  whileDead = true,
};

local addButton = CreateFrame('Button', 'MinimapAlert_AddItemButton', optionsFrame, 'GameMenuButtonTemplate')
addButton:SetSize(100, 24) --128, 32
-- Position will be set by TrackingList.lua when it loads

addButton:SetText('Add Item')
addButton:SetScript('OnClick', function() 
--StaticPopup_Show("MinimapAlert_AddCustomName") old add node dialog
MinimapAlert_AddNode:Show()
end)

--[[
clearButton = CreateFrame('Button', nil, addButton, 'GameMenuButtonTemplate')
clearButton:SetSize(100, 24) --128, 32
clearButton:SetPoint('TOP', addButton, 'BOTTOM', 0, -8)
clearButton:SetText('Clear List')
clearButton:SetScript('OnClick', function() minimapAlert.saveData.trackingList = {} optionsFrame.listFrame.refreshList() end)
--]]


local subText = optionsFrame:CreateFontString()
subText:SetFontObject('GameFontHighlightSmall')
subText:SetText('Search interval ~0.5s is recommended if using idle scan\nFaster means faster response but more minimap flickering.')
subText:SetPoint('TOPLEFT', resetFrameButton, 'BOTTOMLEFT', 8, -16)


local MySlider = CreateFrame("Slider", "MinimapAlert_Slider", optionsFrame, "OptionsSliderTemplate")
MySlider:SetWidth(100)
MySlider:SetHeight(16)
MySlider:SetPoint("CENTER", subText, "BOTTOM", 0, -32)
MySlider:SetMinMaxValues(1, 10)
MySlider:SetValueStep(1)
MySlider:SetOrientation('HORIZONTAL')
MySlider:SetObeyStepOnDrag(true)

--MySlider.tooltipText = 'This is the Tooltip hint' --Creates a tooltip on mouseover.
 MinimapAlert_SliderLow:SetText('0.1'); --Sets the left-side slider text (default is "Low").
 MinimapAlert_SliderHigh:SetText('1.0'); --Sets the right-side slider text (default is "High").
 MinimapAlert_SliderText:SetText('0.5'); --Sets the "title" text (top-centre of slider).


MySlider:SetScript("OnValueChanged", function(self, value)
  minimapAlert.saveData.settings.intervalWhileMoving = value
  MinimapAlert_SliderText:SetText(value/10)

end)

 MySlider:Show()

optionsFrame:SetScript('OnShow', function(self)
    -- Ensure MinimapAlert_Data.settings exists
    if not MinimapAlert_Data then
        MinimapAlert_Data = {}
    end
    if not MinimapAlert_Data.settings then
        MinimapAlert_Data.settings = minimapAlert.defaultData.settings or {}
    end
    
    -- Only refresh checkboxes if they don't match the saved values
    for i = 1, #mainSettings do
        local param = mainSettings[i][2]
        local savedValue = MinimapAlert_Data.settings[param]
        local currentValue = checkButtons[i]:GetChecked()
        
        -- Only update if the checkbox doesn't match the saved value
        if currentValue ~= (savedValue or false) then
            checkButtons[i]:SetChecked(savedValue or false)
        end
    end
    
    -- Ensure MinimapAlert_Data.minimapButton exists
    if not MinimapAlert_Data.minimapButton then
        MinimapAlert_Data.minimapButton = {}
    end
    
    -- Only refresh minimap button checkboxes if they don't match the saved values
    for i = 1, #minimapButtonSettings do
        local param = minimapButtonSettings[i][2]
        local savedValue = MinimapAlert_Data.minimapButton[param] or false
        local currentValue = minimapButtonCheckButtons[i]:GetChecked()
        
        -- Only update if the checkbox doesn't match the saved value
        if currentValue ~= savedValue then
            minimapButtonCheckButtons[i]:SetChecked(savedValue)
        end
    end
    
    --self.trackableFrame.refreshList() 
    self.listFrame.refreshList()

    MySlider:SetValue(MinimapAlert_Data.settings.intervalWhileMoving, true)
    MinimapAlert_AddNode:Hide()
end)

-- Register with appropriate API based on WoW version
if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    -- Retail: Use modern Settings API
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsFrame, optionsFrame.name, optionsFrame.name);
    Settings.RegisterAddOnCategory(category);
    -- Store the category object for use in OpenToCategory calls
    -- The category object has its own numeric ID that OpenToCategory expects
    optionsFrame.category = category
elseif InterfaceOptions_AddCategory then
    -- Classic/Mists/Cata: Use legacy InterfaceOptions API
    InterfaceOptions_AddCategory(optionsFrame)
end
