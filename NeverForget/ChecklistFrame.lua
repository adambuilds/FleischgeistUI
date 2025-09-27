-- The width of the addon. TODO: Make the addon resizeable.
local CHECKLIST_FRAME_WIDTH = 260

-- The vertical space that each items in the list takes.
local CHECKLIST_FRAME_ITEM_HEIGHT = 20

-- Creates the header title text. This is the name of the addon in the header_frame
-- frame.
local function CreateHeaderTitle(parent_frame)
  local header_title = parent_frame:CreateFontString(nil, "Artwork", "GameFontNormal")

  header_title:SetPoint("Left", 5, 0)
  header_title:SetTextColor(1, 1, 1, 1)
  header_title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  header_title:SetText("NeverForget")
  if NeverForget_API_IsMinimized() then
    header_title:SetText("NeverForget - Minimized")
  else
    header_title:SetText("NeverForget")
  end

  return header_title
end

local function CreateXButton(parent_frame)
  local x_button = NeverForget_CreateButton(parent_frame, "X", nil)

  SetDarkFrameBackdrop(x_button)

  x_button:SetSize(20, 20)
  x_button:Hide()

  return x_button
end

-- Creates the container frame. The container frame is the one that displays the
-- checklist items and that can be minimized.
local function CreateContainerFrame(parent_frame)
  local container_frame = CreateFrame("Frame", nil, parent_frame, BackdropTemplateMixin and "BackdropTemplate")

  function container_frame:Initialize()
    self:SetWidth(CHECKLIST_FRAME_WIDTH)
    -- container_frame:SetPoint("Bottom")
    self.assigned_font_strings = {}
    self.available_font_strings = {}

    -- TODO FIX
    -- Initial state of minimized, which depends on saved variables.
    if NeverForget_API_IsMinimized() then
      self:Hide()
    else
      self:Show()
    end

    self:SetPoint("Top", 0, -parent_frame:GetHeight())  -- Minus header height.
    SetFrameBackdrop(self)
  end

  function container_frame:GetFontString()
    if #self.available_font_strings == 0 then
      local new_font_string = NeverForget_CreateFontString(self)
      table.insert(self.available_font_strings, new_font_string)
    end

    local font_string = table.remove(self.available_font_strings)
    table.insert(self.assigned_font_strings, font_string)

    font_string:ClearAllPoints()

    return font_string
  end

  function container_frame:AddItemListNameRow(item_list_name)
    self.row_count = self.row_count + 1
    local y_position = -(self.row_count-1)*CHECKLIST_FRAME_ITEM_HEIGHT

    local font_string = self:GetFontString()

    font_string:SetSize(210, 20)
    font_string:SetPoint("TopLeft", 3, y_position - 1)
    font_string:SetJustifyH("Left")
    font_string:SetText(item_list_name)

    font_string:Show()
  end

  function container_frame:AddItemRow(item_id, item_count, bankIncluded)
    self.row_count = self.row_count + 1
    local y_position = -(self.row_count-1)*CHECKLIST_FRAME_ITEM_HEIGHT

    -- Dsiplay item name.

    local font_string = self:GetFontString()

    font_string:SetSize(210, 20)
    font_string:SetPoint("TopLeft", 3, y_position - 1)
    font_string:SetText(item_id)
    font_string:SetJustifyH("Left")
    local item = Item:CreateFromItemID(item_id)
    font_string.cancel_callback = item:ContinueWithCancelOnItemLoad(function()
      font_string:SetText(item:GetItemLink())
    end)

    font_string:Show()

    -- Display item count.

    -- Get count for this item.
    local real_item_count = GetItemCount(item_id, bankIncluded)

    -- Set the color that will be used when displaying the count.
    local text_color = "Red"
    if (real_item_count >= item_count) then
      text_color = "Green"
    end

    local item_count_font_string = self:GetFontString()

    local colored_count = GetColoredText(real_item_count .. "/" .. item_count, text_color)

    item_count_font_string:SetSize(65, 20)
    item_count_font_string:SetPoint("TopRight", -3, y_position - 1)
    item_count_font_string:SetJustifyH("Center")
    item_count_font_string:SetText(colored_count)

    item_count_font_string:Show()
  end

  function container_frame:Refresh()
    self.row_count = 0
    -- Hide all existing font_strings, and cancel the item name fetch.
    for i, font_string in ipairs(self.assigned_font_strings) do
      if (font_string.cancel_callback ~= nil) then
        font_string.cancel_callback()
      end

      font_string:Hide()
      table.insert(self.available_font_strings, font_string)
    end
    self.assigned_font_strings = {}

    for checklistIndex = 1, NeverForget_API_GetChecklistCount() do
      if NeverForget_API_IsChecklistVisible(checklistIndex) then
        local item_list = NeverForget_API_GetItemList(checklistIndex)

        local bankIncluded = NeverForget_API_IsBankIncluded(checklistIndex)

        -- Include one for the checklist name header.
        local checklist_name = NeverForget_API_GetChecklistName(checklistIndex)
        if #item_list == 0 then
          checklist_name = checklist_name .. " (Empty)"
        end
        if bankIncluded then
          checklist_name = checklist_name .. " (Bank included)"
        end
        self:AddItemListNameRow(checklist_name)

        -- Set up each element of the checklist.
        for i, element in ipairs(item_list) do
          local item_id = element.item_id
          local item_count = element.item_count

          self:AddItemRow(item_id, item_count, bankIncluded)

          --[[frame:SetHyperlinksEnabled(true)
          frame:SetScript("OnHyperlinkEnter", function()
            -- Not ideal because it depends on the Item:CreateFromItemID() above.
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink(item:GetItemLink())
            GameTooltip:Show()
          end)
          frame:SetScript("OnHyperlinkLeave", function()
            GameTooltip:Hide()
          end)]]
        
        end
      end
    end

    if self.row_count == 0 then
      local colored_text = GetColoredText("No selected item lists", "Red")
      self:AddItemListNameRow(colored_text)
    end

    -- Set the container height based on the number of items in the list.
    local new_height = CHECKLIST_FRAME_ITEM_HEIGHT * self.row_count
    self:SetHeight(new_height)
  end
  return container_frame
end

-- Creates the header frame. The header frame is movable frame that contains
-- the name of the addon and the + and - buttons.
function NeverForget_CreateHeaderFrame()
  -- This frame is named so that its position is restored on addon load.
  local header_frame = CreateFrame("Frame", "NeverForget_HeaderFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

  header_frame:SetSize(CHECKLIST_FRAME_WIDTH, CHECKLIST_FRAME_ITEM_HEIGHT)
  header_frame:SetPoint("Center")
  SetDarkFrameBackdrop(header_frame)

  SetFrameMovable(header_frame)

  -- Children
  header_frame.buttons = {}
  function header_frame:CreateButton(icon_character, callback)
    local index = #self.buttons + 1

    local header_button = NeverForget_CreateButton(self,
        icon_character,
        callback)

    header_button:SetSize(CHECKLIST_FRAME_ITEM_HEIGHT, CHECKLIST_FRAME_ITEM_HEIGHT)
    header_button:SetPoint("Right", -(index - 1) * CHECKLIST_FRAME_ITEM_HEIGHT, 0) -- Padding of 5.

    self.buttons[index] = header_button
  end

  header_frame.title = CreateHeaderTitle(header_frame)

  -- Container frame.
  local container_frame = CreateContainerFrame(header_frame)

  container_frame:Initialize()

  header_frame.container_frame = container_frame

  header_frame:CreateButton("-", function()
    NeverForget_API_ToggleMinimized()
    ToggleFrame(header_frame.container_frame)

    if NeverForget_API_IsMinimized() then
      header_frame.title:SetText("NeverForget - Minimized")
    else
      header_frame.title:SetText("NeverForget")
    end
  end)
  header_frame:CreateButton(">", function()
    ToggleDropDownMenu(1, nil, MyDropDown, "cursor", 0, 0)
  end)

  function Initialize(frame, level, menuList)
    if (level == 1) then
      local info = UIDropDownMenu_CreateInfo()
      info.text = "Your checklists"
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info)

      -- One item per checklist.
      for checklistIndex=1, NeverForget_API_GetChecklistCount() do
        info = UIDropDownMenu_CreateInfo()
        info.text = NeverForget_API_GetChecklistName(checklistIndex)
        info.hasArrow = true
        info.keepShownOnClick = true
        info.isNotRadio = true
        info.menuList = checklistIndex
        info.arg1 = checklistIndex
        info.checked =  NeverForget_API_IsChecklistVisible(checklistIndex)
        info.func = function(self, arg1)
          NeverForget_API_ToggleChecklistVisibility(arg1)
        end
        UIDropDownMenu_AddButton(info)
      end

      -- Separator
      info = UIDropDownMenu_CreateInfo()
      info.disabled = true 
      info.notCheckable = true
      UIDropDownMenu_AddButton(info)

      -- Title button
      info = UIDropDownMenu_CreateInfo()
      info.text = "Actions"
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info)

      info = UIDropDownMenu_CreateInfo()
      info.text = "New list"
      info.notCheckable = true
      info.func = NeverForget_API_CreateChecklist
      UIDropDownMenu_AddButton(info)
    end

    if (level == 2) then
      local checklistIndex = menuList

      -- Title button
      local info = UIDropDownMenu_CreateInfo()
      info.text = NeverForget_API_GetChecklistName(checklistIndex)
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Edit"
      info.notCheckable = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_OpenEditMode(arg1)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Rename"
      info.notCheckable = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_API_RenameChecklist(arg1)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Delete"
      info.notCheckable = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_API_DeleteChecklist(arg1)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, 2)

      -- Separator
      info = UIDropDownMenu_CreateInfo()
      info.disabled = true 
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, 2)

      -- Title button
      info = UIDropDownMenu_CreateInfo()
      info.text = "List options"
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Include bank"
      info.checked = NeverForget_API_IsBankIncluded(checklistIndex)
      info.keepShownOnClick = true
      info.isNotRadio = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_API_ToggleIncludeBank(arg1)
      end
      UIDropDownMenu_AddButton(info, 2)

      -- Separator
      info = UIDropDownMenu_CreateInfo()
      info.disabled = true 
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, 2)

      -- Title button
      info = UIDropDownMenu_CreateInfo()
      info.text = "Import options"
      info.isTitle = true
      info.notCheckable = true
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Import"
      info.notCheckable = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_OpenImportFrame(arg1)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, 2)

      info = UIDropDownMenu_CreateInfo()
      info.text = "Show import string"
      info.notCheckable = true
      info.arg1 = checklistIndex
      info.func = function(self, arg1)
        NeverForget_OpenShowImportStringWindow(arg1)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info, 2)
    end
  end

  local drop_down_frame = CreateFrame("Frame", "MyDropDown", UIParent, "UIDropDownMenuTemplate")

  UIDropDownMenu_Initialize(drop_down_frame, Initialize, "MENU")

  function header_frame:Refresh()
    header_frame.container_frame:Refresh()
  end

  return header_frame
end