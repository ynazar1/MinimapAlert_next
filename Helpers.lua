minimapAlert.f = {}

minimapAlert.f.createListFrame = function(title, headertext, subtext, parent)
    local frame = CreateFrame('Frame', nil, parent, backdropStuff)
    frame:SetSize(192, 248)
    --frame:SetPoint('BOTTOMRIGHT', -32, 48)
    frame:SetBackdrop({
          edgeFile='Interface/Tooltips/UI-Tooltip-Border', 
          bgFile='Interface/Tooltips/UI-Tooltip-Background', 
          tile = false, tileSize = 16, edgeSize = 16,
          insets = { left = 4, right = 4, top = 4, bottom = 4 }})
    frame:SetBackdropColor(0.15, 0.15, 0.15, 1)
    
    frame.offset = 0
    frame.refreshList = function() end
    
    frame.subText = frame:CreateFontString()
    frame.subText:SetFontObject('GameFontHighlightSmall')
    frame.subText:SetText(subtext)
    frame.subText:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 4, -4)
      
    frame.header = frame:CreateFontString()
    frame.header:SetFontObject('GameFontNormalLarge')
    frame.header:SetText(title)
    frame.header:SetPoint('BOTTOM', frame, 'TOP', 0, 4)

    frame.content = CreateFrame('Frame', nil, frame)
    frame.content:SetSize(frame:GetWidth(), frame:GetHeight()-10)
    frame.content:SetPoint('CENTER', 0, 0)

    frame.slider = CreateFrame('Slider', nil, frame, 'UIPanelScrollBarTemplate')
    frame.slider:SetPoint('TOPLEFT', frame, 'TOPRIGHT', -20, -20)
    frame.slider:SetPoint('BOTTOMLEFT', frame, 'BOTTOMRIGHT', 0, 20)
    frame.slider:SetMinMaxValues(0, 0)
    frame.slider.scrollStep = 1
    frame.slider:SetScript('OnValueChanged', function(self, value) 
        frame.offset = math.floor(value)
        frame.refreshList()
    end)
    frame.slider:SetValue(0)
    
    frame.setOffset = function(self, offset)
        self.slider:SetMinMaxValues(0, self.offset)
        --self.slider:SetValue(self.offset)
    end
    
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            frame.slider.ScrollUpButton:Click()
        else
            frame.slider.ScrollDownButton:Click()
        end
    end)

    frame.slider.background = frame.slider:CreateTexture(nil, 'BACKGROUND')
    frame.slider.background:SetColorTexture(0, 0, 0, 1)
    frame.slider.background:SetAllPoints()
    
    return frame
end