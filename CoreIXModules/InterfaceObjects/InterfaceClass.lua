-- // About
-- // Base instance functions for the Assembler

-- // Variables
local RunService = game:GetService("RunService")
local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXInterfaceClass" 
IXObjectClassModule.Aliases = {"ScreenGui"}
IXObjectClassModule.Void = {"RegisterElement", "FindElement"}

-- // Functions
function IXObjectClassModule:Enable()
	
end

function IXObjectClassModule:Disable()
	
end

function IXObjectClassModule:FindClass(ClassName, Yield)
	local Result = self.Children[ClassName]

	if Result then return Result end
	if not Yield then return end

	repeat
		RunService.RenderStepped:Wait()
		Result = self.Children[ClassName]
	until
	Result

	return Result
end

function IXObjectClassModule:RegisterClass(Object)
	if self.Children[Object.Name] then return self.Children[Object.Name] end
	self.Children[Object.Name] = self.Context.Assembler:AssembleClass("MasterClass", Object)

	return self:RegisterClass(Object)
end

-- // Internal
function IXObjectClassModule:ConstructClassDescendants()
	for Index, Child in ipairs(self.Object:GetChildren()) do
		if Child:IsA("Frame") and not Child:GetAttribute("Disabled") then
			self:RegisterClass(Child)
		end
	end
end

function IXObjectClassModule:ConstructClassConnections()
	self.Object:GetPropertyChangedSignal("Parent"):Connect(function()
		if self.Object.Parent == nil then
			local ParentObject = self.Object.Parent
			local IntegrityCheck = pcall(function() self.Object.Parent = workspace end)

			if IntegrityCheck then
				self.Object.Parent = ParentObject
			else
				self:Destroy()
			end
		end
	end)
	
	self.Object.ChildAdded:Connect(function(Child)
		if Child:IsA("Frame") and not Child:GetAttribute("Disabled") then
			self:RegisterClass(Child)
		end
	end)
	
	self.Object.ChildRemoved:Connect(function(Child)
		self.Children[Child.Name] = false
	end)
end

-- // Constructor
function IXObjectClassModule.new(Context, Object)
	local self = setmetatable({}, IXObjectClassModule)
	
	self.Object = Object
	self.Context = Context
	
	self.Children = {}
	self.Settings = {}
	
	return self
end

return IXObjectClassModule
