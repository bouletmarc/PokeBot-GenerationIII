local paths = {
	-- Inside truck
	{65, {9,9}, {12,9}},
	-- Go to Mom House
	{9, {11,17}},
	-- Mom house
	{1, {15,15}, {15,14}, {15,9}},
	-- Bedroom
	{2, {14,9}, {12,9}, {s="setDirection",dir="Up"}, {s="setHour"}, {12,9}, {14,9}, {14,8}},
	-- Dad TV Show
	{1, {15,10}, {11,12}, {15,12}, {15,16}},
	-- Go to neightbor house
	{9, {12,16}, {21,16}, {21,15}},
	-- Inside Neighbor house
	{3, {9,15}, {9,9}},
	-- Inside Bedroom
	{4, {8,9}, {8,10}, {12,10}, {s="setDirection",dir="Down"}, {s="speak"}, {8,10}, {8,8}},
	-- Inside house
	{3, {9,10}, {9,16}},
	-- Go Help prof.
	{9, {21,16}, {18,16}, {18,8}}
	
}

--Remake Path for Girl
if GAME_GENDER == 2 then
	paths[2] = {9, {20,17}}
	paths[3] = {3, {9,15}, {9,14}, {9,9}}
	paths[4] = {4, {8,9}, {10,9}, {s="setDirection",dir="Up"}, {s="setHour"}, {10,9}, {8,9}, {8,8}}
	paths[5] = {3, {9,10}, {13,12}, {9,12}, {9,16}}
	paths[6] = {9, {21,16}, {12,16}, {12,15}}
	paths[7] = {1, {15,15}, {15,9}}
	paths[8] = {2, {14,9}, {14,10}, {10,10}, {s="setDirection",dir="Down"}, {s="speak"}, {14,10}, {14,8}}
	paths[9] = {1, {15,10}, {15,16}}
	paths[10][2] = {12,16}
end

return paths
