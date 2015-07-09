local Utils = {}

local Memory = require "util.memory"

local EMP = 1

-- GENERAL

function Utils.dist(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

function Utils.each(table, func)
	for key,val in pairs(table) do
		func(key.." = "..tostring(val)..",")
	end
end

function Utils.eachi(table, func)
	for idx,val in ipairs(table) do
		if val then
			func(idx.." "..val)
		else
			func(idx)
		end
	end
end

function Utils.match(needle, haystack)
	for i,val in ipairs(haystack) do
		if needle == val then
			return true
		end
	end
	return false
end

function Utils.key(needle, haystack)
	for key,val in pairs(haystack) do
		if needle == val then
			return key
		end
	end
	return nil
end

function Utils.capitalize(string)
	return string:sub(1, 1):upper()..string:sub(2)
end

-- GAME

function Utils.canPotionWith(potion, forDamage, curr_hp, max_hp)
	local potion_hp
	if potion == "full_restore" then
		potion_hp = 9001
	elseif potion == "super_potion" then
		potion_hp = 50
	else
		potion_hp = 20
	end
	return math.min(curr_hp + potion_hp, max_hp) >= forDamage - 1
end

function Utils.ingame()
	return Memory.value("game", "ingame") > 0
end

function Utils.onPokemonSelect(battleMenu)
	--return battleMenu == 8 or battleMenu == 48 or battleMenu == 184 or battleMenu == 224
	return battleMenu == 145
end

function Utils.drawText(x, y, message)
	gui.text(x * EMP, y * EMP, message)
end

-- TIME

local Hours = 0
local Minutes = 0
local Seconds = 0
local Current_frame = 0
local Current_frame_changed = 0

function Utils.reset()
	Hours = 0
	Minutes = 0
	Seconds = 0
	Current_frame = 0
	Current_frame_changed = 0
end

function Utils.igt()
	local hours = Hours
	local mins = Minutes
	local secs = Seconds
	return (hours * 60 + mins) * 60 + secs
end

local function clockSegment(unit)
	if unit < 10 then
		unit = "0"..unit
	end
	return unit
end

function Utils.timeSince(prevTime)
	local currTime = Utils.igt()
	local diff = currTime - prevTime
	local timeString
	if diff > 0 then
		local secs = diff % 60
		local mins = math.floor(diff / 60)
		timeString = clockSegment(mins)..":"..clockSegment(secs)
	end
	return currTime, timeString
end

function Utils.elapsedTime()
	if not Utils.ingame() then
		return "0:00:00"
	else
		--local secs = Memory.value("time", "seconds")
		--local mins = Memory.value("time", "minutes")
		--local hours = Memory.value("time", "hours")
		local frames = Memory.value("time", "frames")
		if Current_frame ~= frames then
			Current_frame = frames
			Current_frame_changed = Current_frame_changed + 1
			if Current_frame_changed == 60 then
				Current_frame_changed = 0
				Seconds = Seconds + 1
				if Seconds == 60 then
					Seconds = 0
					Minutes = Minutes + 1
					if Minutes == 60 then
						Minutes = 0
						Hours = Hours + 1
					end
				end
			end
		end
		return Hours..":"..clockSegment(Minutes)..":"..clockSegment(Seconds)
	end
end

--[[function Utils.frames()
	if Utils.ingame() then
	
	else
	local totalFrames = Memory.value("time", "hours") * 60
	totalFrames = (totalFrames + Memory.value("time", "minutes")) * 60
	totalFrames = (totalFrames + Memory.value("time", "seconds")) * 60
	totalFrames = totalFrames + Memory.value("time", "frames")
	return totalFrames
end]]

return Utils
