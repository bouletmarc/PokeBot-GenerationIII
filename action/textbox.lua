local Textbox = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"

local alphabet_upper = "ABCDEF .GHIJKL ,MNOPQRS TUVWXYZ "
local alphabet_lower = "abcdef .ghijkl ,mnopqrs tuvwxyz "
local alphabet_number = "01234 56789 !?<>/- _{}[] "
-- < = male symbol
-- > = female symbol
-- { or } = "
-- [ or ] = '

local TableNumber = 1
local ActualUpper = 1

local function getIndexForLetter(letter, Mode)
	if Mode == "Upper" then
		return alphabet_upper:find(letter, 1, true)
	elseif Mode == "Lower" then
		return alphabet_lower:find(letter, 1, true)
	elseif Mode == "Number" then
		return alphabet_number:find(letter, 1, true)
	end
end

function Textbox.name(letter, randomize)
	local inputting = Memory.value("menu", "text_input")
	if inputting then
		-- Set vars
		local lidx
		local drow
		local dcol
		local NameTable = {}
		local ColumnMax
		--Get values
		local crow = Memory.value("text_inputing", "row")
		local ccol = Memory.value("text_inputing", "column")
		local mode = Memory.value("text_inputing", "mode")
		
		--if letter then
			local StringLenght = string.len(letter)
			letter:gsub(".",function(letter2)
				table.insert(NameTable,letter2)
				
				if NameTable[TableNumber] then
					local Mode = "Upper"
					
					--its a letter
					if string.match(NameTable[TableNumber], '%a') then
						if string.match(NameTable[TableNumber], '%u') then
							Mode = "Upper"
						elseif string.match(NameTable[TableNumber], '%l') then
							Mode = "Lower"
						end
					--its a number
					elseif string.match(NameTable[TableNumber], '%d') then
						Mode = "Number"
					--its anything but not a letter or a number
					else
						if string.find(alphabet_upper, NameTable[TableNumber]) ~= nil then
							Mode = "Upper"
						elseif string.find(alphabet_lower, NameTable[TableNumber]) ~= nil then
							Mode = "Lower"
						elseif string.find(alphabet_number, NameTable[TableNumber]) ~= nil then
							Mode = "Number"
						end
					end
					
					--Set lidx
					lidx = getIndexForLetter(NameTable[TableNumber], Mode)
					
					local Waiting = Input.isWaiting()
					
					--Proceed
					if not Waiting then
						--Get/set Lower/Upper
						if Mode == "Upper" and mode ~= 0 or Mode == "Lower" and mode ~= 1 or Mode == "Number" and mode ~= 2 then
							if mode == 2 then
								ColumnMax = 6
							else
								ColumnMax = 8
							end
							if crow ~= 0 then
								Input.press("Up", 2)
							elseif crow == 0 then
								if ccol < ColumnMax then
									Input.press("Right", 2)
								else
									Input.press("A", 2)
								end
							end
						--Get/Set Letter
						else
							if mode == 2 then
								ColumnMax = 6
							else
								ColumnMax = 8
							end
							dcol = math.fmod(lidx - 1, ColumnMax)
							if ccol < dcol then
								Input.press("Right", 2)
							elseif ccol > dcol then
								Input.press("Left", 2)
							elseif ccol == dcol then
								drow = math.ceil(lidx/ColumnMax)-1
								if crow < drow then
									Input.press("Down", 2)
								elseif crow > drow then
									Input.press("Up", 2)
								elseif crow == drow then
									Input.press("A", 2)
									TableNumber = TableNumber + 1
								end
							end
						end
					end
				end
			end)
			
			local Waiting = Input.isWaiting()
			
			if TableNumber > StringLenght and not Waiting then
				if Memory.value("menu", "text_length")-7 > 0 then
					if mode == 2 then
						ColumnMax = 6
					else
						ColumnMax = 8
					end
					--get column/row
					if crow ~= 2 and ccol ~= ColumnMax then
						Input.press("Start", 2)
					elseif crow == 2 and ccol == ColumnMax then
						Input.press("A", 2)
						TableNumber = 1
						ActualUpper = 1
						NameTable = {}
						return true
					end
				end
			end
		--[[else
			if Memory.value("menu", "text_length")-7 > 0 then
				Input.press("Start")
				return true
			end
			
			lidx = nidoIdx
			
			crow = Memory.value("menu", "input_row")
			drow = math.ceil(lidx / 9)
			if Menu.balance(crow, drow, true, 6, true) then
				ccol = math.floor(Memory.value("menu", "column") / 2)
				dcol = math.fmod(lidx - 1, 9)
				if Menu.sidle(ccol, dcol, 9, true) then
					Input.press("A")
				end
			end]]
		--end
	else
		--Reset Values
		TableNumber = 1
		ActualUpper = 1
		NameTable = {}
		
		if randomize then
			Input.press("A", math.random(1, 5))
		else
			Input.press("A", 2)
			--Input.cancel()
		end
	end
end

function Textbox.isActive()
	local Active = false
	--if Memory.value("game", "textbox") == 1 or Memory.value("game", "textboxing") == 1 then
	if Memory.value("game", "textbox") > 0 then
		Active = true
	end
	return Active
end

function Textbox.handle()
	if not Textbox.isActive() then
		return true
	end
	Input.cancel()
end

return Textbox
