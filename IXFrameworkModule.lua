-- // About
-- // Purpose; Entrypoint and Context to an Interface System

-- // Variables
local CoreIXModules = script.Parent:WaitForChild("CoreIXModules")
local IXDependencies = CoreIXModules:WaitForChild("IXDependencies")

local IXEnum = require(IXDependencies:WaitForChild("IXEnums"))
local IXLibary = require(IXDependencies:WaitForChild("IXLibary"))
local IXSettings = require(IXDependencies:WaitForChild("IXSettings"))
local IXAssembler = require(IXDependencies:WaitForChild("IXAssembler"))

local IXFrameworkModule = {}

IXFrameworkModule.__index = IXFrameworkModule
IXFrameworkModule.Name = "IXFramework" 

-- // General API
function IXFrameworkModule:RecursiveGetChildren(Object)
	local ChildrenObjects = {}
	
	for Index, Value in pairs(Object.Children) do
		if Value.Children then
			ChildrenObjects[("%s (%s)"):format(Value.Object.Name, Value.Name)] = self:RecursiveGetChildren(Value)
		else
			table.insert(ChildrenObjects, ("%s (%s)"):format(Value.Object.Name, Value.Name))
		end
	end

	return ChildrenObjects
end

function IXFrameworkModule:DisplayTree()
	local ChildrenObjects = {}
	
	for Index, Value in pairs(self.Interface.Children) do
		ChildrenObjects[("%s (%s)"):format(Value.Object.Name, Value.Name)] = self:RecursiveGetChildren(Value)
	end
	
	print({[self.Interface] = ChildrenObjects})
end

function IXFrameworkModule:RegisterInterface(GuiObject)
	self.Interface = self.Assembler:AssembleClass("InterfaceClass", GuiObject)
	
	return self.Interface
end

function IXFrameworkModule:PreloadInterface()
	
end

-- // Constructor
function IXFrameworkModule.new()
	local self = setmetatable({}, IXFrameworkModule)
	
	self.Classes = {}
	
	self.Libary = IXLibary
	self.Interface = false
	
	self.Enum = IXEnum.new(self)
	self.Settings = IXSettings.new(self)
	self.Assembler = IXAssembler.new(self)
	
	self.Assembler:AssembleClasses()
	self.Assembler:AssembleModules()

	return self.Libary:ToObject(self)
end

return IXFrameworkModule
