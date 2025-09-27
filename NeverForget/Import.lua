  -- Initialize delete list confirm popup
StaticPopupDialogs["NEVERFORGET_IMPORT_CHECKLIST"] = {
  text = "Paste an import string for\n|cFFFFFF00%s|r",
  button1 = "Import",
  button2 = "Cancel",
  OnAccept = function(self, data)
    local import_string = self.editBox:GetText()
    NeverForget_ImportChecklistString(data, import_string)
  end,
  timeout = 0,
  hasEditBox = true,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

  -- Initialize delete list confirm popup
StaticPopupDialogs["NEVERFORGET_SHOW_IMPORT_STRING"] = {
  text = "Showing import string for\n|cFFFFFF00%s|r",
  button1 = "Ok",
  --button2 = "Cancel",
  timeout = 0,
  hasEditBox = true,
  whileDead = true,
  enterClicksFirstButton = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

-- Shows the import string frame. TODO: The name of this frame is ambiguous
-- with the other frame that shows the current import string.
function NeverForget_OpenImportFrame(checklistIndex)
  local dialog = StaticPopup_Show("NEVERFORGET_IMPORT_CHECKLIST", NeverForget_API_GetChecklistName(checklistIndex))
  if (dialog) then
    dialog.data = checklistIndex
  end
end

  -- Shows the frame with the current import string.
local show_import_string_frame = nil
function NeverForget_OpenShowImportStringWindow(checklistIndex)
  local dialog = StaticPopup_Show("NEVERFORGET_SHOW_IMPORT_STRING", NeverForget_API_GetChecklistName(checklistIndex))
  if (dialog) then
    dialog.editBox:SetText(NeverForget_GetImportString(checklistIndex))
  end
end
