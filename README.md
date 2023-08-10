# Sonder
Custom State Management Class

Source:
```
--!nocheck

--[[
	// File Name: Sonder.lua
	// Author: TheNamesLua
	// Description: A lightweight class for managing game state

	--| METHODS |--
	@sonder.new()
	
	sonder:Handle(item: any) -- will add item to sonder
	sonder:Release(item: any) -- will remove an item from a sonder
	sonder:Clean() -- will clean up any items in the sonder
	sonder:Destroy() -- alias for sonder:Clean()
	sonder:Supports(item) -- will tell you if an item is supported by Sonder
	sonder:Extends() -- returns a new empty sonder object
]]

local sonder = {}
sonder.__index = sonder

export type _SonderClass = {
	Hold : (self, thing: any)->nil,
	Release: (self, thing: any)->nil,
	Clean : (self)->nil,
	Destroy : (self)->nil,
	Supports: (self, thing: any)->boolean,
	Extends: (self)->_SonderClass,
}

local Supported_Types = {
	"Instance",
	"RBXScriptConnection",
	"thread",
	"table",
}

local function CleanupItem(item)
	local type = typeof(item)

	local passed, err = pcall(function()
		if type == "Instance" then
			item:Destroy()
		elseif type == "RBXScriptConnection" then
			if item.Connected then
				item:Disconnect()
			end
		elseif type == "thread" then
			coroutine.close(item)
		elseif type == "table" then
			if item.Destroy then
				item:Destroy()
			else
				error("Error cleaning up table", 2)
			end
		end
	end)

	if not passed then
		error(err)
	end
end

function sonder.new(): _SonderClass
	return setmetatable(sonder, sonder)
end

function sonder:Hold(item: any)
	local _type = typeof(item)
	assert(table.find(Supported_Types, _type), `Type {_type} Is not supported with sonder. List of supported items: {table.unpack(Supported_Types)}`)
	
	table.insert(self.Items, item)
end

function sonder:Release(item: any)
	local exists = table.find(self.Items, item)
	
	if exists then
		table.remove(self.Items, exists)
	end
end

function sonder:Supports(item)
	if table.find(Supported_Types, typeof(item)) then
		return true
	end
	
	return false
end

function sonder:Clean()
	for index, item in ipairs(self.Items) do
		CleanupItem(item)
	end
	
	table.clear(self.Items)
end

sonder.Items = {}

--@alias for sonder:Clean()
sonder.Destroy = sonder.Clean
sonder.Extends = sonder.new

return sonder
```
