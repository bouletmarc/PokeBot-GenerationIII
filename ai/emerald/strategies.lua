
local Combat = require "ai.combat"
local Control = require "ai.control"
local Strategies = require "ai.strategies"

local Battle = require "action.battle"
local Shop = require "action.shop"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Player = require "util.player"
local Utils = require "util.utils"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

local status = Strategies.status

local strategyFunctions = Strategies.functions

--local bulbasaurScl
--local UsingSTRATS = ""

-- TIME CONSTRAINTS

Strategies.timeRequirements = {

	--[[charmander = function()
		return 2.39
	end,
	
	pidgey = function()
		local timeLimit = 7.55
		return timeLimit
	end,
	
	glitch = function()
		local timeLimit = 10.15
		if Pokemon.inParty("pidgey") then
			timeLimit = timeLimit + 0.67
		end
		return timeLimit
	end,]]
	
}

-- HELPERS

--[[local function pidgeyDSum()
	local sx, sy = Player.position()
	if status.tries == nil then
		if status.tries then
			status.tries.idx = 1
			status.tries.x, status.tries.y = sx, sy
		else
			status.tries = 0
		end
	end
	if status.tries ~= 0 and Control.escaped then
		if status.tries[status.tries.idx] == 0 then
			tries.idx = tries.idx + 1
			if tries.idx > 3 then
				tries = 0
			end
			return pidgeyDSum()
		end
		if status.tries.x ~= sx or status.tries.y ~= sy then
			status.tries[status.tries.idx] = status.tries[status.tries.idx] - 1
			status.tries.x, status.tries.y = sx, sy
		end
		sy = 47
	else
		sy = 48
	end
	if sx == 8 then
		sx = 9
	else
		sx = 8
	end
	Walk.step(sx, sy)
end

local function tackleDSum()
	local sx, sy = Player.position()
	if status.tries == nil then
		if status.tries then
			status.tries.idx = 1
			status.tries.x, status.tries.y = sx, sy
		else
			status.tries = 0
		end
	end
	if status.tries ~= 0 and Control.escaped then
		if status.tries[status.tries.idx] == 0 then
			tries.idx = tries.idx + 1
			if tries.idx > 3 then
				tries = 0
			end
			return tackleDSum()
		end
		if status.tries.x ~= sx or status.tries.y ~= sy then
			status.tries[status.tries.idx] = status.tries[status.tries.idx] - 1
			status.tries.x, status.tries.y = sx, sy
		end
		--sx = 1
	--else
		--sx = 2
	end
	if sy == 6 then
		sy = 8
	else
		sy = 6
	end
	Walk.step(sx, sy)
end]]

-- STRATEGIES

local strategyFunctions = Strategies.functions

strategyFunctions.setHour = function()
	if Strategies.initialize() then
		status.tempDir = false
	end
	local Main = Memory.value("menu", "main")
	local Current = Memory.value("menu", "settings_current")
	local Row = Memory.value("menu", "start_menu_row")
	local Hours = Memory.value("menu", "hours_row")
	local Mins = Memory.value("menu", "minutes_row")
	
	if Main == 29 then
		local Waiting = Input.isWaiting()
		if not Waiting then
			if Current == 76 then
				if Hours < GAME_HOURS then
					Input.press("Right", 0)
				elseif Hours > GAME_HOURS then
					Input.press("Left", 0)
				else
					if Mins < GAME_MINUTES then
						Input.press("Right", 0)
					elseif Mins > GAME_MINUTES then
						Input.press("Left", 0)
					else
						Input.press("A", 2)
					end
				end
			elseif Current == 78 then
				if Row == 1 then
					Input.press("Up", 2)
				else
					Input.press("A", 2)
					return true
				end
			end
		end
	else
		Input.press("A", 2)
	end
end

-- PROCESS

function Strategies.completeGameStrategy()
	status = Strategies.status
end

function Strategies.resetGame()
	--maxEtherSkip = false
	status = Strategies.status
	stats = Strategies.stats
end

return Strategies
