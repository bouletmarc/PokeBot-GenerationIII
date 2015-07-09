local Memory = {}

local memoryNames = {
	setting = {
		text_speed = 0x5E0A,		--139-136-128
		battle_animation = 0x5E0C,	--141=on 133=off
		battle_style = 0x5E0E,		--135=shift 132=set
		sound_style = 0x5E10,		--142=mono 145=stereo
		button_style = 0x5E12,		--
		windows_style = 0x5E14,		--0 to 7
	},
	text_inputing = {
		column = 0x2065E,
		row = 0x20660,
		mode = 0x206A4,
	},
	--[[inventory = {
		item_count = 0x1892,
		item_base = 0x1893,
	},]]
	menu = {
		row = 0x5E0A,
		input_row = 0x5E08,
		settings_row = 0x5E14,
		start_menu_row = 0x3CD92,
		hours_row = 0x5E0C,		--(0-23)
		minutes_row = 0x5E0E,	--(0-59)
		
		--item_row = 0x110C,
		--item_row_size = 0x110D,
		
		column = 0x3CE5D,
		current = 0x0820,		--
		--size = 0x0FA3,
		main_current = 0x5E00,
		option_current = 0x0859,
		settings_current = 0x5E01,
		--shop_current = 0x0F87,
		--selection = 0x0F78,
		text_input = 0x20667,	--1=inputing
		text_length = 0x217FA,	-- -7
		main = 0x0819,
		--pokemon = 0x0C51,			--TO DO, USED WHILE EVOLVING
		--selection_mode = 0x0C35,	--TO DO, USED WHEN SWAPING MOVE
		--transaction_current = 0x0F8B,--TODO, USED FOR SHOPPING
	},
	player = {
		--name = 0x147D,
		--name2 = 0x1493,
		moving = 0x37593,		--1 = moving
		facing = 0x37368,		--17=S // 34=N // 51=W // 68=E
		--repel = 0x1CA1,
		--party_size = 0x1CD7,
	},
	game = {
		--battle = 0x122D,		--1=wild 2=trainer
		ingame = 0x0E08,
		textbox = 0x0E40,
		--textbox = 0x5DF0,
		--textboxing = 0x5ECC,
	},
	time = {
		--hours = 0x24A87,
		--minutes = 0x24A88,
		--seconds = 0x24A89,
		--frames = 0x24A8A,
		frames = 0x249C0,
	},
	--[[shop = {
		--transaction_amount = 0x110C,
	},]]
	battle = {
		text = 0x24068,				--
		menu = 0x5D60,				--106=106(att) // 186=94(main) // 128=233(item) // 145=224(pkmon)
		--menuX = 0x0FAA,				--used for battle menu Row-X
		--menuY = 0x0FA9,				--used for battle menu Row-Y
		--battle_turns = 0x06DD,		--USED FOR DSUM ESCAPE??
		
		opponent_id = 0x240DC,		--or 0x1204??
		opponent_level = 0x24106,
		opponent_type1 = 0x240FD,
		opponent_type2 = 0x240FE,
		--opponent_move_id = 0x240E8,	--used to get opponent moves ID's
		--opponent_move_pp = 0x24100,	--used to get opponent moves PP's

		our_id = 0x24084,
		--our_status = 0x063A,
		our_level = 0x240AE,
		our_type1 = 0x240A5,
		our_type2 = 0x240A6,
		--our_move_id = 0x24090,		--used to get our moves ID's
		--our_move_pp = 0x240A8,		--used to get our moves PP's
		
		--our_pokemon_list = 0x1288	--used to retract any of our Pokemons values (slot 1-6)
		
		--attack_turns = 0x06DC,	--NOT USED??
		--accuracy = 0x0D1E,		--NOT DONE YET
		--x_accuracy = 0x1063,		--NOT DONE YET
		--disabled = 0x0CEE,		--NOT DONE YET
		--paralyzed = 0x1018,		--NOT DONE YET
		--critical = 0x105E,		--NOT DONE YET
		--miss = 0x105F,			--NOT DONE YET
		--our_turn = 0x1FF1,		--NOT DONE YET
		
		--opponent_next_move = 0xC6E4,	--NOT USED??
		--opponent_last_move = 0x0FCC,	--NOT DONE YET AND NOT USED??
		--opponent_bide = 0x106F,		--NOT DONE YET AND NOT USED??
	},
	
	--[[pokemon = {
		exp1 = 0x1179,
		exp2 = 0x117A,	--NOT DONE YET
		exp3 = 0x117B,
	},]]
}

local doubleNames = {
	battle = {
		opponent_hp = 0x24104,
		opponent_max_hp = 0x24108,
		opponent_attack = 0x240DE,
		opponent_defense = 0x240E0,
		opponent_speed = 0x240E2,
		opponent_special_attack = 0x240E4,
		opponent_special_defense = 0x240E6,

		our_hp = 0x240AC,
		our_max_hp = 0x240B0,
		our_attack = 0x24086,
		our_defense = 0x24088,
		our_speed = 0x2408A,
		our_special_attack = 0x2408C,
		our_special_defense = 0x2408E,
	},
	
	game = {
		map = 0x37359,
	},
	
	player = {
		x = 0x37364,
		y = 0x37366,
	},
	
	--[[pokemon = {
		attack = 0x117E,
		defense = 0x1181,	--NOT DONE YET
		speed = 0x1183,
		special = 0x1185,
	},]]
}

local function raw(address)
	if string.len(tostring(address)) == 6 then
		memory.usememorydomain("EWRAM")
	else
		memory.usememorydomain("IWRAM")
	end
	return memory.readbyte(address)
end
Memory.raw = raw

function Memory.string(first, last)
	local a = "ABCDEFGHIJKLMNOPQRSTUVWXYZ():;[]abcdefghijklmnopqrstuvwxyz?????????????????????????????????????????-???!.????????*?/.?0123456789"
	local str = ""
	while first <= last do
		local v = raw(first) - 127
		if v < 1 then
			return str
		end
		str = str..string.sub(a, v, v)
		first = first + 1
	end
	return str
end

function Memory.double(section, key)
	local first = doubleNames[section][key]
	return raw(first) + raw(first + 1)
end

function Memory.value(section, key)
	local memoryAddress = memoryNames[section]
	if key then
		memoryAddress = memoryAddress[key]
	end
	return raw(memoryAddress)
end

function Memory.getAddress(section, key)
	local memoryAddress = memoryNames[section]
	if key then
		memoryAddress = memoryAddress[key]
	end
	return memoryAddress
end

return Memory
