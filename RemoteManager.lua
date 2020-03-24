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
bind: Binds to the given event or function. Accepts a name, FunctionToBind & Permission function. Perm func is optional and should return true to allow or false to deny.
fire: Fire an event or a function from the client to the server


Remote names are case insensitive.

Version: 1.1.0
--]]
local runService = game:GetService("RunService")

local module = {}

module.warn = function(o, ...)
	warn("RemoteManager: "..o, ...)
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

module.fetchRemote = function(name, isFunction)
	name = string.lower(name)
	
	local remote = script:WaitForChild(name, 0.5)
	if remote then
		return remote
	else
		if not runService:IsClient() then
			return module.addRemote(name, isFunction)
		else
			warn("Cannot create (fetchEvent) as on client.")
			return nil
		end
		
	end
end

-- Server side only, realistically.


-- Supports binding both functions and events. 
module.bind = function(name, funcToBind, permFunc, isFunction)
	local remote = module.fetchRemote(name, isFunction)
	
	local isEvent = remote:IsA("RemoteEvent")

	local function bindFunc (plr, ...)
		if permFunc ~= nil then
			-- not clean but theres no other way to return "all" values from it.
			local allowed, a,b,c,d,f,g = permFunc(plr, ...) 
			if allowed then
				return funcToBind(plr, ...)
			else
				if not b then module.warn("Player "..plr.Name.." tried to fire "..name.. " but is not allowed.") end
				return allowed, a, b, c,d,f,g
			end
		else
			return funcToBind(plr, ...)
		end
	end
	
	if isEvent then
		remote.OnServerEvent:connect(bindFunc)
	else
		remote.OnServerInvoke = bindFunc
	end
	
	
	
	return remote
end


-- A shortcut
module.fire = function(name, ...)
	local remote = module.getRemote(name)
	if not remote then
		module.warn("Failed to fire - Remote does not exist.")
		return false
	end
	local isEvent = remote:IsA("RemoteEvent")
	
	if runService:IsClient() then
		if isEvent then
			return remote:FireServer(...)
		else
			return remote:InvokeServer(...)
		end
		
	else
		
		module.warn("Couldn't fire event from server. This function is only for the client.")
		return nil, "Cannot be used on server!"
	end
	
end

-- Old aliases
module.bindEvent = module.bind
module.fireEvent = module.fire

	
return module
