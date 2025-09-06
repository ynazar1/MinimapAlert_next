--[[
local optionsFrame = _G['MinimapAlert_OptionsFrame']
local entryPool = {}

local trackableFrame = minimapAlert.f.createListFrame('Trackables', 'Common names to track', 'Click to add to tracking list', optionsFrame)
trackableFrame:SetPoint('BOTTOMLEFT', 32, 48)

local categories = minimapAlert.trackables

local function createEntryFrame(parent)
   local trackingEntry = CreateFrame('Button', nil, parent)
   trackingEntry:SetSize(parent:GetWidth()-8-16, 20)
   --trackingEntry:SetPoint('TOP', 0, -4)
   
   trackingEntry.bg = trackingEntry:CreateTexture(nil, 'BACKGROUND')
   trackingEntry.bg:SetAllPoints()
   
   trackingEntry.icon = trackingEntry:CreateTexture(nil, 'ARTWORK')
   trackingEntry.icon:SetSize(14, 14)
   trackingEntry.icon:SetAlpha(0.8)
   trackingEntry.icon:SetPoint('LEFT', 4, 0)
   
   trackingEntry.hlicon = trackingEntry:CreateTexture(nil, 'OVERLAY')
   trackingEntry.hlicon:SetSize(14, 14)
   trackingEntry.hlicon:SetAlpha(1)
   trackingEntry.hlicon:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
   trackingEntry.hlicon:SetBlendMode('ADD')
   trackingEntry.hlicon:SetPoint('CENTER', trackingEntry.icon, 'CENTER', 0, 0)
   trackingEntry.hlicon:Hide()
   
   trackingEntry.text = trackingEntry:CreateFontString()
   trackingEntry.text:SetFontObject('GameFontNormal')
   trackingEntry.text:SetText('Peacebloom')
   trackingEntry.text:SetPoint('LEFT', trackingEntry.icon, 'RIGHT', 4, 0)
   
   trackingEntry.setSubLevel = function(self, subLevel)
      self.icon:ClearAllPoints()
      self.icon:SetPoint('LEFT', 4 + (subLevel*8), 0)
   end
   
   trackingEntry.updateType = function(self, type, expanded)
      self.expanded = expanded
      self.type = type
      if type == 'category' then
         if expanded then
            self.icon:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
         else
            self.icon:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
         end
         self.hlicon:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
         self.icon:SetSize(14, 14)
         self.hlicon:SetSize(14, 14)
      else
         self.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
         self.hlicon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
         self.icon:SetSize(12, 12)
         self.hlicon:SetSize(12, 12)
      end
   end
   
   trackingEntry:SetScript('OnEnter', function(self)  
         self.text:SetTextColor(1, 1, 1) 
         self.hlicon:Show()      
   end)
   trackingEntry:SetScript('OnLeave', function(self)  
         self.text:SetTextColor(0.99999779462814, 0.81960606575012, 0)
         self.hlicon:Hide()
   end)
   
   
   return trackingEntry
end

--showCategory moet dingen negeren als hij nog net boven de offset is
local function showCategory(cTable, subLevel, counter)
    subLevel = subLevel + 1
   
    for category = 1, #cTable do
        counter = counter + 1

        if counter > trackableFrame.offset and counter-trackableFrame.offset <= #entryPool then
            entryPool[counter-trackableFrame.offset]:setSubLevel(subLevel)
            entryPool[counter-trackableFrame.offset]:updateType(cTable[category].type, cTable[category].expanded)
            entryPool[counter-trackableFrame.offset]:Show()
        end
         
        if cTable[category].type == 'category' then
            if counter > trackableFrame.offset and counter-trackableFrame.offset <= #entryPool then
                entryPool[counter-trackableFrame.offset].text:SetText(cTable[category].name)
                
                if string.len(cTable[category].name) <= 20 then
                    entryPool[counter-trackableFrame.offset].text:SetFontObject('GameFontNormal')
                else
                    entryPool[counter-trackableFrame.offset].text:SetFontObject('GameFontNormalSmall')
                end
                
                entryPool[counter-trackableFrame.offset]:SetScript('OnClick', function()
                if cTable[category].expanded then
                    --trackableFrame:setOffset(trackableFrame.offset - #cTable[category].entries)
                    cTable[category].expanded = false 
                else
                    --trackableFrame:setOffset(trackableFrame.offset + #cTable[category].entries)
                    cTable[category].expanded = true  
                end
                trackableFrame.refreshList()
                end)
            end
            
            if cTable[category].expanded then
                subLevel, counter = showCategory(cTable[category].entries, subLevel, counter)
            end      
        else
            local name = minimapAlert.saveData.cachedNames[cTable[category].itemID]
            local succes = true            
            
            if not name then
                local itemName = GetItemInfo(cTable[category].itemID)
                if itemName then
                    minimapAlert.saveData.cachedNames[cTable[category].itemID] = itemName
                    name = itemName
                else
                    name = 'GetItemInfo Fail.'
                    succes = false
                end
            else
                --print('found cached '..name)
            end
            
            if counter > trackableFrame.offset and counter-trackableFrame.offset <= #entryPool then
                entryPool[counter-trackableFrame.offset].text:SetText(name)
                
                if string.len(name) <= 20 then
                    entryPool[counter-trackableFrame.offset].text:SetFontObject('GameFontNormal')
                else
                    entryPool[counter-trackableFrame.offset].text:SetFontObject('GameFontNormalSmall')
                end
                
                entryPool[counter-trackableFrame.offset]:SetScript('OnClick', function()
                    if succes then
                        optionsFrame.listFrame.addEntry(name)               
                    else
                        DEFAULT_CHAT_FRAME:AddMessage('Minimap Alert: Failed to retrieve localized item name, try opening and closing this window or add the name manually.')         
                    end
                end)
            end
        end
    end
    subLevel = subLevel - 1
    return subLevel, counter
end


trackableFrame.refreshList = function()
   local counter = 0
   local subLevel = -1
   
   subLevel, counter = showCategory(categories, subLevel, counter)

   if counter < #entryPool then
      for i = counter+1, #entryPool do
         entryPool[i]:Hide()
      end
   end
   
    if counter <= #entryPool then
        trackableFrame.slider:SetMinMaxValues(0, 0)
    else
        trackableFrame.slider:SetMinMaxValues(0, counter-#entryPool)
    end
    
    if trackableFrame.offset == 0 then
        trackableFrame.slider.ScrollUpButton:Disable()
    else
        trackableFrame.slider.ScrollUpButton:Enable()
    end

    local _,maxValue = trackableFrame.slider:GetMinMaxValues()
    if trackableFrame.offset < maxValue then
        trackableFrame.slider.ScrollDownButton:Enable()
    else
        trackableFrame.slider.ScrollDownButton:Disable()
    end
    
end

for i = 1, 12 do
  entryPool[i] = createEntryFrame(trackableFrame)
  
  if i > 1 then
     entryPool[i]:SetPoint('TOP', entryPool[i-1], 'BOTTOM')
  else
     entryPool[i]:SetPoint('TOPLEFT', 4, 0)
  end
  
  entryPool[i]:Hide()
end


optionsFrame.trackableFrame = trackableFrame
--]]