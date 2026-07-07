-- main file for the dfzh_loader mod

--@ module = true

--[====[
dfzh_loader
===========

Tags: dfhack | localization | chinese

Usage
-----
    Auto-loads on DFHack init (SC_CORE_INITIALIZED) without requiring any
    commands.  Also exposes CLI sub-commands for manual control:

    dfzh_loader -reload
        Re-run the full installation pipeline: plugin DLL, data sync, and
        SDL2_ttf.dll.  Useful after updating mod files in-place.

    dfzh_loader -unload
        Remove installed artifacts only: hack/plugins/dfzh.plug.dll and
        hack/data/dfzh/.  Does NOT touch the mod source directory or
        SDL2_ttf.dll in the DF root.

    Both flags are mutually exclusive; supplying no flag prints this help.
]====]

local utils = require "utils"
local json = require('json')
local scriptmanager = require('script-manager')

local GLOBAL_KEY = 'dfzh_loader'

-- ============================================================================

local function get_default_state()
    return {
        loaded = false,
        load_attempted = false,
    }
end
state = state or get_default_state()


-- ============================================================================
-- Utility: ensure a directory exists (mkdir_recursive is idempotent)
-- ============================================================================
local function ensure_dir_exists(dir)
    if dfhack.filesystem.exists(dir) then
        return true
    end
    return dfhack.filesystem.mkdir_recursive(dir)
end

-- ============================================================================
-- Persisted deployment state (via json.open)
-- Stores deploy_state.json in <hack>/data/dfzh/ alongside other mod data.
-- ============================================================================
local function load_state(data_dst_dir)
    ensure_dir_exists(data_dst_dir)
    local config = json.open(data_dst_dir .. '/deploy_state.json')
    return config
end

-- ============================================================================
-- Utility: binary-safe file copy
-- ============================================================================
local function copy_file(src, dst)
    local src_f, err = io.open(src, "rb")
    if not src_f then return false, "open src: " .. (err or "unknown") end
    local dst_f, dst_err = io.open(dst, "wb")
    if not dst_f then
        src_f:close()
        return false, "open dst: " .. (dst_err or "unknown")
    end
    local data, read_err = src_f:read("*a")
    if not data then
        src_f:close()
        dst_f:close()
        return false, "read: " .. tostring(read_err or "unknown")
    end
    local ok, write_err = pcall(dst_f.write, dst_f, data)
    src_f:close()
    dst_f:close()
    if not ok then
        return false, "write: " .. tostring(write_err)
    end
    return true
end

-- ============================================================================
-- Utility: recursively remove a directory tree
-- ============================================================================
local function rmdir_recursive(dir)
    if not dfhack.filesystem.exists(dir) then
        return true
    end
    local all_ok = true
    for _, name in ipairs(dfhack.filesystem.listdir(dir) or {}) do
        local path = dir .. '/' .. name
        if dfhack.filesystem.isdir(path) then
            if not rmdir_recursive(path) then
                all_ok = false
            end
        else
            local ok, err = os.remove(path)
            if not ok then
                dfhack.printerr(string.format("[%s] Remove failed: %s (%s)", GLOBAL_KEY, name, err))
                all_ok = false
            end
        end
    end
    if all_ok then
        dfhack.filesystem.rmdir(dir)
    end
    return all_ok
end

-- ============================================================================
-- Utility: recursively copy a directory tree
-- ============================================================================
local function copy_tree(src_dir, dst_dir)
    ensure_dir_exists(dst_dir)
    local any_failed = false
    for _, name in ipairs(dfhack.filesystem.listdir(src_dir) or {}) do
        local src_path, dst_path = src_dir .. '/' .. name, dst_dir .. '/' .. name
        if dfhack.filesystem.isdir(src_path) then
            if not copy_tree(src_path, dst_path) then
                any_failed = true
            end
        else
            local ok, err = copy_file(src_path, dst_path)
            if not ok then
                dfhack.printerr(string.format("[%s] [2/3] Copy failed: %s (%s)", GLOBAL_KEY, name, err))
                any_failed = true
            end
        end
    end
    return not any_failed
end

-- ============================================================================
-- Phase 1: find and install the plugin DLL.
-- DLL naming convention: dfzh-<dfhack_version>.plug.dll
-- Destination: <hack>/plugins/dfzh.plug.dll
-- Returns: true on success (aborts entire loader on failure).
-- ============================================================================
local function install_plugin_dll(plugins_src_dir, plugins_dst_dir, dfhack_version)
    local dll_name = string.format("dfzh-%s.plug.dll", dfhack_version)
    local dll_src = plugins_src_dir .. '/' .. dll_name
    local dll_dst = plugins_dst_dir .. '/dfzh.plug.dll'

    dfhack.printerr(string.format("[%s] [1/3] Plugin DLL: Searching for %s", GLOBAL_KEY, dll_name))

    if not dfhack.filesystem.exists(dll_src) then
        dfhack.printerr(string.format(
            "[%s] [1/3] ERROR: DLL not found for DFHack %s", GLOBAL_KEY, dfhack_version))
        dfhack.printerr(string.format("[%s] [1/3] Expected: %s", GLOBAL_KEY, dll_src))

        local ok, listing = pcall(dfhack.filesystem.listdir, plugins_src_dir)
        if ok and type(listing) == "table" and #listing > 0 then
            dfhack.printerr(string.format("[%s] [1/3] Available DLLs:", GLOBAL_KEY))
            for _, f in ipairs(listing) do
                dfhack.printerr(string.format("    %s", f))
            end
        else
            dfhack.printerr(string.format(
                "[%s] [1/3] Plugin directory empty or missing: %s", GLOBAL_KEY, plugins_src_dir))
        end
        return false
    end

    ensure_dir_exists(plugins_dst_dir)

    dfhack.printerr(string.format("[%s] [1/3] Copying -> %s", GLOBAL_KEY, dll_dst))
    local ok, err = copy_file(dll_src, dll_dst)
    if not ok then
        dfhack.printerr(string.format("[%s] [1/3] Copy failed: %s", GLOBAL_KEY, err))
        return false
    end

    dfhack.printerr(string.format("[%s] [1/3] Plugin DLL installed", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- Phase 2: copy data directory to destination.
-- Existing files are removed separately before deploy, not here.
-- Requires Phase 1 success.
-- ============================================================================
local function copy_data(data_src_dir, data_dst_dir)
    dfhack.printerr(string.format("[%s] [2/3] Data copy starting\n    src : %s\n    dst : %s", GLOBAL_KEY, data_src_dir, data_dst_dir))

    if not dfhack.filesystem.exists(data_src_dir) then
        dfhack.printerr(string.format("[%s] [2/3] Source data directory not found, skipping", GLOBAL_KEY))
        return true
    end

    local ok = copy_tree(data_src_dir, data_dst_dir)
    if not ok then
        dfhack.printerr(string.format("[%s] [2/3] Data copy had errors", GLOBAL_KEY))
        return false
    end

    dfhack.printerr(string.format("[%s] [2/3] Data copy complete", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- Phase 3: copy SDL2_ttf.dll to the destination if missing.
-- Does NOT overwrite an existing file (user may have a custom build).
-- ============================================================================
local function install_sdl_ttf(sdl_ttf_src, sdl_ttf_dst)
    dfhack.printerr(string.format("[%s] [3/3] SDL2_ttf.dll check", GLOBAL_KEY))

    if dfhack.filesystem.exists(sdl_ttf_dst) then
        dfhack.printerr(string.format("[%s] [3/3] Already present in DF root, skipping", GLOBAL_KEY))
        return true
    end

    if not dfhack.filesystem.exists(sdl_ttf_src) then
        dfhack.printerr(string.format("[%s] [3/3] Source not found: %s", GLOBAL_KEY, sdl_ttf_src))
        return false
    end

    dfhack.printerr(string.format("[%s] [3/3] Copying -> %s", GLOBAL_KEY, sdl_ttf_dst))
    local ok, err = copy_file(sdl_ttf_src, sdl_ttf_dst)
    if not ok then
        dfhack.printerr(string.format("[%s] [3/3] Copy failed: %s", GLOBAL_KEY, err))
        return false
    end

    dfhack.printerr(string.format("[%s] [3/3] SDL2_ttf.dll installed", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- Remove the deployed data directory (used by deploy and unload).
-- ============================================================================
local function remove_data_dir(data_dst_dir)
    if dfhack.filesystem.exists(data_dst_dir) then
        if rmdir_recursive(data_dst_dir) then
            dfhack.printerr(string.format("[%s] Removed data: %s", GLOBAL_KEY, data_dst_dir))
        else
            dfhack.printerr(string.format("[%s] Remove data failed: %s", GLOBAL_KEY, data_dst_dir))
            return false
        end
    end

    return true
end

-- ============================================================================
-- Remove the deployed plugin DLL (used only by unload).
-- ============================================================================
local function remove_plugin_dll(dll_dst)
    if dfhack.filesystem.exists(dll_dst) then
        local ok, err = os.remove(dll_dst)
        if ok then
            dfhack.printerr(string.format("[%s] Removed plugin: %s", GLOBAL_KEY, dll_dst))
        else
            dfhack.printerr(string.format("[%s] Remove plugin failed: %s (%s)", GLOBAL_KEY, dll_dst, err))
            return false
        end
    end

    return true
end

-- ============================================================================
-- Disable and unload the dfzh plugin from DFHack.
-- Returns: true on success, false on failure.
-- ============================================================================
local function disable_unload_plugin()
    local hack_path = dfhack.getHackPath():gsub('\\', '/')
    local dll_dst = hack_path .. '/plugins/dfzh.plug.dll'
    if not dfhack.filesystem.exists(dll_dst) then return true end

    local out1, r1 = dfhack.run_command_silent('disable', 'dfzh')
    if r1 ~= 0 then
        dfhack.printerr(string.format("[%s] disable dfzh failed (ret=%s): %s", GLOBAL_KEY, tostring(r1), out1))
        return false
    end
    dfhack.printerr(string.format("[%s] disable dfzh: ok", GLOBAL_KEY))

    local out2, r2 = dfhack.run_command_silent('unload', 'dfzh')
    if r2 ~= 0 then
        dfhack.printerr(string.format("[%s] unload dfzh failed (ret=%s): %s", GLOBAL_KEY, tostring(r2), out2))
        return false
    end
    dfhack.printerr(string.format("[%s] unload dfzh: ok.", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- Load and enable the dfzh plugin in DFHack.
-- Returns: true on success, false on failure.
-- ============================================================================
local function load_enable_plugin()
    local out1, r1 = dfhack.run_command_silent('load', 'dfzh')
    if r1 ~= 0 then
        dfhack.printerr(string.format("[%s] load dfzh failed (ret=%s): %s", GLOBAL_KEY, tostring(r1), out1))
        return false
    end
    dfhack.printerr(string.format("[%s] load dfzh: ok", GLOBAL_KEY))

    local out2, r2 = dfhack.run_command_silent('enable', 'dfzh')
    if r2 ~= 0 then
        dfhack.printerr(string.format("[%s] enable dfzh failed (ret=%s): %s", GLOBAL_KEY, tostring(r2), out2))
        return false
    end
    dfhack.printerr(string.format("[%s] enable dfzh: ok", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- Unload: disable + unload from DFHack, then remove installed files.
-- Does NOT touch the mod source or SDL2_ttf.dll in DF root.
-- ============================================================================
local function unload()
    if not disable_unload_plugin() then
        dfhack.printerr(string.format("[%s] Unload failed", GLOBAL_KEY))
        return
    end

    local hack_path = dfhack.getHackPath():gsub('\\', '/')
    local data_dst_dir = hack_path .. '/data/dfzh'
    local dll_dst = hack_path .. '/plugins/dfzh.plug.dll'

    if not remove_plugin_dll(dll_dst) then
        return
    end

    if not remove_data_dir(data_dst_dir) then
        return
    end

    dfhack.printerr(string.format("[%s] Unload complete", GLOBAL_KEY))
end

-- ============================================================================
-- deploy: copy plugin DLL, data, and SDL2_ttf.dll to their destinations.
-- Parameters:
--   internal_dir    - mod's internal/ directory containing plugins/, data/, SDL2_ttf.dll
--   plugins_dst_dir - <hack>/plugins
--   data_dst_dir    - <hack>/data/dfzh
--   sdl_ttf_dst     - <DF root>/SDL2_ttf.dll
--   dfhack_version  - DFHack version string for DLL selection
--   skip_data       - if true, skip the data copy phase
-- Returns: true on success, false if critical phase fails.
-- ============================================================================
local function deploy(internal_dir, plugins_dst_dir, data_dst_dir, sdl_ttf_dst, dfhack_version, skip_data)
    dfhack.printerr(string.format("[%s] Deploy started", GLOBAL_KEY))

    local ok = install_plugin_dll(internal_dir .. '/plugins', plugins_dst_dir, dfhack_version)
    if not ok then
        dfhack.printerr(string.format("[%s] Phase 1 failed - deploy stopped", GLOBAL_KEY))
        return false
    end

    if not skip_data then
        if not remove_data_dir(data_dst_dir) then
            dfhack.printerr(string.format("[%s] Failed to remove old data, aborting.", GLOBAL_KEY))
            return false
        end
        ok = copy_data(internal_dir .. '/data', data_dst_dir)
        if not ok then
            dfhack.printerr(string.format("[%s] Phase 2 failed - deploy stopped", GLOBAL_KEY))
            return false
        end
    end

    ok = install_sdl_ttf(internal_dir .. '/SDL2_ttf.dll', sdl_ttf_dst)
    if not ok then
        dfhack.printerr(string.format("[%s] Phase 3 failed (non-fatal, continuing)", GLOBAL_KEY))
    end

    dfhack.printerr(string.format("[%s] Deploy complete", GLOBAL_KEY))
    return true
end

-- ============================================================================
-- do_loader: orchestrates (1) check -> (2) unload old -> (3) deploy -> (4) persist state -> (5) load+enable
--   force=true  -> skip version check, always deploy (used by -reload)
--   force=nil   -> check NUMERIC_VERSION in deploy_state.json
-- ============================================================================
local function do_loader(force)
    local mod_path = scriptmanager.getModSourcePath(GLOBAL_KEY):gsub('\\', '/')
    local hack_path = dfhack.getHackPath():gsub('\\', '/')
    local df_path = dfhack.getDFPath():gsub('\\', '/')
    local dfhack_version = dfhack.getDFHackVersion()

    local internal_dir = mod_path:gsub("/$", "") .. '/scripts_modinstalled/internal'
    local plugins_dst_dir = hack_path .. '/plugins'
    local data_dst_dir = hack_path .. '/data/dfzh'
    local sdl_ttf_dst = df_path .. '/SDL2_ttf.dll'

    -- Parse mod version from info.txt
    local meta = scriptmanager.get_mod_info_metadata(mod_path, {'NUMERIC_VERSION', 'DISPLAYED_VERSION'})
    local numeric_version = meta and meta.NUMERIC_VERSION
    local displayed_version = meta and meta.DISPLAYED_VERSION

    if numeric_version and displayed_version then
        dfhack.printerr(string.format("[%s] NUMERIC_VERSION(%s), DISPLAYED_VERSION(%s).",
            GLOBAL_KEY, numeric_version, displayed_version))
    end

    -- (1) Version check -- load saved state BEFORE any destructive operations
    local config = load_state(data_dst_dir)
    local saved = config.data

    if not force and numeric_version and saved.numeric_version == numeric_version then
        dfhack.printerr(string.format("[%s] Up to date, no deploy needed.", GLOBAL_KEY))
        return true
    end

    -- DISPLAYED_VERSION unchanged -> skip data copy & data removal
    local skip_data = not force and displayed_version and saved.displayed_version == displayed_version
    if skip_data then
        dfhack.printerr(string.format("[%s] DISPLAYED_VERSION unchanged, skipping data copy.", GLOBAL_KEY))
    end

    -- (2) Unload: disable + unload from DFHack
    if not disable_unload_plugin() then
        return false
    end

    -- (3) Deploy dll
    local ok = deploy(internal_dir, plugins_dst_dir, data_dst_dir, sdl_ttf_dst, dfhack_version, skip_data)
    if not ok then
        return false
    end

    -- (4) Persist deployment state for next startup comparison
    if numeric_version then
        saved.numeric_version = numeric_version
        saved.displayed_version = displayed_version
        config:write()
        dfhack.printerr(string.format("[%s] Deployment state saved.", GLOBAL_KEY))
    end

    return true
end

dfhack.onStateChange[GLOBAL_KEY] = function(sc)
    if sc == SC_CORE_INITIALIZED then
        dfhack.printerr(string.format("[%s] SC_CORE_INITIALIZED: DF(%s), DFHack(%s).",
            GLOBAL_KEY, dfhack.getDFVersion(), dfhack.getDFHackVersion()))
        dfhack.printerr(string.format("[%s] DF(%s), DFHack(%s)",
            GLOBAL_KEY, dfhack.getDFPath(), dfhack.getHackPath()))

        if not state.load_attempted then
            state.load_attempted = true
            if do_loader() then
                -- (5) Load + enable
                state.loaded = load_enable_plugin()
            end
            dfhack.printerr(string.format("[%s] Loader finished, loaded=%s",
                GLOBAL_KEY, tostring(state.loaded)))
        end
    end
end

function main(...)
    local validArgs = utils.invert({"reload", "unload"})
    local args = utils.processArgs({...}, validArgs)

    if args.unload then
        unload()
        return
    end

    if args.reload then
        dfhack.printerr(string.format("[%s] -reload: forced re-deploy", GLOBAL_KEY))
        do_loader(true)
        return
    end
    print(dfhack.script_help())
end

if not dfhack_flags.module then
    main(...)
end
