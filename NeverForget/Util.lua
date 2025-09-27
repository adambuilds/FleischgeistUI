-- Shows an error to the user.
function ShowError(error_text)
  print("NeverForget: " .. error_text)
end

-- Helper function to return the color code associated with a |color_name|.
function GetColorCode(color_name)
  if (color_name == "Red") then
    return "|cffff0000"
  end

  if (color_name == "Green") then
    return "|cff00ff00"
  end

  if (color_name == "Yellow") then
    return "|cffffff00"
  end

  -- Defaults to white
  return "|cffff00ff"
end

-- Wraps the |text| with the right code to display with a color.
function GetColoredText(text, color_name)
  return GetColorCode(color_name) .. text .. "|r"
end