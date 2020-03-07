--[[
	Searches all scripts in instance Inst for string Str.
	Designed for large workloads - splits search into corotine blocks of 100 items, this will usually be fine.
		If you have an absolutely massive (and I mean, really big) game you might want to increase that number.
	Neztore 2020
--]]

function search(inst, str)
	local desc = inst:GetDescendants()
	for count = 1, #desc, 100 do
		local success, errorMessage = coroutine.resume(coroutine.create(function()
			local limit = count+100
			if limit > #desc then
				limit = #desc
			end
    		for inner = count, limit do
			wait()
				if not desc[inner] then
					return warn("Index "..inner.." is nil!")
				end
				if desc[inner]:isA("Script")  then
					if desc[inner].Source then
						local m, a = string.find(desc[inner].Source, str)
						if m then
							warn("!! Found in "..desc[inner]:GetFullName() .. " at position "..m)
						end
					else
						print(desc[inner]:GetFullName() .. " has no source?")
					end
				end
			end
		end))
		if not success then warn("Failed to search block "..count .. " to "..count+100) end
		
	end
end

-- EXAMPLE USAGE
search(game.Workspace, "neztore")

-- Search the entire game for string s.
local s = ""
for _, service in pairs(game:GetChildren()) do 
  local s, e = pcall(function() 
	local f = coroutine.wrap(function()
		search(service, s)
		print("Searched "..service.Name)
	end)
	f()
end)
end
