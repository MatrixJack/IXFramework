-- // About
-- // Base instance functions for the Assembler
-- // EXAMPLE CLASS :: UNTESTED VIEWPORT FUNCTIONS

-- // Variables
local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXViewportClass" 
IXObjectClassModule.Aliases = {
	"ViewportFrame"
}

-- // Functions
function IXObjectClassModule:Enable()
	self.Object.Visible = true
	self.IsActive = true
end

function IXObjectClassModule:Disable()
	self.Object.Visble = false
	self.IsActive = false
end

function IXObjectClassModule:SetPrimaryObject(Object)
	if self.Object then
		self.Object:Destroy()
	end
	
	Object.CFrame = CFrame.new(0, 0, 0)
	
	self.MainObject = Object
	self.Object = Object
	self.Vector = Vector3.new(0, 5, Object.Size.Z + 10)
end

function IXObjectClassModule:SetPrimaryModel(Model)
	local ModelSize = Model:GetExtentsSize()
	
	if not Model.PrimaryPart then
		self.Context.Libary:Warn("Model Has No Primary Part %s", Model:GetFullName())
	end
	
	if self.Object then
		self.Object:Destroy()
	end
	
	Model.PrimaryPart.CFrame = CFrame.new(0, 0, 0)
	
	self.MainObject = Model.PrimaryPart
	self.Object = Model.PrimaryPart
	self.Vector = Vector3.new(0, 5, ModelSize.Z + 10)
end

-- // Internal
function IXObjectClassModule:InitializeDefaults()
	self.InitializeDefaults = nil
	self.Camera.Parent = self.Object
	self.Object.CurrentCamera = self.Camera
	
	self.Context.Libary:Spawn(function()
		while true do
			if self.Settings.CameraMode == self.Context.Enum.ViewportCameraMode.Spin then
				self.Camera.CFrame = CFrame.new(self.Vector, self.MainObject.Position) * CFrame.Angles(0, 0, math.rad(self.ZAngle))
				
				self.ZAngle += 1
			end
			
			wait(self.Settings.ViewportThreadTick)
		end	
	end)
end

function IXObjectClassModule:ConstructClassDescendants()
	do -- // Internal Connections
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
end

-- // Constructor
function IXObjectClassModule.new(Context, Object)
	local self = setmetatable({}, IXObjectClassModule)

	self.Object = Object
	self.Context = Context
	
	self.MainObject = false
	self.Object = false
	
	self.ZAngle = 0
	self.Vector = Vector3.new(0, 5, 10)
	self.Camera = Instance.new("Camera")
	self.MutexIndex = 0
	
	self.IsActive = true
	self.Settings = {
		["CameraMode"] = self.Context.Settings.ViewportCameraMode;
		["ViewportThreadTick"] = self.Context.Settings.ViewportThreadTick;
	}

	return self
end

return IXObjectClassModule
