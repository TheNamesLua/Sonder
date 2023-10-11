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
		sonder:GetItems() -- returns a table of every item currently in the sonder
	]]

    local sonder = {}
    sonder.ClassName = "Sonder"
    
    export type _SonderClass = {
        Handle : (self, thing_or_things: any)->nil,
        Release: (self, thing: any)->nil,
        Clean : (self)->nil,
        Destroy : (self)->nil,
        Supports: (self, thing: any)->boolean,
        Extends: (self)->_SonderClass,
        GetItems: (self)->any,
    }
    
    local Supported_Types = {
        "Instance",
        "RBXScriptConnection",
        "thread",
        "table",
    }
    
    local function CleanupItem(item)
        if not item then
            return
        end
    
        local type = typeof(item)
    
        pcall(function()
            if type == "Instance" then
                item:Destroy()
            end
    
            if type == "RBXScriptConnection" then
                if item.Connected then
                    item:Disconnect()
                end
            end
    
            if type == "thread" then
                coroutine.close(item)
            end
    
            if type == "table" then
                if item.Destroy then
                    item:Destroy()
                else
                    error("Error cleaning up table", 2)
                end	
            end
        end)
    end
    
    function sonder.new(): _SonderClass
        local newSonder = {}
        newSonder.ClassName = "Sonder"
        newSonder.Items = {} -- Initialize the Items table for the new object
    
        for key, value in pairs(sonder) do
            if type(value) == "function" then
                newSonder[key] = value
            end
        end
    
        setmetatable(newSonder, sonder)
        return newSonder
    end
    
    function sonder:Handle(...)
        for _, item in ipairs(table.pack(...)) do
            local _type = typeof(item)
            assert(table.find(Supported_Types, _type), `Type {_type} Is not supported with sonder. List of supported items: {table.unpack(Supported_Types)}`)
    
            table.insert(self.Items, item)
        end
    end
    
    function sonder:Release(item: any)
        local exists = table.find(self.Items, item)
    
        if exists then
            table.remove(self.Items, exists)
        end
    end
    
    function sonder:Supports(item)
        return table.find(Supported_Types, typeof(item)) ~= nil
    end
    
    function sonder:Clean()
        for _, item in ipairs(self.Items) do
            CleanupItem(item)
        end
    
        table.clear(self.Items)
    end
    
    function sonder:GetItems(): {any}
        return self.Items
    end
    
    sonder.Items = {}
    
    --@alias for sonder:Clean()
    sonder.Destroy = sonder.Clean
    --@alias for sonder.new
    sonder.Extends = sonder.new
    
    return sonder
