--[[

	Developed by:
╔═╗─╔╗──────────╔╗
║║╚╗║║─────────╔╝╚╗
║╔╗╚╝║╔══╗╔═══╗╚╗╔╝╔══╗╔═╗╔══╗
║║╚╗║║║║═╣╠══║║─║║─║╔╗║║╔╝║║═╣
║║─║║║║║═╣║║══╣─║╚╗║╚╝║║║─║║═╣
╚╝─╚═╝╚══╝╚═══╝─╚═╝╚══╝╚╝─╚══╝
https://nezto.re

This is a newer, simplified version of the previous remote manager.


Provides an easy way to access remote functions and events and be sure they exist.
Methods check if the requested item exists. If it does, it returns it.
Additionally supports scoping, e.g. Remotes:scope("fire"):event("water")
Scopes and instance names are case insensitive.
Can be run on both the client, and the server. Items will be only be created if on the server.
]]


-- Imports & Config
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DefaultParent = ReplicatedStorage:WaitForChild("remotes", 2)
if not DefaultParent then
  DefaultParent = Instance.new("Folder", ReplicatedStorage)
  DefaultParent.name = "remotes"
end

if not DefaultParent then
    DefaultParent = Instance.new("Folder", ReplicatedStorage)
    DefaultParent.Name = "remotes"
end

local RemoteManger = {}
RemoteManger.__index = RemoteManger

function RemoteManger.new(Parent)
    local newManger = {}
    setmetatable(newManger, RemoteManger)
    newManger.Parent = Parent;

    return newManger
end

-- Returns the event if it does not already exist.
function RemoteManger:event(name)
    return self:Get(name, "RemoteEvent")
end

-- Gets a remote function.
function RemoteManger:func(name)
    return self:Get(name, "RemoteFunction")
end

function  RemoteManger:Get(name, type)
    local loweredName = string.lower(name)
    local existing = findOfType(self.Parent, type, loweredName)
    return existing or TryCreate(loweredName, loweredName, self.Parent)
end

-- Gets a given scope. If on the client, returns nil.
-- Otherwise returns a RemoteManager of the provided scope.
function RemoteManger:scope(name)
    local lowerName = string.lower(name)
    local child = self.Parent:FindFirstChild(lowerName)
    if child ~= nil then
        return RemoteManger.new(child)
    else
        local newScope = TryCreate("Folder", name, self.Parent)
        if newScope then
            return RemoteManger.new(newScope)
        end
    end
end

-- Will yield for 1 second and try again.
function findOfType(Parent, type, name, secondTry)
    for _, v in pairs(Parent:GetChildren()) do
        if v:IsA(type) and string.lower(v.Name) == name then
            return v;
        end
    end
    if not secondTry then
        wait(1)
        findOfType(Parent, type, name, true)
    end
end


-- Checks if on the server or client, and creates the item if on the server.
function TryCreate(type, name, parent)
    if not RunService:IsClient() then
        local newItem = Instance.new(type)
        newItem.Name = name
        newItem.Parent = parent;
        return newItem;
    end
end

local defaultManager = RemoteManger.new(DefaultParent)
return defaultManager
