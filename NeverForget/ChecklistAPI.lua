
local function GetChecklists()
  return NeverForget_DB.checklists
end

local function GetChecklist(checklistIndex)
  return NeverForget_DB.checklists[checklistIndex]
end

local on_change_callback = nil
local function CallOnChangeCallback()
  on_change_callback()
end

local function CreateChecklist(name)
  local new_index = #NeverForget_DB.checklists + 1

  local checklist = {}
  checklist.name = name
  checklist.item_list = {}
  checklist.include_bank = false
  checklist.visible = true

  NeverForget_DB.checklists[new_index] = checklist

  CallOnChangeCallback()
end

local function RenameChecklist(checklistIndex, new_name)
  local checklist = GetChecklist(checklistIndex)

  checklist.name = new_name

  CallOnChangeCallback()
end

local function DeleteChecklist(checklistIndex)
  local checklists = GetChecklists()

  -- Cannot delete a checklist if there is only one left.
  if (#checklists == 1) then
    ShowError("Cannot delete the last checklist.")
    return
  end

  table.remove(checklists, checklistIndex)

  CallOnChangeCallback()
end

--------------------------------------------------------------------------------

--[[
NeverForget_API_SetOnChangeCallback
NeverForget_API_Initialize

NeverForget_API_CreateChecklist
NeverForget_API_DeleteChecklist
NeverForget_API_SwitchChecklist
NeverForget_API_GetChecklists()

-- Affecting current checklist

NeverForget_API_GetChecklistName
NeverForget_API_RenameChecklist

NeverForget_API_IsItemListEmpty
NeverForget_API_GetItemList
NeverForget_API_ClearItemList

NeverForget_API_AddItemToChecklist
NeverForget_API_RemoveItemFromChecklist

NeverForget_API_ValidateItemId
NeverForget_API_ValidateItemCount

NeverForget_ImportChecklistString
NeverForget_GetImportString
]]

function NeverForget_API_IsChecklistVisible(checklistIndex)
  return NeverForget_DB.checklists[checklistIndex].visible
end

function NeverForget_API_ToggleChecklistVisibility(checklistIndex)
  local checklist =  NeverForget_DB.checklists[checklistIndex]

  checklist.visible = not checklist.visible

  CallOnChangeCallback()
end

function NeverForget_API_SetOnChangeCallback(callback)
  on_change_callback = callback
end

function NeverForget_API_IsHidden()
  if NeverForget_DB.hidden == nil then
    NeverForget_DB.hidden = false
  end
  return NeverForget_DB.hidden
end

function NeverForget_API_ToggleHidden()
  NeverForget_DB.hidden = not NeverForget_DB.hidden
end

function NeverForget_API_IsMinimized()
  return NeverForget_DB.minimized
end

function NeverForget_API_ToggleMinimized()
  NeverForget_DB.minimized = not NeverForget_DB.minimized
end

function NeverForget_API_Initialize()
  if not NeverForget_DB then
    NeverForget_DB = {}
    NeverForget_DB.version = 1

    NeverForget_DB.visible = true
    NeverForget_DB.minimized = false
    NeverForget_DB.hidden = false
    NeverForget_DB.minimap_button_visible = true

    NeverForget_DB.checklists = {}

    -- There must always exists at least one  checklist.
    -- Not using CreateChecklist() to avoid calling CallOnChangeCallback()
    local new_index = #NeverForget_DB.checklists + 1

    local checklist = {}

    checklist.name = "Checklist"
    checklist.item_list = {}
    checklist.include_bank = false
    checklist.visible = true

    NeverForget_DB.checklists[new_index] = checklist
  end

    -- Initialize delete list confirm popup
  StaticPopupDialogs["NEVERFORGET_API_CONFIRM_DELETE"] = {
    text = "Are you sure you want to delete the list\n|cFFFFFF00%s|r?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        DeleteChecklist(data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }

    -- Initialize delete list confirm popup
  StaticPopupDialogs["NEVERFORGET_API_CONFIRM_RENAME"] = {
    text = "Please enter a new name for the list\n|cFFFFFF00%s|r",
    button1 = "Accept",
    button2 = "Cancel",
    OnAccept = function(self, data)
      local text = self.editBox:GetText()
      RenameChecklist(data, text)
    end,
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    enterClicksFirstButton = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }

    -- Initialize delete list confirm popup
  StaticPopupDialogs["NEVERFORGET_API_CONFIRM_NEWNAME"] = {
    text = "Please enter a name for the new list.",
    button1 = "Accept",
    button2 = "Cancel",
    OnAccept = function(self, data, data2)
      local text = self.editBox:GetText()
      CreateChecklist(text)
    end,
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    enterClicksFirstButton = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }
end

function NeverForget_API_RenameChecklist(checklistIndex)
  local dialog = StaticPopup_Show("NEVERFORGET_API_CONFIRM_RENAME", NeverForget_API_GetChecklistName(checklistIndex))
  if (dialog) then
    dialog.data = checklistIndex
  end
end

function NeverForget_API_CreateChecklist()
  StaticPopup_Show("NEVERFORGET_API_CONFIRM_NEWNAME")
end

function NeverForget_API_DeleteChecklist(checklistIndex)
  local dialog = StaticPopup_Show("NEVERFORGET_API_CONFIRM_DELETE", NeverForget_API_GetChecklistName(checklistIndex))
  if (dialog) then
    dialog.data = checklistIndex
  end
end

-- Given the |item_id|, returns the index and the value of this item in the
-- item list. Returns nil if the item is not present in the item list.
local function FindElementInItemList(item_list, item_id)
  for index, element in ipairs(item_list) do
    if (element.item_id == item_id) then
      return index, element
    end
  end
  return nil, nil
end

function NeverForget_API_ToggleIncludeBank(checklistIndex)
  local checklist = GetChecklist(checklistIndex)

  checklist.include_bank = not checklist.include_bank

  CallOnChangeCallback()
end

function NeverForget_API_IsBankIncluded(checklistIndex)
  local checklist = GetChecklist(checklistIndex)

  return checklist.include_bank
end

-- Adds an item and its count to the item list. If the item already exists in
-- the list, the count is overwritten with the new one. If the count is zero,
-- the item is removed from the list.
function AddItemToItemList(item_list, item_id, item_count)
  if item_count == 0 then
    ShowError("Item count must not be zero.")
    return
  end

  local index, element = FindElementInItemList(item_list, item_id)
  if element ~= nil then
    return
  end

  element = {}
  index = #item_list + 1
  item_list[index] = element

  element.item_id = item_id
  element.item_count = item_count

  -- Sort the list.
  table.sort(item_list, function(a, b) return a.item_id  < b.item_id end)
end

function ModifyItemCount(item_list, item_id, item_count)
  if item_count == 0 then
    ShowError("Item count must not be zero.")
    return
  end

  local index, element = FindElementInItemList(item_list, item_id)
  if element == nil then
    return
  end

  item_list[index].item_count = item_count
end

function NeverForget_API_GetItemList(checklistIndex)
  local checklist = GetChecklist(checklistIndex)

  return checklist.item_list
end

function NeverForget_API_SetItemList(checklistIndex, item_list)
  local checklist = GetChecklist(checklistIndex)

  checklist.item_list = item_list

  CallOnChangeCallback()
end

function RemoveItemFromItemList(item_list, item_index)
  table.remove(item_list, item_index)
end

-------------------------------------------------------------------------------

-- Parses |item_id_text| and returns a valid item ID. Returns nil on error.
function NeverForget_API_ValidateItemId(item_id_text)
  -- Check if the text is empty.
  if (item_id_text == "") then
    ShowError("Missing item ID")
    return nil
  end

  -- Check if the text can be converted to a number.
  local item_id = tonumber(item_id_text)
  if (item_id == nil ) then
    ShowError("Item ID is not a number")
    return nil
  end

  -- Check if an item exists with this ID.
  local item = Item:CreateFromItemID(item_id)
  if (item:IsItemEmpty()) then
    ShowError("Invalid item ID")
    return nil
  end

  -- Validation passed.
  return item_id
end

-- Parses |item_count_text| and returns a valid item count. Returns nil on
-- error.
function NeverForget_API_ValidateItemCount(item_count_text)
  -- Check if the text can be converted to a number.
  local item_count = tonumber(item_count_text)
  if (item_count == nil) then
    ShowError("Item count is not a number")
    return nil
  end

  -- Check if the item count returns either a positive number or is equal to
  -- zero.
  if (item_count < 0) then
    ShowError("Item count must be zero or higher")
    return nil
  end

  -- Validation passed.
  return item_count
end


-- TODO migrate
-- Resets and initializes the list from an import string. An import string is a
-- comma-separated list of item_id and count pairs.
-- Ex. 123:10,4398:5
function NeverForget_ImportChecklistString(checklistIndex, import_string)
  -- Reset the checklist.
  new_checklist = {}

  local index = 1
  while (import_string ~= nil and import_string ~= "") do
    -- Avoids freezing the UI if too many items are entered.
    if (index == 100) then
      ShowError("100 items limit exceeded.")
      return
    end

    local current_element, new_import_string = strsplit(",", import_string, 2)
    import_string = new_import_string

    local item_id_text, item_count_text = strsplit(":", current_element, 2)

    if (item_id_text == nil or item_count_text == nil) then
      ShowError("Error parsing import string")
      return
    end

    local item_id = NeverForget_API_ValidateItemId(item_id_text)
    if (item_id == nil) then
      return
    end

    local item_count = NeverForget_API_ValidateItemCount(item_count_text)
    if (item_count == nil) then
      return
    end

    index = index + 1

    AddItemToItemList(new_checklist, item_id, item_count)
  end

  local checklist = GetChecklist(checklistIndex)
  
  checklist.item_list = new_checklist

  CallOnChangeCallback()
end

function NeverForget_API_GetChecklistCount()
  return #GetChecklists()
end

-- TODO migrate
-- Returns the import string that matches the current configuration of the
-- checklist.
function NeverForget_GetImportString(checklistIndex)
  local checklist = GetChecklist(checklistIndex)

  local str = ""
  local is_first = true
  for index, element in ipairs(checklist.item_list) do
    if (not is_first) then
      str = str .. ","
    end
    str = str .. element.item_id .. ":" .. element.item_count
    is_first = false
  end
  return str
end

function NeverForget_API_GetChecklistName(checklistIndex)
  local checklist = GetChecklist(checklistIndex)

  return checklist.name
end

function NeverForget_API_SetMinimapButtonVisible()
  NeverForget_DB.minimap_button_visible = true
end

function NeverForget_API_SetMinimapButtonHidden()
  NeverForget_DB.minimap_button_visible = false
end

function NeverForget_API_IsMinimapButtonVisible()
  if NeverForget_DB.minimap_button_visible == nil then
    NeverForget_DB.minimap_button_visible = true
  end
  return NeverForget_DB.minimap_button_visible
end