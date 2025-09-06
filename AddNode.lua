local function createCheckButton(text, parent)
   local frame = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
   frame:SetSize(26, 26)
   
   frame.text = frame:CreateFontString()
   frame.text:SetFontObject('GameFontNormal')
   frame.text:SetText(text)
   frame.text:SetTextColor(1, 1, 1, 1)
   frame.text:SetPoint('LEFT', frame, 'RIGHT', 4, 0)
   
   return frame    
end



local frame = CreateFrame('Frame', "MinimapAlert_AddNode", MinimapAlert_OptionsFrame, backdropStuff)
frame:SetSize(296, 140)
frame:ClearAllPoints()
frame:SetPoint("TOPLEFT", MinimapAlert_OptionsFrame, "BOTTOMLEFT", 32, 96+140)

frame:SetBackdrop({
      bgFile = 'Interface/FrameGeneral/UI-Background-Rock',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile = true, tileSize = 192, edgeSize = 16,
      insets = {left = 4, right = 4, top = 4, bottom = 4}})
frame:Hide()

local button_accept = CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
button_accept:SetSize(78, 24)
button_accept:ClearAllPoints()
button_accept:SetPoint('BOTTOMLEFT', 8, 8)
button_accept:SetText(ACCEPT)

local button_cancel = CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
button_cancel:SetSize(78, 24)
button_cancel:ClearAllPoints()
button_cancel:SetPoint('BOTTOMRIGHT', -8, 8)
button_cancel:SetText(CANCEL)
button_cancel:SetScript("OnClick", function(self)
   frame:Hide()
end)

local text1 = frame:CreateFontString()
text1:SetFontObject("GameFontNormal")
text1:SetText("Enter (part of) name as it appears on minimap.\nExample: |cFFFFFFFFthorium|r or |cFFFFFFFFwindy cloud|r")
text1:SetJustifyH("LEFT")
text1:ClearAllPoints()
text1:SetPoint('TOPLEFT', 12, -14)


local input1 = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
input1:SetPoint("TOPLEFT", text1, "BOTTOMLEFT", 4, -12)
input1:SetWidth(164)
input1:SetHeight(16)
input1:SetMovable(false)
--input1:SetAutoFocus(true)
input1:SetMultiLine(false)
input1:SetMaxLetters(16)

local text2 = frame:CreateFontString()
text2:SetFontObject("GameFontNormal")
text2:SetText("Enter (part of) looted item name.\nExample: |cFFFFFFFFore|r or |cFFFFFFFFmote of air|r\nLeave empty to resume on any loot.")
text2:SetJustifyH("LEFT")
text2:ClearAllPoints()
text2:SetPoint('TOPLEFT', text1, "BOTTOMLEFT", 0, -72)
text2:Hide()

local input2 = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
input2:SetPoint("TOPLEFT", text2, "BOTTOMLEFT", 4, -12)
input2:SetWidth(164)
input2:SetHeight(16)
input2:SetMovable(false)
--input2:SetAutoFocus(true)
input2:SetMultiLine(false)
input2:SetMaxLetters(16)
input2:Hide()


local check_autoresume = createCheckButton("Resume tracking after looting?", frame)
check_autoresume:ClearAllPoints()
check_autoresume:SetChecked(false)
check_autoresume:SetPoint("TOPLEFT", input1, "BOTTOMLEFT", -8, -8)
check_autoresume:SetScript("OnClick", function(self)
      if self:GetChecked() then
         frame:SetSize(296, 212)
         text2:Show()
         input2:Show()
      else
         frame:SetSize(296, 140)
         text2:Hide()
         input2:Hide()
      end
      
end)

frame:SetScript("OnShow", function(self)
   input1:SetText("")
   input2:SetText("")
         frame:SetSize(296, 140)
         text2:Hide()
         input2:Hide()
   check_autoresume:SetChecked(false)
end)

button_accept:SetScript("OnClick", function(self)
   if (input1:GetText() ~= "") then
      MinimapAlert_OptionsFrame.listFrame.addEntry({nodeName = input1:GetText(), lootName = input2:GetText(), autoResume = check_autoresume:GetChecked()})
   else
      print("Minimap Alert: Type the name of something you want to track!")
   end
   frame:Hide()
end)