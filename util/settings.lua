local Settings = {}

local Textbox = require "action.textbox"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Utils = require "util.utils"

local settings_done = false
local Setting_done = false

local desired = {}
desired.text_speed = GAME_TEXT_SPEED
desired.battle_animation = GAME_BATTLE_ANIMATION
desired.battle_style = GAME_BATTLE_STYLE
desired.sound_style = GAME_SOUND_STYLE
desired.button_style = GAME_BUTTON_STYLE
desired.windows_style = GAME_WINDOWS_STYLE

local function isEnabled(name)
	return Memory.value("setting", name) == desired[name]
end

-- PUBLIC

function Settings.set(...)
	--set vars
	local startMenu = Memory.value("menu", "main")
	local menuRow = Memory.value("menu", "row")
	
	--set settings
	if not settings_done then
		for i,name in ipairs(arg) do
			if not isEnabled(name) then
				--open settings menu
				if startMenu ~= 51 then
					if menuRow ~= 1 then
						Input.press("Down", 2)
					else
						Input.press("A", 2)
					end
				--set options
				else
					Menu.setOption(name, desired[name])
				end
				return false
			end
		end
		--setting done
		settings_done = true
	end
	
	--close option menu
	if startMenu == 51 then
		Input.press("B", 2)
	end
	if startMenu ~= 51 then
		settings_done = false
		return true
	end
end

function Settings.startNewAdventure(startWait)
	local startMenu = Memory.value("menu", "main")
	--local MenuCurrent = Memory.value("menu", "current")
	local SettingsCurrent = Memory.value("menu", "settings_current")
	local Row = Memory.value("menu", "row")
	local GenderRow = Memory.value("menu", "settings_row")
	
	--press A
	if startMenu == 30 then
		Input.press("A", 2)
	--press Start
	elseif startMenu == 180 or startMenu == 20 or startMenu == 23 then
		if not Setting_done and math.random(0, startWait) == 0 then
			Input.press("Start")
		end
	--set settings
	elseif startMenu == 49 or startMenu == 51 then
		if not Setting_done then
			if Settings.set("text_speed", "battle_animation", "battle_style", "sound_style", "button_style", "windows_style") then
				Setting_done = true
			end
		else
			if Row ~= 0 then
				Input.press("Up", 2)
			else
				Input.press("A", 2)
			end
		end
	--Set Gender
	elseif startMenu == 19 then
		if SettingsCurrent == 13 or SettingsCurrent == 14 then
			if GenderRow == 1 and GAME_GENDER == 2 then
				Input.press("Down", 2)
			elseif GenderRow == 2 and GAME_GENDER == 1 then
				Input.press("Up", 2)
			else
				Input.press("A", 2)
			end
		else
			Input.press("A", 2)
		end
	--Set Name&start adventure
	elseif startMenu == 31 then
		if SettingsCurrent < 100 then
			--reset setting not done
			Setting_done = false
			--set our name
			Textbox.name(PLAYER_NAME, true)
		else
			--start adventure
			Input.press("A", 2)
		end
	else
		Input.press("A", 2)
	end
end

return Settings
