local frame = CreateFrame('Frame', "MinimapAlert_WhatsNew", UIParent, backdropStuff)
frame:SetSize(320, 320)
frame:ClearAllPoints()
frame:SetPoint("CENTER")

frame:SetBackdrop({
      bgFile = 'Interface/FrameGeneral/UI-Background-Rock',
      edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
      tile = true, tileSize = 192, edgeSize = 16,
      insets = {left = 4, right = 4, top = 4, bottom = 4}})
frame:Hide()

local button_accept = CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
button_accept:SetSize(78, 24)
button_accept:ClearAllPoints()
button_accept:SetPoint('BOTTOM', 0, 8)
button_accept:SetText(ACCEPT)

button_accept:SetScript("OnClick", function() 
      --store flag that we saw whatsnew
      frame:Hide()
end)

local header = frame:CreateFontString()
header:SetFontObject("GameFontNormalLarge")
header:SetTextColor(1, 1, 1, 1)
header:SetPoint("TOP", 0, -16)


local whatsnew = frame:CreateFontString()
whatsnew:SetFontObject("GameFontNormal")
whatsnew:SetText("What's new?")
whatsnew:SetJustifyH("CENTER")
whatsnew:SetJustifyV("TOP")
whatsnew:ClearAllPoints()
whatsnew:SetPoint("TOP", header, "BOTTOM", 0, -8)

local text = frame:CreateFontString()
text:SetFontObject("GameFontNormal")
text:SetTextColor(1, 1, 1)
text:SetText("|cFFFF0000- Tracking list has been reworked, you can now set auto resume per item and specify loot if wanted. You will have to re-add your items!|r\n\n- Alert sound is now played on Master channel so you always hear it\n\n- Fixed various lua errors\n\n- Fixed accidentally pinging minimap\n\n- Thank you for your comments on curse, I do read them!")
text:SetJustifyH("LEFT")
text:SetSize(300, 240)
text:SetPoint("TOP", header, "BOTTOM", 0, -8)

frame:SetScript("OnShow", function(self) 
      header:SetText("Minimap Alert "..minimapAlert.saveData.addonVersion)
      minimapAlert.saveData.showWhatsNew = false
end)
