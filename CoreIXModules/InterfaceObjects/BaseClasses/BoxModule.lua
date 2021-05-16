-- // About
-- // Base instance functions for the Assembler

-- // Variables
local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXBoxClass" 
IXObjectClassModule.Aliases = {
	"TextBox"
}

-- // Functions
function IXObjectClassModule:Enable()

end

function IXObjectClassModule:Disable()

end

-- // Internal
function IXObjectClassModule:ConstructClassDescendants()
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
			self:RegisterElement(Child)
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

	self.Settings = {}

	return self
end

return IXObjectClassModule
