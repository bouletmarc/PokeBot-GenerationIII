local Strategies = {}

local Combat = require "ai.combat"
local Control = require "ai.control"

local Battle = require "action.battle"
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

--local yellow = YELLOW
local splitNumber, splitTime = 0, 0
local resetting, itemPos1, itemPos2, itemNumber

local status = {tries = 0, canProgress = nil, initialized = false, tempDir = false}
Strategies.status = status

local strategyFunctions

-- RISK/RESET

function Strategies.getTimeRequirement(name)
	return Strategies.timeRequirements[name]()
end

-- RISK/RESET

function Strategies.hardReset(message, extra, wait)
	resetting = true
	if Strategies.seed then
		if extra then
			extra = extra.." | "..Strategies.seed
		else
			extra = Strategies.seed
		end
	end
	--Reset values
	--RUNNING4CONTINUE = false
	--RUNNING4NEWGAME = true
	
	Bridge.chat(message, extra)
	if wait and INTERNAL and not STREAMING_MODE then
		strategyFunctions.wait()
	else
		client.reboot_core()
	end
	return true
end

function Strategies.reset(reason, extra, wait)
	local time = Utils.elapsedTime()
	local resetMessage = "reset"
	if time then
		resetMessage = resetMessage.." after "..time
	end
	resetMessage = resetMessage.." at "..Control.areaName
	local separator
	if Strategies.deepRun and not Control.yolo then
		separator = " BibleThump"
	else
		separator = ":"
	end
	resetMessage = resetMessage..separator.." "..reason
	if status.tweeted then
		Strategies.tweetProgress(resetMessage)
	end
	return Strategies.hardReset(resetMessage, extra, wait)
end

-- RESET TO CONTINUE

--[[function Strategies.SkipReset(message)
	RUNNING4CONTINUE = true
	EXTERNALDONE = false
	client.reboot_core()
	return true
end]]

function Strategies.death(extra)
	local reason = "Died"
	--[[local reason
	if Control.missed then
		reason = "Missed"
	elseif Control.criticaled then
		reason = "Critical'd"
	elseif Control.yolo then
		reason = "Yolo strats"
	else
		reason = "Died"
	end]]
	return Strategies.reset(reason, extra)
end

function Strategies.overMinute(min)
	if type(min) == "string" then
		min = Strategies.getTimeRequirement(min)
	end
	return Utils.igt() > (min * 60)
end

function Strategies.resetTime(timeLimit, reason, once)
	if Strategies.overMinute(timeLimit) then
		reason = "Took too long to "..reason
		if RESET_FOR_TIME then
			return Strategies.reset(reason)
		end
		if once then
			print(reason.." "..Utils.elapsedTime())
		end
	end
end

-- HELPERS

function Strategies.initialize()
	if not status.initialized then
		status.initialized = true
		return true
	end
end

--[[function Strategies.buffTo(buff, defLevel, usePPAmount, oneHit)
	if Battle.isActive() then
		status.canProgress = true
		local forced
		if not usePPAmount then
			if defLevel and Memory.double("battle", "opponent_defense") > defLevel then
				forced = buff
			end
		else
			local AvailablePP = Battle.pp(buff)
			if not oneHit then
				if AvailablePP > usePPAmount then
					forced = buff
				end
			else
				if Strategies.initialize() then
					status.tempDir = AvailablePP
				end
				if AvailablePP > status.tempDir-1 then
					forced = buff
				end
			end
		end
		Battle.automate(forced, true)
	elseif status.canProgress then
		return true
	else
		Battle.automate()
	end
end

function Strategies.dodgeUp(npc, sx, sy, dodge, offset)
	if not Battle.handleWild() then
		return false
	end
	local px, py = Player.position()
	if py < sy - 1 then
		return true
	end
	local wx, wy = px, py
	if py < sy then
		wy = py - 1
	elseif px == sx or px == dodge then
		if px - Memory.raw(npc) == offset then
			if px == sx then
				wx = dodge
			else
				wx = sx
			end
		else
			wy = py - 1
		end
	end
	Walk.step(wx, wy)
end

local function dodgeH(options)
	local left = 1
	if options.left then
		left = -1
	end
	local px, py = Player.position()
	if px * left > options.sx * left + (options.dist or 1) * left then
		return true
	end
	local wx, wy = px, py
	if px * left > options.sx * left then
		wx = px + 1 * left
	elseif py == options.sy or py == options.dodge then
		if py - Memory.raw(options.npc) == options.offset then
			if py == options.sy then
				wy = options.dodge
			else
				wy = options.sy
			end
		else
			wx = px + 1 * left
		end
	end
	Walk.step(wx, wy)
end]]

-- GENERALIZED STRATEGIES

Strategies.functions = {

	split = function(data)
		Bridge.split(data and data.finished)
		if not INTERNAL then
			splitNumber = splitNumber + 1

			local timeDiff
			splitTime, timeDiff = Utils.timeSince(splitTime)
			if timeDiff then
				print(splitNumber..". "..Control.areaName..": "..Utils.elapsedTime().." ("..timeDiff..")")
			end
		end
		return true
	end,

	interact = function(data)
		if Battle.handleWild() then
			if Battle.isActive() then
				return true
			end
			if Textbox.isActive() then
				if status.tries > 0 then
					return true
				end
				status.tries = status.tries - 1
				Input.cancel()
			elseif Player.interact(data.dir) then
				status.tries = status.tries + 1
			end
		end
	end,

	confirm = function(data)
		if Battle.handleWild() then
			if Textbox.isActive() then
				status.tries = status.tries + 1
				Input.cancel(data.type or "A")
			else
				if status.tries > 0 then
					return true
				end
				Player.interact(data.dir)
			end
		end
	end,

	setDirection = function(data)
		if Player.isFacing(data.dir) then
			return true
		else
			Input.press(data.dir, 2)
			return true
		end
	end,
	
	speak = function()
		if Strategies.initialize() then
			status.tempDir = false
		end
		if Textbox.isActive() then
			Input.press("A", 2)
			status.tempDir = true
		else
			if status.tempDir then
				status.tempDir = false
				return true
			else
				Input.press("A", 2)
			end
		end
	end,
	
	openMenu = function()
		if Textbox.isActive() then
			return true
		else
			Input.press("Start", 2)
		end
	end,
	
	closeMenu = function()
		if not Textbox.isActive() then
			return true
		else
			Input.press("B")
		end
	end,

	allowDeath = function(data)
		Control.canDie(data.on)
		return true
	end,

	--[[champion = function()
		if status.canProgress then
			if status.tries > 1500 then
				return Strategies.hardReset("Beat the game in "..status.canProgress.." !")
			end
			if status.tries == 0 then
				Bridge.tweet("Beat Pokemon "..GAME_NAME.." in "..status.canProgress.."!")
				if Strategies.seed then
					print(Utils.frames().." frames, with seed "..Strategies.seed)
					print("Please save this seed number to share, if you would like proof of your run!")
				end
			end
			status.tries = status.tries + 1
		elseif Memory.value("menu", "shop_current") == 252 then
			Strategies.functions.split({finished=true})
			status.canProgress = Utils.elapsedTime()
		else
			Input.cancel()
		end
	end]]
}

strategyFunctions = Strategies.functions

function Strategies.execute(data)
	if strategyFunctions[data.s](data) then
		status = {tries=0}
		Strategies.status = status
		Strategies.completeGameStrategy()
		-- print(data.s)
		if resetting then
			return nil
		end
		return true
	end
	return false
end

function Strategies.init(midGame)
	if not STREAMING_MODE then
		splitTime = Utils.timeSince(0)
	end
	if midGame then
		Combat.factorPP(true)
	end
end

function Strategies.softReset()
	status = {tries=0}
	Strategies.status = status
	stats = {}
	Strategies.stats = stats
	Strategies.updates = {}

	splitNumber, splitTime = 0, 0
	resetting = nil
	Strategies.deepRun = false
	Strategies.resetGame()
end

return Strategies
