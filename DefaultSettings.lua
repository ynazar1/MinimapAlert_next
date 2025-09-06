minimapAlert.defaultData = {}
minimapAlert.defaultData.trackingList = {}
minimapAlert.defaultData.cachedNames = {}
minimapAlert.defaultData.settings = {}
minimapAlert.defaultData.settings.flashScreen = true
minimapAlert.defaultData.settings.flashTaskbar = true
minimapAlert.defaultData.settings.autoResumeAfterLoot = true
minimapAlert.defaultData.settings.idleScan = false
minimapAlert.defaultData.settings.playSound = true
minimapAlert.defaultData.settings.intervalWhileMoving = 5
minimapAlert.defaultData.showWhatsNew = false
minimapAlert.defaultData.minimapButton = {}
minimapAlert.defaultData.minimapButton.show = true
minimapAlert.defaultData.minimapButton.angle = 0
minimapAlert.defaultData.minimapButton.hideMinimapButton = false

-- Settings validation function
function minimapAlert.validateSettings()
    if not minimapAlert.saveData then
        minimapAlert.saveData = minimapAlert.defaultData
        return
    end
    
    -- Validate minimap button settings
    if not minimapAlert.saveData.minimapButton then
        minimapAlert.saveData.minimapButton = {}
    end
    
    -- Ensure required fields exist
    if type(minimapAlert.saveData.minimapButton.hideMinimapButton) ~= "boolean" then
        minimapAlert.saveData.minimapButton.hideMinimapButton = false
    end
    
    if type(minimapAlert.saveData.minimapButton.angle) ~= "number" then
        minimapAlert.saveData.minimapButton.angle = 0
    end
    
    -- Validate angle range
    if minimapAlert.saveData.minimapButton.angle < 0 or minimapAlert.saveData.minimapButton.angle > 2 * math.pi then
        minimapAlert.saveData.minimapButton.angle = 0
    end
    
    -- Validate other settings
    if not minimapAlert.saveData.settings then
        minimapAlert.saveData.settings = minimapAlert.defaultData.settings
    end
    
    for key, defaultValue in pairs(minimapAlert.defaultData.settings) do
        if minimapAlert.saveData.settings[key] == nil then
            minimapAlert.saveData.settings[key] = defaultValue
        end
    end
    
    -- No special validation needed - all settings are handled by the loop above
end
