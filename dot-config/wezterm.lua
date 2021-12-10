local wezterm = require "wezterm";

local font = wezterm.font("DejaVu Sans Mono");
local default_prog = nil
local launch_menu = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  font = wezterm.font("Consolas");

  default_prog = {"wsl.exe"}

  table.insert(launch_menu, {
    label = "CMD",
    args = {"cmd.exe"},
  })

  table.insert(launch_menu, {
    label = "PowerShell",
    args = {"powershell.exe"},
  })

  -- Find installed visual studio version(s) and add their compilation
  -- environment command prompts to the menu
  for _, arch in ipairs({"", " (x86)"}) do
    local program_files = string.format("C:/Program Files%s", arch)

    for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*", program_files)) do
      local year = vsvers:gsub("Microsoft Visual Studio/", "")
      local vsdir = program_files .. "/" .. vsvers
      local vcvars = ""

      if year >= "2022" then
        vcvars = vsdir .. "/Community/VC/Auxiliary/Build/vcvars64.bat"
      else
        vcvars = vsdir .. "/BuildTools/VC/Auxiliary/Build/vcvars64.bat"
      end

      args = {"cmd.exe", "/k", vcvars}

      table.insert(launch_menu, {
        label = "x64 Native Tools VS " .. year,
        args = args,
      })
    end
  end

  for _, _ in ipairs(wezterm.glob("Git", "C:/Program Files")) do
    table.insert(launch_menu, {
      label = "Git Bash",
      args = {"C:/Program Files/Git/usr/bin/bash.exe", "-i", "-l"},
      set_environment_variables = {
      },
    })
  end
end

local colors = {
  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = "white",
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = "black",
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- of the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = "white",

  -- the foreground color of selected text
  selection_fg = "black",
  -- the background color of selected text
  selection_bg = "#fffacd",

  scrollbar_thumb = "#555555",

  -- The color of the split lines between panes
  split = "#444444",

  -- The default text color
  foreground = "#dedede",
  -- The default background color
  background = "#0C0C0C",

  ansi = {
    "#0C0C0C",
    "#db2d20",
    "#13A10E",
    "#C19C00",
    "#0037DA",
    "#881798",
    "#3A96DD",
    "#CCCCCC",
  },
  brights = {
    "#767676",
    "#E74856",
    "#16C60C",
    "#F9F1A5",
    "#3B78FF",
    "#B4009E",
    "#61D6D6",
    "#F2F2F2",
  },
  tab_bar = {
    background = "#888888",

    active_tab = {
      bg_color = "#dddddd",
      fg_color = "#000000",
      intensity = "Bold",
    },

    inactive_tab = {
      bg_color = "#888888",
      fg_color = "#000000",
    },

    inactive_tab_hover = {
      bg_color = "#aaaaaa",
      fg_color = "#000000",
    },

    new_tab = {
      bg_color = "#888888",
      fg_color = "#000000",
    },

    new_tab_hover = {
      bg_color = "#aaaaaa",
      fg_color = "#000000",
    },
  }
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = wezterm.truncate_right(tab.active_pane.title, max_width-5)
  return {
    {Text=string.format(" %s: %s ", tab.tab_index + 1, title)},
  }
end)

return {
  font = font,
  font_size = 11,
  enable_scroll_bar = true,
  scrollback_lines = 20000,
  colors = colors,
  audible_bell = "Disabled",
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  tab_max_width = 22,
  harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
  launch_menu = launch_menu,
  default_prog = default_prog,
  keys = {
    {key="t", mods="CTRL|ALT", action="ShowLauncher"},
  },
}