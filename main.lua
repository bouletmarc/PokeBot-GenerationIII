--##################################################
--#############							############
--#############			SETTING  		############
--#############							############
--##################################################

--Reset Settings
RESET_FOR_TIME = false 			-- Set to false if you just want to see the bot finish a run without reset for time
RESET_FOR_ENCOUNTERS = false 	-- Set to false if you just want to see the bot finish a run without reset for encounters

--Game Settings
GAME_NAME = "Emerald"			-- Set to Ruby/Sapphire or Emerald
GAME_HOURS = 17					-- Set the internal game hour (0-23h)
GAME_MINUTES = 35				-- Set the internal game minutes (0-59min)
GAME_GENDER = 1					-- Set the player gender (1-2 // boy-girl)

GAME_TEXT_SPEED = 2				-- Set the Text Speed (0-2 // slow-fast)
GAME_BATTLE_ANIMATION = 1		-- Set the battle animation (0-1 // no-yes)
GAME_BATTLE_STYLE = 1			-- Set the battle style (0-1 // shift-set)
GAME_SOUND_STYLE = 1			-- Set the sound style (0-1 // stereo-mono)
GAME_BUTTON_STYLE = 0			-- Set the button style (0-2)
GAME_WINDOWS_STYLE = 4			-- Set the windows style (0-19)

--Connection Settings
INTERNAL = false				-- Allow connection with LiveSplit ?
STREAMING_MODE = false			-- Enable Streaming mode

--Script Settings
CUSTOM_SEED = nil		 		-- Set to a known seed to replay it, or leave nil for random runs
PAINT_ON    = true 				-- Display contextual information while the bot runs

--Names Settings 
PLAYER_NAME = "TeStInG"			-- Player name
RIVAL_NAME = "URRival"			-- Rival name
MUDKIP_NAME = "Muddy"			-- Set Mudkip name

--NAMES SETTINGS TIPS : 
--		- Can use up to 7 letter ingame
--		- Upper, Lower case and Number allowed
--		- Specials Characters :
-- 			< = male symbol
-- 			> = female symbol
-- 			{ or } = "
-- 			[ or ] = '




--#####################################################################################
--#####################################################################################
--###########															###############
--###########   PLEASE DON'T EDIT ANYTHING BELLOW, IT'S AT YOUR RISK   	###############
--###########				 START CODE (hard hats on)					###############
--###########															###############
--#####################################################################################
--#####################################################################################

-- SET VALUES

local VERSION = "0.1-BETA"

local START_WAIT = 99
local hasAlreadyStartedPlaying = false
local oldSeconds
local running = true
local lastHP

--RUNNING4CONTINUE = false		--used to continue a game
--RUNNING4NEWGAME = true			--used to make a new game (remove last save also)
--EXTERNALDONE = false			--used when the above settings are done externally
--local InternalDone = false 		--used when the above settings are done internally

-- LOAD DIR

local LowerGameName = string.lower(GAME_NAME)

local Battle = require "action.battle"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Combat = require "ai.combat"
local Control = require "ai.control"
local Strategies = require("ai."..LowerGameName..".strategies")

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Paint = require "util.paint"
local Utils = require "util.utils"
local Settings = require "util.settings"

local Pokemon = require "storage.pokemon"

-- GLOBAL

function p(...)	--print
	local string
	if #arg == 0 then
		string = arg[0]
	else
		string = ""
		for i,str in ipairs(arg) do
			if str == true then
				string = string.."\n"
			else
				string = string..str.." "
			end
		end
	end
	print(string)
end

-- RESET

local function resetAll()
	Strategies.softReset()
	Combat.reset()
	Control.reset()
	Walk.reset()
	Paint.reset()
	Bridge.reset()
	oldSeconds = 0
	running = false
	Utils.reset()
	-- client.speedmode = 200
	
	if CUSTOM_SEED then
		Strategies.seed = CUSTOM_SEED
		p("RUNNING WITH A FIXED SEED ("..Strategies.seed.."), every run will play out identically!", true)
	else
		Strategies.seed = os.time()
		p("Starting a new run with seed "..Strategies.seed, true)
	end
	math.randomseed(Strategies.seed)
end

-- EXECUTE

local OWNER = "Bouletmarc"
p("Welcome to PokeBot Version "..VERSION, true)
p("Actually running Pokemon "..GAME_NAME.." Speedruns by "..OWNER, true)

Control.init()

--STREAMING_MODE = not walk.init()
if INTERNAL and STREAMING_MODE then
	RESET_FOR_TIME = true
end

if CUSTOM_SEED then
	client.reboot_core()
else
	hasAlreadyStartedPlaying = Utils.ingame()
end

Strategies.init(hasAlreadyStartedPlaying)
if RESET_FOR_TIME and hasAlreadyStartedPlaying then
	RESET_FOR_TIME = false
	p("Disabling time-limit resets as the game is already running. Please reset the emulator and restart the script if you'd like to go for a fast time.", true)
end
if STREAMING_MODE then
	Bridge.init()
else
	Input.setDebug(true)
end

-- MAIN LOOP

local previousMap

while true do
	local currentMap = Memory.double("game", "map")
	if currentMap ~= previousMap then
		Input.clear()
		previousMap = currentMap
	end
	--if Strategies.frames then
		--if Memory.value("game", "battle") == 0 then
	--		Strategies.frames = Strategies.frames + 1
		--end
	--	Utils.drawText(0, 80, Strategies.frames)
	--end
	--if Bridge.polling then
	--	Settings.pollForResponse()
	--end

	if not Input.update() then
		if not Utils.ingame() and currentMap == 0 then
			if running then
				if not hasAlreadyStartedPlaying then
					if emu.framecount() == 1 then client.reboot_core() end
					hasAlreadyStartedPlaying = true
				else
					resetAll()
				end
			else
				Settings.startNewAdventure(START_WAIT)
			end
		else
			if not running then
				Bridge.liveSplit()
				running = true
			end
			--local battleState = Memory.value("game", "battle")
			--Control.encounter(battleState)
			--local curr_hp = Pokemon.index(0, "hp")
			--if curr_hp == 0 and not Control.canDie() and Pokemon.index(0) > 0 then
			--	Strategies.death(currentMap)
			--elseif Walk.strategy then
			if Walk.strategy then
				if Strategies.execute(Walk.strategy) then
					Walk.traverse(currentMap)
				end
			--elseif battleState > 0 then
			--	if not Control.shouldCatch(partySize) then
			--		Battle.automate()
			--	end
			elseif Textbox.handle() then
				Walk.traverse(currentMap)
			end
		end
	end

	if STREAMING_MODE then
		local newSeconds = Memory.value("time", "seconds")
		if newSeconds ~= oldSeconds and (newSeconds > 0 or Memory.value("time", "frames") > 0) then
			Bridge.time(Utils.elapsedTime())
			oldSeconds = newSeconds
		end
	elseif PAINT_ON then
		Paint.draw(currentMap)
	end

	Input.advance()
	emu.frameadvance()
end

Bridge.close()
