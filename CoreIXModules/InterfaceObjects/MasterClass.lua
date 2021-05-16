-- // About
-- // Base instance functions for the Assembler

-- // Variables
local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXMasterClass" 

-- // Functions
function IXObjectClassModule:Enable()
	self.Object.Visible = true
end

function IXObjectClassModule:Disable()
	self.Object.Visible = false
end

function IXObjectClassModule:SetPrimaryFrame(Frame)
	local Child = self.Children[Frame]
	
	if self.PrimaryFrame == Child then return end
	
	if self.PrimaryFrame then
		self.PrimaryFrame.InvisibleEvent()
		self.PrimaryFrame:Disable()
	end
	
	if Child then
		Child.VisibleEvent()
		Child:Enable()
		
		if Child.Settings.VisibleAnimation ~= self.Context.Enum.AnimationType.None then
			Child:PlayAnimation(Child.Settings.VisibleAnimation)
		end
		
		self.PrimaryFrame = Child
	else
		self.Context.Libary:Warn("Failed To Set Primary: Invalid Frame %s", Frame)
	end
end

function IXObjectClassModule:InitializeDefaults()
	if not self.Settings.MasterDefaultVisible then
		for Index, Value in ipairs(self.Children) do
			Value.Object.Visible = false
		end
	end
end

-- // Internal
function IXObjectClassModule:ConstructClassDescendants()
	for Index, Child in ipairs(self.Object:GetChildren()) do
		if Child:IsA("Frame") and not Child:GetAttribute("Disabled") then
			local Object = self:RegisterElement(Child)
			
			if not self.Settings.MasterDefaultVisible then
				Object.Object.Visible = false
			end
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
			local Object = self:RegisterElement(Child)
			
			if not self.Settings.MasterDefaultVisible then
				Object.Object.Visible = false
			end
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
	self.PrimaryFrame = false

	self.Children = {}
	self.Settings = {
		["MasterDefaultVisible"] = self.Context.Settings.MasterDefaultVisible
	}

	return self
end

return IXObjectClassModule
