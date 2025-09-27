local addon_name, addon_table = ...

local addon_frame = CreateFrame("Frame")

-- Do not access until initialization.
local header_frame = nil

addon_frame:RegisterEvent("ADDON_LOADED")
addon_frame:SetScript("OnEvent", function(self, event, arg1)
  -- Make sure the event received is the one for our addon specifically.
  if (event ~= "ADDON_LOADED") then return end
  if (arg1 ~= addon_name) then return end

  -- No longer need to receive this event.
  addon_frame:UnregisterEvent("ADDON_LOADED")

  NeverForget_API_Initialize()

  header_frame = NeverForget_CreateHeaderFrame()

  NeverForget_API_SetOnChangeCallback(function()
    header_frame:Refresh()
  end)

  header_frame:RegisterEvent("BAG_UPDATE")
  header_frame:SetScript("OnEvent", function(self, event)
    self:Refresh()
  end)

  function header_frame:Toggle()
    ToggleFrame(self)
    NeverForget_API_ToggleHidden()
  end

  header_frame:Refresh()

  if NeverForget_API_IsHidden() then
    header_frame:Hide()
  else
    header_frame:Show()
  end

  -- LibDataBroker stuff
  local data_object = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("NeverForget", {
    type = "launcher",
    icon = "Interface\\Icons\\inv_misc_note_06",
    OnClick = function(clickedframe, button)
      if (button == "LeftButton") then
        header_frame:Toggle()
      end
      if (button == "RightButton") then
        InterfaceOptionsFrame_OpenToCategory("NeverForget")
        InterfaceOptionsFrame_OpenToCategory("NeverForget")
      end
    end,
  })
  function data_object:OnTooltipShow()
    self:AddLine("|cffffffffNeverForget|r")
    self:AddLine("Click to show/hide")
    self:AddLine("Right-click to open options")
  end
  function data_object:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()
    data_object.OnTooltipShow(GameTooltip)
    GameTooltip:Show()
  end
  function data_object:OnLeave()
    GameTooltip:Hide()
  end

  -- LibDBIcon stuff
  local icon = LibStub:GetLibrary("LibDBIcon-1.0")
  local init_table = { hide = not NeverForget_API_IsMinimapButtonVisible() }
  icon:Register("NeverForgetLDB", data_object, init_table)

  local show_icon_callback = function() icon:Show("NeverForgetLDB") end
  local hide_icon_callback = function() icon:Hide("NeverForgetLDB") end

  local options_panel = NeverForget_CreateOptionsPanel(show_icon_callback, hide_icon_callback)
end)

-- Function for Toggle Window keybind.
function NeverForget_ToggleWindow()
  header_frame:Toggle()
end

BINDING_NAME_TOGGLE_WINDOW = "Toggle Window";
BINDING_HEADER_NEVERFORGET = "NeverForget";



--[[

Todo list:

Add option panel to delete profile data. This could be used by someone in a bad
state to get out of said bad state. Should be initialized before anything else
so that if the bad state cause an error early in the addon's initialization, the
button still works.

Make edit mode more pretty
Reorder list.
Resizable checklist.
Put item link in checklist instead of only name.
Automatically retrieve items from bank
]]
