function NeverForget_CreateOptionsPanel(show_icon_callback, hide_icon_callback)
  -- Options panel
  local options_panel = CreateFrame("Frame", nil, UIParent);
  options_panel.name = "NeverForget";
  function options_panel:refresh()
    local is_icon_visible = NeverForget_API_IsMinimapButtonVisible()
    self.minimap_button_visibility_checkbox:SetChecked(is_icon_visible)
  end
  function options_panel:okay()
    local minimap_button_visible = self.minimap_button_visibility_checkbox:GetChecked()
    if (minimap_button_visible) then
      show_icon_callback()
      NeverForget_API_SetMinimapButtonVisible()
    else
      hide_icon_callback()
      NeverForget_API_SetMinimapButtonHidden()
    end
  end
  function options_panel:cancel()
  end
  function options_panel:default()
    show_icon_callback()
    NeverForget_API_SetMinimapButtonVisible()
  end

  options_panel.minimap_button_visibility_label = NeverForget_CreateFontString(options_panel)
  options_panel.minimap_button_visibility_label:SetSize(210, 20)
  options_panel.minimap_button_visibility_label:SetPoint("TopLeft", 5, -5)
  options_panel.minimap_button_visibility_label:SetJustifyH("Left")
  options_panel.minimap_button_visibility_label:SetText("Show minimap button")
  options_panel.minimap_button_visibility_label:Show()
 
  options_panel.minimap_button_visibility_checkbox = CreateFrame("CheckButton", nil, options_panel, "ChatConfigCheckButtonTemplate") 
  options_panel.minimap_button_visibility_checkbox:SetPoint("TopLeft", 125, -5)

  InterfaceOptions_AddCategory(options_panel);

  return options_panel
end