-- Utility function to make a frame movable.
function SetFrameMovable(frame)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

-- Helper function to set a transparent gray backdrop to a frame.
function SetFrameBackdrop(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    edgeSize = 1
  })
  frame:SetBackdropColor(0.1, 0.1, 0.1, 0.6);
  frame:SetBackdropBorderColor(0, 0, 0, 0.3);
end

-- Helper function to set a darker transparent gray backdrop to a frame.
function SetDarkFrameBackdrop(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    edgeSize = 1
  })
  frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8);
  frame:SetBackdropBorderColor(0, 0, 0, 0.3);
end

-- Helper function to set a darker transparent gray backdrop to a frame.
function SetYellowFrameBackdrop(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    edgeSize = 1
  })
  frame:SetBackdropColor(0.5, 0.5, 0.1, 0.8);
  frame:SetBackdropBorderColor(0, 0, 0, 0.3);
end

function NeverForget_CreateEditBox(parent_frame)
  local edit_box = CreateFrame("EditBox", nil, parent_frame, BackdropTemplateMixin and "BackdropTemplate")

  SetDarkFrameBackdrop(edit_box)
  edit_box:SetAutoFocus(false)
  edit_box:SetFont("Fonts\\FRIZQT__.TTF", 10, "THICKOUTLINE")
  edit_box:SetJustifyH("Center")

  edit_box:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)

  return edit_box
end

function ToggleFrame(frame)
  if (frame:IsVisible()) then
    frame:Hide()
  else
    frame:Show()
  end
end

function NeverForget_CreateFontString(parent_frame)
  local font_string = parent_frame:CreateFontString(nil, "Artwork", "GameFontNormal")

  font_string:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  font_string:SetTextColor(1, 1, 0, 1)

  return font_string
end

function NeverForget_CreateButton(parent_frame, text, on_click_callback)
  local button = CreateFrame("Button", nil, parent_frame, BackdropTemplateMixin and "BackdropTemplate")

  local font_string = button:CreateFontString()
  font_string:SetPoint("Center")
  font_string:SetTextColor(1, 1, 0, 1)
  font_string:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  font_string:SetText(text)

  button:SetFontString(font_string)

  button:SetScript("OnClick", on_click_callback)

  -- Highlight in red when hover.
  button:SetScript("OnEnter", function()
    font_string:SetTextColor(1, 0, 0, 1)
  end)
  button:SetScript("OnLeave", function()
    font_string:SetTextColor(1, 1, 0, 1)
  end)

  return button
end
