#!/usr/bin/env lua
-- theme-export — render the active wezterm theme as palettes for other apps.
--
-- Modes (combinable; stdout appends in flag order):
--   --bash      eval-able palette for the Claude Code statusline
--   --cc-theme  Claude Code custom-theme JSON, printed to stdout
--   --sync      write ~/.claude/themes/wezterm.json if its content drifted
--   --omp       write shell/oh-my-posh/theme.generated.omp.json if it drifted
--   --css       :root{...} CSS custom properties for markdown-viewer, to stdout
--   --css-sync  write ../wezterm-webview/theme.generated.css if it drifted
--
-- On ANY failure: exit non-zero and print NOTHING (callers eval the output,
-- so partial output would corrupt their state).
-- Contract + install steps: README.md next to this file.

local function main()
  -- Repo root: machine seam first, script location as fallback.
  local root = os.getenv("TERMINAL_REPO_DIR")
  if not root or root == "" then
    root = (arg[0] or ""):match("^(.*)/integrations/claude%-code/[^/]+$")
  end
  assert(root and root ~= "", "no repo root")

  -- Active theme: mirror the wezterm.lua bootstrap.
  local function load_if_exists(path)
    local f = io.open(path, "r")
    if not f then return nil end
    f:close()
    return dofile(path)
  end
  local name = load_if_exists(root .. "/theme.lua")
             or dofile(root .. "/theme.sample.lua")
  local theme = dofile(root .. "/themes/" .. name .. ".lua")
  assert(type(theme) == "table", "theme did not return a table")

  -- Color math.
  local function rgb(c)
    local r, g, b = c:match("^#(%x%x)(%x%x)(%x%x)$")
    assert(r, "not a hex color: " .. tostring(c))
    return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
  end
  local function to_hex(r, g, b)
    local function cl(v) return math.max(0, math.min(255, math.floor(v + 0.5))) end
    return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
  end
  local function blend(c, base, a)
    local r1, g1, b1 = rgb(c)
    local r2, g2, b2 = rgb(base)
    return to_hex(r1*a + r2*(1-a), g1*a + g2*(1-a), b1*a + b2*(1-a))
  end
  -- Themes may use rgba(r,g,b,a) (cyberdream's transparent tab bar);
  -- flatten those over the scheme background. Hex passes through.
  local function resolve(c, base)
    if c:match("^#") then return c end
    local r, g, b, a = c:match("^rgba%((%d+),%s*(%d+),%s*(%d+),%s*([%d%.]+)%)$")
    assert(r, "unsupported color: " .. tostring(c))
    return blend(to_hex(tonumber(r), tonumber(g), tonumber(b)), base, tonumber(a))
  end
  local function luminance(c)
    local r, g, b = rgb(c)
    return (0.2126*r + 0.7152*g + 0.0722*b) / 255
  end

  -- The eleven roles (spec: Role mapping).
  local bg = theme.colors.background
  local roles = {
    bg      = bg,
    bg_alt  = resolve(theme.tab_bar.colors.background, bg),
    bg_alt2 = resolve(theme.tab_bar.colors.inactive_tab_hover.bg_color, bg),
    fg      = theme.colors.foreground,
    dim     = theme.ui.dim,
    muted   = theme.ui.muted,
    accent  = theme.ui.accent,
    ok      = theme.colors.ansi[3],
    warn    = theme.ui.warn,
    alert   = theme.ui.alert,
    crit    = theme.colors.ansi[2],
    thumb   = theme.ui.scrollbar_thumb,
  }
  -- Validate every role up front, by name — a theme missing a field should
  -- say which one, not die in an emitter with a nameless nil error.
  for _, n in ipairs({ "bg", "bg_alt", "bg_alt2", "fg", "dim", "muted",
                       "accent", "ok", "warn", "alert", "crit", "thumb" }) do
    assert(roles[n], "theme is missing the field behind role: " .. n)
    rgb(roles[n])
  end

  -- Emitters.
  local function esc(prefix, c)
    local r, g, b = rgb(c)
    return string.format("\27[%s;2;%d;%d;%dm", prefix, r, g, b)
  end
  local function triplet(c)
    local r, g, b = rgb(c)
    return string.format("%d;%d;%d", r, g, b)
  end

  local function emit_bash()
    -- 0.7 accent share, not 0.5: on light themes blending toward the light
    -- band washed the low-fill cells out (user-reported faint, 2026-06-12).
    local grad_start = blend(roles.accent, roles.bg_alt2, 0.7)
    local lines = {
      "BG_L1='"    .. esc("48", roles.bg_alt)  .. "'",
      "BG_L2='"    .. esc("48", roles.bg_alt2) .. "'",
      "FG='"       .. esc("38", roles.fg)      .. "'",
      "DIM='"      .. esc("38", roles.dim)     .. "'",
      "ACCENT='"   .. esc("38", roles.accent)  .. "'",
      "CLR_OK='"   .. esc("38", roles.ok)      .. "'",
      "CLR_WARN='" .. esc("38", roles.warn)    .. "'",
      "CLR_CRIT='" .. esc("38", roles.crit)    .. "'",
      "GRAD_START_RGB='" .. triplet(grad_start)    .. "'",
      "GRAD_END_RGB='"   .. triplet(roles.accent)  .. "'",
      -- muted, not thumb: thumb vs the bar's band was ~1.05:1 on paper —
      -- the empty track vanished entirely (pixel-verified, 2026-06-12).
      "GRAD_EMPTY='"     .. esc("38", roles.muted) .. "'",
    }
    return table.concat(lines, "\n") .. "\n"
  end

  local function emit_cc_theme()
    local base = luminance(roles.bg) > 0.5 and "light" or "dark"
    local tokens = {
      { "claude",            roles.accent },
      -- inactive is pulled 25% toward fg: Claude Code sets struck-through
      -- tasks and other body text in it, where the raw tab-gray dim reads
      -- ~3:1 on the paper cream (user-reported hard to read, 2026-06-12).
      { "inactive",          blend(roles.fg, roles.dim, 0.25) },
      -- subtle matches inactive's formula: Claude Code uses it for collapsed
      -- past input, connector lines, AND the pinned-header text while
      -- scrolled — all of which must stay readable. Raw thumb was ~1.2:1 on
      -- the paper bg; muted was still too faint pinned (user, 2026-06-12).
      { "subtle",            blend(roles.fg, roles.dim, 0.25) },
      -- the band behind user input rows and the pinned header — a soft
      -- accent tint instead of the base preset's untinted gray, so typed
      -- input is scannable on the cream (user request, 2026-06-12).
      { "userMessageBackground",      blend(roles.accent, roles.bg, 0.12) },
      { "userMessageBackgroundHover", blend(roles.accent, roles.bg, 0.18) },
      { "success",           roles.ok },
      { "warning",           roles.warn },
      { "error",             roles.crit },
      { "diffAdded",         blend(roles.ok,   roles.bg, 0.18) },
      { "diffRemoved",       blend(roles.crit, roles.bg, 0.18) },
      { "diffAddedDimmed",   blend(roles.ok,   roles.bg, 0.10) },
      { "diffRemovedDimmed", blend(roles.crit, roles.bg, 0.10) },
      { "diffAddedWord",     blend(roles.ok,   roles.bg, 0.40) },
      { "diffRemovedWord",   blend(roles.crit, roles.bg, 0.40) },
    }
    local parts = {}
    for _, t in ipairs(tokens) do
      parts[#parts + 1] = string.format('    "%s": "%s"', t[1], t[2])
    end
    return string.format(
      '{\n  "name": "wezterm",\n  "base": "%s",\n  "overrides": {\n%s\n  }\n}\n',
      base, table.concat(parts, ",\n"))
  end

  local function sync_cc_theme()
    local home = os.getenv("HOME")
    assert(home and home ~= "", "no HOME")
    local dir = home .. "/.claude/themes"
    local path = dir .. "/wezterm.json"
    local wanted = emit_cc_theme()
    local f = io.open(path, "r")
    if f then
      local current = f:read("a")
      f:close()
      if current == wanted then return end
    end
    os.execute(string.format("mkdir -p '%s'", dir))
    local tmp = path .. ".tmp"
    local w = assert(io.open(tmp, "w"))
    w:write(wanted)
    w:close()
    assert(os.rename(tmp, path))
  end

  -- oh-my-posh: rewrite the tracked template's palette from the theme's omp
  -- block. Structure (segments, icons, powerline shape) stays in the template;
  -- only palette values change. Returns the full config text, or nil when the
  -- theme defines no omp block (then --omp writes nothing).
  local function build_omp()
    if type(theme.omp) ~= "table" then return nil end
    local tmpl_path = root .. "/shell/oh-my-posh/theme.omp.json"
    local f = assert(io.open(tmpl_path, "r"), "no omp template at " .. tmpl_path)
    local tmpl = f:read("a")
    f:close()

    -- Resolve a name to a hex: literal (#...) -> theme.hues -> role table -> error.
    local hues = theme.hues or {}
    local function resolve_name(name)
      assert(type(name) == "string", "omp value is not a string: " .. tostring(name))
      if name:match("^#") then return name end
      if hues[name] then return hues[name] end
      if roles[name] then return roles[name] end
      error("unknown omp color name: " .. name)
    end

    -- Template palette keys, in file order — the authoritative key set.
    local palette = tmpl:match('"palette"%s*:%s*(%b{})')
    assert(palette, "omp template has no palette block")
    local keys, seen = {}, {}
    for k in palette:gmatch('"([%w_]+)"%s*:') do
      keys[#keys + 1] = k
      seen[k] = true
    end

    -- The two key sets must match exactly — a silent mismatch would leave a
    -- baked value unthemed, or an omp entry doing nothing.
    for k in pairs(theme.omp) do
      assert(seen[k], "omp block has key not in template: " .. k)
    end
    local lines = {}
    for _, k in ipairs(keys) do
      local v = theme.omp[k]
      assert(v ~= nil, "omp template key has no omp-block entry: " .. k)
      local hex = resolve_name(v)
      rgb(hex)  -- a resolved value must be a real hex
      lines[#lines + 1] = string.format('    "%s": "%s"', k, hex)
    end

    local new_palette = "{\n" .. table.concat(lines, ",\n") .. "\n  }"
    local repl = ('"palette": ' .. new_palette):gsub("%%", "%%%%")  -- escape % for gsub
    return (tmpl:gsub('"palette"%s*:%s*%b{}', repl, 1))
  end

  local function sync_omp()
    local wanted = build_omp()
    if not wanted then return end  -- no omp block: leave the tracked template
    local path = root .. "/shell/oh-my-posh/theme.generated.omp.json"
    local f = io.open(path, "r")
    if f then
      local current = f:read("a")
      f:close()
      if current == wanted then return end
    end
    local tmp = path .. ".tmp"
    local w = assert(io.open(tmp, "w"))
    w:write(wanted)
    w:close()
    assert(os.rename(tmp, path))
  end

  local function active_code_font()
    local fname = load_if_exists(root .. "/font.lua")
                or dofile(root .. "/font.sample.lua")
    local fdef = dofile(root .. "/fonts/" .. fname .. ".lua")
    assert(type(fdef) == "table" and fdef.family, "font def missing family: " .. tostring(fname))
    return fdef.family
  end

  -- Option B: push the active font INTO the viewer so it follows the font switcher
  -- with no manual Windows install. Copy the weight files into the viewer's gitignored
  -- fonts.generated/ and emit @font-face for them (the node server serves them, and a
  -- url() @font-face overrides any same-named installed font, so it works either way).
  local FONT_DEST = root:gsub("[/\\][^/\\]+$", "") .. "/wezterm-webview/fonts.generated"

  local function active_font_name()
    return load_if_exists(root .. "/font.lua") or dofile(root .. "/font.sample.lua")
  end

  -- Map a source filename to a normalized RIBBI basename, or nil to skip. Non-RIBBI
  -- weights (medium/light/thin/...) are dropped — the browser synthesizes what's missing.
  local function classify_font(file)
    local l = file:lower()
    if not l:match("%.[ot]tf$") then return nil end
    if l:match("light") or l:match("thin") or l:match("black")
       or l:match("semi") or l:match("extra") or l:match("heavy") then return nil end
    local bold, ital = l:match("bold"), l:match("italic")
    if l:match("medium") then return (not ital) and "code-m" or nil end  -- Medium (500); skip MediumItalic
    if bold and ital then return "code-bi" end
    if ital then return "code-i" end
    if bold then return "code-b" end
    return "code-r"
  end

  local function list_dir(dir)
    local p = io.popen('ls -1 "' .. dir .. '" 2>/dev/null'); if not p then return {} end
    local t = {}; for ln in p:lines() do t[#t + 1] = ln end; p:close(); return t
  end

  -- Copy the active font's RIBBI files into fonts.generated/ — guarded so the (~10MB)
  -- copy only happens when the selected font actually changed.
  local function sync_fonts()
    local fname = active_font_name()
    local mf = io.open(FONT_DEST .. "/.font", "r")
    local cur = mf and mf:read("a") or nil; if mf then mf:close() end
    if cur == fname then return end
    local adir = root .. "/fonts/assets/" .. fname
    os.execute('mkdir -p "' .. FONT_DEST .. '"')
    os.execute('rm -f "' .. FONT_DEST .. '"/code-r.* "' .. FONT_DEST .. '"/code-m.* '
             .. '"' .. FONT_DEST .. '"/code-b.* "' .. FONT_DEST .. '"/code-i.* '
             .. '"' .. FONT_DEST .. '"/code-bi.*')
    for _, file in ipairs(list_dir(adir)) do
      local norm = classify_font(file)
      if norm then
        os.execute('cp "' .. adir .. "/" .. file .. '" "'
                 .. FONT_DEST .. "/" .. norm .. file:match("(%.%w+)$") .. '"')
      end
    end
    local w = io.open(FONT_DEST .. "/.font", "w"); if w then w:write(fname); w:close() end
  end

  -- @font-face rules for whatever code-*.{ttf,otf} were pushed into fonts.generated/.
  local function font_faces()
    local fam, faces = active_code_font(), {}
    local meta = { ["code-r"] = { 400, "normal" }, ["code-m"] = { 500, "normal" },
                   ["code-b"] = { 700, "normal" },
                   ["code-i"] = { 400, "italic" }, ["code-bi"] = { 700, "italic" } }
    for _, f in ipairs(list_dir(FONT_DEST)) do
      local m = meta[f:match("^(code%-%a+)%.[ot]tf$") or ""]
      if m then
        faces[#faces + 1] = string.format(
          '@font-face { font-family: "%s"; src: url("/fonts.generated/%s"); ' ..
          'font-weight: %d; font-style: %s; font-display: swap; }', fam, f, m[1], m[2])
      end
    end
    return #faces > 0 and (table.concat(faces, "\n") .. "\n") or ""
  end

  local function emit_css()
    local scheme = luminance(roles.bg) > 0.5 and "light" or "dark"
    local link = theme.colors.ansi[5]                    -- blue slot (real blue)
    local sel  = theme.colors.selection_bg or roles.bg_alt2
    local hues = theme.hues or {}
    local function hue(name) return hues[name] or roles.bg_alt2 end  -- optional per theme
    rgb(link); rgb(sel)
    local lines = {
      "  color-scheme: " .. scheme .. ";",
      "  --bg: "      .. roles.bg      .. ";",
      "  --fg: "      .. roles.fg      .. ";",
      "  --accent: "  .. roles.accent  .. ";",
      "  --link: "    .. link          .. ";",
      "  --code-bg: " .. roles.bg_alt  .. ";",
      "  --surface: " .. roles.bg_alt2 .. ";",
      "  --border: "  .. roles.thumb   .. ";",
      "  --muted: "   .. roles.muted   .. ";",
      "  --sel: "     .. sel           .. ";",
      "  --ok: "      .. roles.ok      .. ";",
      "  --warn: "    .. roles.warn    .. ";",
      "  --crit: "    .. roles.crit    .. ";",
    }
    for _, h in ipairs({ "rosy","sky","mint","lavender","peach","teal","gold" }) do
      lines[#lines + 1] = "  --hue-" .. h .. ": " .. hue(h) .. ";"
    end
    lines[#lines + 1] = '  --font-code: "' .. active_code_font() .. '", monospace;'
    lines[#lines + 1] = '  --font-body: "IBM Plex Sans", system-ui, sans-serif;'
    return font_faces() .. ":root {\n" .. table.concat(lines, "\n") .. "\n}\n"
  end

  local function sync_css()
    -- The markdown viewer is now a sibling repo (../wezterm-webview); push the
    -- generated CSS into its dir — the same one-directional push as --sync into
    -- ~/.claude/themes. Real sibling path, not a junction (Windows file APIs,
    -- including WezTerm's Lua, don't reliably follow it).
    local path = root:gsub("[/\\][^/\\]+$", "") .. "/wezterm-webview/theme.generated.css"
    local wanted = emit_css()
    local f = io.open(path, "r")
    if f then local cur = f:read("a"); f:close(); if cur == wanted then return end end
    local tmp = path .. ".tmp"
    local w = assert(io.open(tmp, "w")); w:write(wanted); w:close()
    assert(os.rename(tmp, path))
  end

  -- Mode dispatch: render everything first, then act, then print.
  assert(#arg > 0, "no mode given")
  local out = {}
  local sync = false
  local omp = false
  local css_sync = false
  for _, flag in ipairs(arg) do
    if flag == "--bash" then out[#out + 1] = emit_bash()
    elseif flag == "--cc-theme" then out[#out + 1] = emit_cc_theme()
    elseif flag == "--sync" then sync = true
    elseif flag == "--omp" then omp = true
    elseif flag == "--css" then out[#out + 1] = emit_css()
    elseif flag == "--css-sync" then css_sync = true
    else error("unknown flag: " .. flag) end
  end
  if sync then sync_cc_theme() end
  if omp then sync_omp() end
  if css_sync then sync_fonts(); sync_css() end
  io.write(table.concat(out))
end

local ok, err = pcall(main)
if not ok then
  -- stderr only: stdout must stay empty on failure (callers eval it), and
  -- the statusline caller already sends stderr to /dev/null.
  io.stderr:write("theme-export: " .. tostring(err) .. "\n")
  os.exit(1)
end
