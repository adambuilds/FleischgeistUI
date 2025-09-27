local addonName, addonData = ...

local CHECKLIST_FRAME_WIDTH = 260

-- The vertical space that each items in the list takes.
local CHECKLIST_FRAME_ITEM_HEIGHT = 20


local function CreateCopyOfItemList(checklistIndex)
  local item_list = NeverForget_API_GetItemList(checklistIndex)

  local copy = {}
  for i, item in ipairs(item_list) do
    copy[i] = {}
    copy[i].item_id = item.item_id
    copy[i].item_count = item.item_count
  end

  return copy
end

local function CreateHeaderTitle(parent_frame)
  local header_title = parent_frame:CreateFontString(nil, "Artwork", "GameFontNormal")

  header_title:SetPoint("Left", 5, 0)
  header_title:SetTextColor(1, 1, 1, 1)
  header_title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  header_title:SetText("NeverForget - Editing")

  return header_title
end

function CreateEditModeFrame()
  -- This frame is named so that its position is restored on addon load.
  local header_frame = CreateFrame("Frame", "NeverForget_EditMode_HeaderFrame", nil, BackdropTemplateMixin and "BackdropTemplate")

  header_frame:SetSize(CHECKLIST_FRAME_WIDTH, CHECKLIST_FRAME_ITEM_HEIGHT)
  header_frame:SetPoint("Top", 0, -300)
  SetDarkFrameBackdrop(header_frame)

  SetFrameMovable(header_frame)

  header_frame.title = CreateHeaderTitle(header_frame)

  local edit_frame = CreateFrame("Frame", nil, header_frame, BackdropTemplateMixin and "BackdropTemplate")
  header_frame.edit_frame = edit_frame

  function edit_frame:Initialize()
    self:SetWidth(CHECKLIST_FRAME_WIDTH)
    self:SetPoint("Top", 0, -header_frame:GetHeight()) --, 0, -parent_frame:GetHeight())
    SetFrameBackdrop(self)

    self:CreateSaveButton()
    self:CreateCancelButton()
    self:CreateAddItemRowFrame(function(item_id)
      AddItemToItemList(edit_frame.item_list, item_id, 1)
      edit_frame:Refresh()
    end)

    self.item_name_font_strings = {}
    self.item_count_edit_boxes = {}
    self.item_remove_buttons = {}
  end

  function edit_frame:CreateSaveButton()
    local save_button = NeverForget_CreateButton(self, "Save", function()
      self:SaveItemList()
    end)

    save_button:SetSize(60, 20)
    save_button:SetPoint("Bottom", 40, -30)

    self.save_button = save_button
  end

  function edit_frame:CreateCancelButton()
    local cancel_button = NeverForget_CreateButton(self, "Cancel", function()
      self:CancelEdit()
    end)

    cancel_button:SetSize(60, 20)
    cancel_button:SetPoint("Bottom", -40, -30)

    self.cancel_button = cancel_button
  end

  function edit_frame:SaveItemList()
    if edit_frame.last_focused_edit_box then
      edit_frame.last_focused_edit_box:SetItemCount()
    end

    NeverForget_API_SetItemList(self.checklistIndex, self.item_list)

    self.item_list = nil
    header_frame:Hide()
  end

  function edit_frame:CancelEdit()
    self.item_list = nil
    header_frame:Hide()
  end

  function edit_frame:CreateAddItemRowFrame(add_item_callback)
    local add_item_row_frame = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")

    SetDarkFrameBackdrop(add_item_row_frame)

    add_item_row_frame:SetSize(200, 20)
    add_item_row_frame:SetPoint("Bottom")

    function add_item_row_frame:OnClick(button)
      if (button ~= "LeftButton") then
        return
      end

      -- Check if there is an item on the cursor
      local info_type, item_id, item_link = GetCursorInfo()
      if (info_type ~= "item") then
        return
      end

      add_item_callback(item_id)
      ClearCursor()
    end

    add_item_row_frame:EnableMouse(true)
    add_item_row_frame:SetScript("OnReceiveDrag", function(self)
      self:OnClick("LeftButton")
    end)
    add_item_row_frame:SetScript("OnMouseDown", function(self, button)
      self:OnClick(button)
    end)

    add_item_row_frame:Show()

    local font_string = NeverForget_CreateFontString(add_item_row_frame)

    font_string:SetPoint("Center")
    font_string:SetText("Add an item by dragging it here")
    font_string:Show()

    self.add_item_row_frame = add_item_row_frame
  end
--[[
  edit_frame:SetScript("OnShow", function(self)
    self.item_list = CreateCopyOfItemList(self.checklistIndex)
    self:Refresh()
  end)]]

  function edit_frame:GetRemoveButton(index)
    local remove_button = self.item_remove_buttons[index]
    if remove_button == nil then
      remove_button = NeverForget_CreateButton(self, "X", nil, BackdropTemplateMixin and "BackdropTemplate")

      SetDarkFrameBackdrop(remove_button)

      remove_button:SetSize(20, 20)
      remove_button:Hide()

      --font_string:SetSize(20, self:GetWidth() - 50)
      self.item_remove_buttons[index] = remove_button
    end

    return remove_button
  end

  function edit_frame:GetItemNameFontString(index)
    local font_string = self.item_name_font_strings[index]
    if font_string == nil then
      font_string = NeverForget_CreateFontString(self)
      --font_string:SetSize(20, self:GetWidth() - 50)
      self.item_name_font_strings[index] = font_string
    end

    return font_string
  end

  function edit_frame:GetItemCountEditBox(index)
    local edit_box = self.item_count_edit_boxes[index]
    if edit_box == nil then
      edit_box = NeverForget_CreateEditBox(self)
      edit_box:SetSize(50, 20)
      edit_box:SetNumeric(true)
      edit_box:SetMaxLetters(5)
      self.item_count_edit_boxes[index] = edit_box
    end

    return edit_box
  end

  function edit_frame:SetChecklistIndex(index)
    self.checklistIndex = index
    local colored_checklist_name = GetColoredText(NeverForget_API_GetChecklistName(index), "Yellow")
    header_frame.title:SetText("NeverForget - Editing " .. colored_checklist_name)
    self.item_list = CreateCopyOfItemList(self.checklistIndex)
  end

  function edit_frame:Refresh()
    -- First hide all existing frames. This is needed because there could now
    -- be one less element in the item list since last refresh, meaning there
    -- might be one frame of each type that is still showing that will not get
    -- overwritten.
    for i, edit_box in ipairs(self.item_count_edit_boxes) do
      edit_box:Hide()
    end
    for i, font_string in ipairs(self.item_name_font_strings) do
      if (font_string.cancel_callback ~= nil) then
        font_string.cancel_callback()
      end
      font_string:Hide()
    end
    for i, remove_button in ipairs(self.item_remove_buttons) do
      remove_button:Hide()
    end

    -- Show each item rows. Could be none if the list is currently empty.
    for i, item in ipairs(self.item_list) do
      local item_id = item.item_id
      local item_count = item.item_count

      local y_position = -(i-1)*CHECKLIST_FRAME_ITEM_HEIGHT

      -- Display the close buttons.
      local remove_button = self:GetRemoveButton(i)
      remove_button:SetPoint("TopLeft", -20, y_position)
      remove_button:Show()
      remove_button:SetScript("OnClick", function()
        RemoveItemFromItemList(edit_frame.item_list, i)
        edit_frame:Refresh()
      end)

      -- Display the item's name.
      local item_name_font_string = self:GetItemNameFontString(i)
      item_name_font_string:SetPoint("TopLeft", 3, y_position - 5)
      item_name_font_string:SetText(item_id)
      item_name_font_string:Show()

      local item = Item:CreateFromItemID(item_id)
      item_name_font_string.cancel_callback = item:ContinueWithCancelOnItemLoad(function()
        item_name_font_string:SetText(item:GetItemLink())
      end)

      -- Display the item's count in an edit box
      local item_count_edit_box = self:GetItemCountEditBox(i)
      item_count_edit_box:SetPoint("TopRight", 0, y_position)
      item_count_edit_box.original_count = item_count
      item_count_edit_box:SetText(item_count)
      item_count_edit_box:Show()

      function item_count_edit_box:SetItemCount()
        local new_count = self:GetNumber()
        if new_count == 0 then
          self:SetText(self.original_count)
          edit_frame:Refresh()
          self:ClearFocus()
          return
        end

        ModifyItemCount(edit_frame.item_list, item_id, new_count)
        self:ClearFocus()
        edit_frame:Refresh()
      end

      item_count_edit_box:SetScript("OnEnterPressed", function(self)
        self:SetItemCount()
      end)

      item_count_edit_box:SetScript("OnEditFocusGained", function(self)
        edit_frame.last_focused_edit_box = self
        --self:HighlightText(0, 0)
      end)

      item_count_edit_box:SetScript("OnEditFocusLost", function(self)
        edit_frame.last_focused_edit_box = nil
        if edit_frame.item_list then
          self:SetItemCount()
        end
        --self:HighlightText(0, 0)
      end)

    end

    -- Show add item row.

    self:SetHeight(20 * (#self.item_list + 1))
  end

  edit_frame:Initialize()

  return header_frame
end

local headerFrame = nil

function NeverForget_OpenEditMode(checklistIndex)
  if not headerFrame then
    headerFrame = CreateEditModeFrame()
  end

  headerFrame.edit_frame:SetChecklistIndex(checklistIndex)
  headerFrame.edit_frame:Refresh()

  headerFrame:Show()
end

function NeverForget_CloseEditMode()
  editModeFrame:Hide()
end