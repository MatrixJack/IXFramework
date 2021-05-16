-- // About
-- // The module that builds IXFramework

-- // Variables
local CoreIXModules = script.Parent.Parent
local InterfaceObjects = CoreIXModules:WaitForChild("InterfaceObjects")
local ClassObjects = CoreIXModules:WaitForChild("ClassObjects")

local IXAssemblerModule = {}

IXAssemblerModule.__index = IXAssemblerModule
IXAssemblerModule.Name = "IXFrameworkAssember" 
IXAssemblerModule.ClassFunctions = {
	"ConstructClassDescendants";
	"ConstructClassConnections";
	"UpdateDefaults";
	"InitializeDefaults";
}

-- // Functions
function IXAssemblerModule:IsClass(ClassName)
	return self.InterfaceModules[ClassName] ~= nil
end

function IXAssemblerModule:FindClass(ClassName)
	local ClassValue = self.InterfaceModules[ClassName]
	
	if ClassValue then
		if typeof(ClassValue) == "string" then
			return self.InterfaceModules[ClassValue]
		else
			return ClassValue
		end
	else
		self.Context.Libary:Warn("Invalid ClassName %s", ClassName)
	end
end

function IXAssemblerModule:AssembleClass(ClassName, ...)
	local ModuleSource = self:FindClass(ClassName)
	
	if ModuleSource then
		local ConstructedClass = self.InstanceClass:SerailizeFunctions(
			ModuleSource.new(self.Context, ...)
		)
		
		for Index, Value in ipairs(self.ClassFunctions) do
			if ConstructedClass[Value] then
				ConstructedClass[Value](ConstructedClass)
			end
		end
		
		return self.Context.Libary:ToObject(
			self.InstanceClass:VoidFunctions(
				ConstructedClass
			)
		)
	end
end

function IXAssemblerModule:AssembleModules()
	for Index, ModuleObject in ipairs(InterfaceObjects:GetDescendants()) do
		if ModuleObject:IsA("ModuleScript") then
			local Source = require(ModuleObject)
			
			if Source.Aliases then
				for Index, Value in ipairs(Source.Aliases) do
					self.InterfaceModules[Value] = ModuleObject.Name
				end
			end
			
			self.InterfaceModules[ModuleObject.Name] = Source
		end
	end
end

function IXAssemblerModule:AssembleClasses()
	local InstanceClass = require(ClassObjects:WaitForChild("InstanceClass"))
	
	self.InstanceClass = InstanceClass.new(self.Context)
end

-- // Constructor
function IXAssemblerModule.new(Context)
	local self = setmetatable({}, IXAssemblerModule)
	
	self.InstanceClass = false
	self.InterfaceModules = {}
	
	self.Context = Context
	
	return self.Context.Libary:ToObject(self)
end

return IXAssemblerModule
