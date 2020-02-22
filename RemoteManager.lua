--[[
	Developed by:
╔═╗─╔╗──────────╔╗
║║╚╗║║─────────╔╝╚╗
║╔╗╚╝║╔══╗╔═══╗╚╗╔╝╔══╗╔═╗╔══╗
║║╚╗║║║║═╣╠══║║─║║─║╔╗║║╔╝║║═╣
║║─║║║║║═╣║║══╣─║╚╗║╚╝║║║─║║═╣
╚╝─╚═╝╚══╝╚═══╝─╚═╝╚══╝╚╝─╚══╝

https://nezto.re

getRemote: Simply fetches a remote, returns null if it does not exist.
addRemote: Create a remote. If it already exists, returns it. Also can create remoteFunctions
fetchRemote: Fetches a remote. If it does not exist, creates it.
bindEvent: Binds to the given event. Accepts a name, FunctionToBind & Permission function. Perm func is optional and should return true to allow or false to deny.
fireEvent: Fire an event from the client to the server


Remote names are case insensitive.

TODO: Once I work out how to have variable number of params, move to that.
Version: 1.0.0
--]]
local runService = game:GetService("RunService")

local module = {}

module.warn = function(msg, arg2)
	if arg2 then
		warn("RemoteManager: "..msg, arg2)
	else
		warn("RemoteManager: "..msg)
	end
	
end

module.getRemote = function(name)
	name = string.lower(name)
	local remote = script:FindFirstChild(name)

	if not remote then
		module.warn("RemoteManager: Failed to get remote with name "..name)
		return false
	end
	return remote
end

-- name: string, isFunction: bool
module.addRemote = function(name, isFunction)
	name = string.lower(name)
	local remote = script:FindFirstChild(name)

	if remote then
		module.warn("RemoteManager: Failed to create remote with name "..name.." as it already exists.")
		return remote
	else
		local n = "RemoteEvent"
		if isFunction then
			n = "RemoteFunction"
		end
		
		local newRemote = Instance.new(n)
		newRemote.Name = name
		newRemote.Parent = script
		return newRemote
	end
end

module.fetchRemote = function(name)
	name = string.lower(name)
	
	local remote = script:WaitForChild(name, 10)
	if remote then
		return remote
	else
		return module.addRemote(name)
	end
end

-- Server side only, realistically.
module.bindEvent = function(name, funcToBind, permFunc)
	local remote = module.fetchRemote(name)
	remote.OnServerEvent:connect(function(plr, one, two, three, four, five, six, seven, eight, nine, ten)
		if permFunc ~= nil then
			if permFunc(plr, one, two, three, four, five, six, seven, eight, nine, ten) then
			
				funcToBind(plr, one, two, three, four, five, six, seven, eight, nine, ten)
			else
				module.warn("Player "..plr.Name.." tried to fire "..name.. " but is not allowed.")
			end
		else
			funcToBind(plr, one, two, three, four, five, six, seven, eight, nine, ten)
		end
	end)
	
	return remote
end

-- A shortcut
module.fireEvent = function(name, one, two, three, four, five, six, seven, eight, nine, ten)
	local remote = module.fetchRemote(name)
	if not remote then
		module.warn("Failed to fire - Remote does not exist.")
		return false
	end
	if runService:IsClient() then
		remote:FireServer(one, two, three, four, five, six, seven, eight, nine, ten)
	else
		module.warn("Couldn't fire event from server. This function is only for the client.")
	end
	
end
return module
