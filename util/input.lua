local Input = {}

local Bridge = require "util.bridge"
local Memory = require "util.memory"
local Utils = require "util.utils"

local lastSend
local currentButton, remainingFrames, setForFrame
local debug
local bCancel = true

local drawText = Utils.drawText

local Waiting = false

local function bridgeButton(btn)
	if btn ~= lastSend then
		lastSend = btn
		Bridge.input(btn)
	end
end

--local function sendButton(button, ab, hold, newgame)
--local function sendButton(button, ab, hold)
local function sendButton(button, ab, slow)
	local inputTable = {}
	if slow ~= nil then
		if slow == false then
			inputTable = {[button]=true, B=true}
		else
			inputTable = {[button]=true}
		end
	else
		inputTable = {[button]=true}
	end
	--else
		--if not newgame then
		--	inputTable = {[button]=true}
		--else
		--	inputTable = {Up=true, B=true, Select=true}
		--end
	--end
	joypad.set(inputTable)
	if debug then
		if slow ~= nil then
			if slow == true then
				drawText(0, 60, button.."+B "..remainingFrames)
			else
				drawText(0, 60, button.." "..remainingFrames)
			end
		else
			drawText(0, 60, button.." "..remainingFrames)
		end
	end
	if ab then
		button = "A,B"
	end
	bridgeButton(button)
	setForFrame = button
end

function Input.isWaiting()
	if setForFrame and not Waiting then
		Waiting = true
	elseif not setForFrame and Waiting then
		Waiting = false
	end
	return Waiting
end

--function Input.press(button, frames, hold, newgame)
--function Input.press(button, frames, hold)
function Input.press(button, frames, slow)
	if setForFrame then
		print("ERR: Reassigning "..setForFrame.." to "..button)
		return
	end
	if frames == nil or frames > 0 then
		if button == currentButton then
			return
		end
		if not frames then
			frames = 1
		end
		currentButton = button
		remainingFrames = frames
	else
		remainingFrames = 0
	end
	bCancel = button ~= "B"
	
	--sendButton(button, false)
	sendButton(button, false, slow)
	--sendButton(button, false, hold, newgame)
end

--function Input.cancel(accept)
function Input.cancel()
	--if accept and Memory.value("menu", "shop_current") == 20 then
	--if accept and Memory.value("menu", "shop_current") == 30 then
	--	Input.press(accept)
	--else
		local button
		if bCancel then
			button = "B"
		else
			button = "A"
		end
		sendButton(button, true)
		--sendButton(button, false)
		bCancel = not bCancel
	--end
end

function Input.escape()
	local rowSelected = Memory.value("battle", "menuY")
	local columnSelected = Memory.value("battle", "menuX")
	if not Input.isWaiting() then
		if rowSelected == 1 then
			Input.press("Down", 2)
		else
			if columnSelected == 1 then
				Input.press("Right", 2)
			else
				Input.press("A", 2)
			end
		end
	end
end

function Input.clear()
	currentButton = nil
	remainingFrames = -1
end

function Input.update()
	if currentButton then
		remainingFrames = remainingFrames - 1
		if remainingFrames >= 0 then
			if remainingFrames > 0 then
				sendButton(currentButton)
				return true
			end
		else
			currentButton = nil
		end
	end
	setForFrame = nil
end

function Input.advance()
	if not setForFrame then
		bridgeButton("e")
	end
end

function Input.setDebug(enabled)
	debug = enabled
end

return Input

