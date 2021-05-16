-- // About
-- // Base instance functions for the Assembler

-- // Variables
local RunService = game:GetService("RunService")
local IXInstanceClassModule = {}

IXInstanceClassModule.__index = IXInstanceClassModule
IXInstanceClassModule.Name = "IXFrameworkAssember" 

IXInstanceClassModule.InstanceFunctions = {}
IXInstanceClassModule.VoidFunctionNames = {
	"new";
	"ConstructClassChildren";
	"ConstructClassConnections";
}

-- // Functions
function IXInstanceClassModule.InstanceFunctions:PlayAnimation(AnimationEnum, Positive)
	
end

function IXInstanceClassModule.InstanceFunctions:FindElement(ElementName, Yield)
	assert(ElementName and typeof(ElementName) == "string", "Called FindElement with invalid arguments.")
	
	local Result = self.Children[ElementName]

	if Result then return Result end
	if not Yield then return end

	repeat
		RunService.RenderStepped:Wait()
		Result = self.Children[ElementName]
	until
		Result

	return Result
end

function IXInstanceClassModule.InstanceFunctions:RegisterElement(Object)
	assert(Object and type(Object) == "userdata", "Called RegisterElement with invalid arguments.")
	
	if self.Children[Object.Name] then return self.Children[Object.Name] end
	self.Children[Object.Name] = self.Context.Assembler:AssembleClass(Object.ClassName, Object)

	return self.Children[Object.Name]
end

function IXInstanceClassModule.InstanceFunctions:Set(SettingName, SettingValue)
	assert(SettingName and typeof(SettingName) == "string", "Called RegisterElement with invalid arguments.")
	assert(SettingValue and typeof(SettingValue) == "string", "Called Set with invalid arguments.")
	
	if self.Settings then
		if self.Settings[SettingName] == nil then
			self.Context.Libary:Warn("Invalid Setting %s For Object %s (Ignoring)", SettingName, self.Name)
		end
		
		self.Settings[SettingName] = SettingValue
	else
		self.Context.Libary:Warn("Missing Settings For Object %s", self.Name)
	end
end

function IXInstanceClassModule.InstanceFunctions:Destroy(Yield)
	if Yield then wait(Yield) end
	
	if self.OnDestroyInvoked then
		self.OnDestroyInvoked()
	end
	
	if self.Object then
		self.Object:Destroy()
	end
	
	setmetatable(self.Object, {mode = "k"})
end

-- // Internal
function IXInstanceClassModule:SerailizeFunctions(ClassSource)
	local Functions = self.InstanceFunctions
	local VoidFuncs = ClassSource.Void or {}
		
	for FunctionName, FunctionCallback in pairs(Functions) do
		if not ClassSource[FunctionName] and not table.find(VoidFuncs, FunctionName) then
			ClassSource[FunctionName] = FunctionCallback
		end
	end
	
	return ClassSource
end

function IXInstanceClassModule:VoidFunctions(ClassSource)
	local Functions = self.VoidFunctionNames
	
	for FunctionIndex, FunctionName in pairs(Functions) do
		if ClassSource[FunctionName] then
			ClassSource[FunctionName] = nil
		end
	end
	
	return ClassSource
end

-- // Constructor
function IXInstanceClassModule.new(Context)
	local self = setmetatable({}, IXInstanceClassModule)
	
	self.Context = Context
	
	return self
end

return IXInstanceClassModule
