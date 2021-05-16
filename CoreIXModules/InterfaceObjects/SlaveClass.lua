-- // About
-- // Base instance functions for the Assembler

-- // Variables
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Mouse = Player:GetMouse()

local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXSlaveClass" 
IXObjectClassModule.Aliases = {"Frame"}

-- // Functions
function IXObjectClassModule:Enable()
	self.Object.Visible = true
end

function IXObjectClassModule:Disable()
	self.Object.Visible = false
end

-- // Internal
function IXObjectClassModule:ConstructClassDescendants()
	for Index, Descendant in ipairs(self.Object:GetDescendants()) do
		if self.Context.Assembler:IsClass(Descendant.ClassName) and not Descendant:GetAttribute("Disabled") then
			self:RegisterElement(Descendant)
		end
	end
end

function IXObjectClassModule:ConstructClassConnections()	
	do
		self.Object.Active = true

		Mouse.Move:Connect(function()
			if not self.Dragging then return end
			local Delta = Vector3.new(Mouse.X, Mouse.Y, 0) - self.DragStart
			local End = UDim2.new(
				self.StartPosition.X.Scale, 
				self.StartPosition.X.Offset + Delta.X, 
				self.StartPosition.Y.Scale, 
				self.StartPosition.Y.Offset + Delta.Y
			)

			if self.Settings.SmoothDragging then
				self.Object:TweenPosition(End, Enum.EasingDirection.Out, Enum.EasingStyle.Back, self.Settings.Responsiveness, true)
			else
				self.Object.Position = End
			end
		end)

		self.Object.InputChanged:Connect(function(InputObject)
			if table.find(self.MovementTypes, InputObject.UserInputType) then
				self.DragInput = InputObject
			end
		end)

		self.Object.InputBegan:Connect(function(InputObject)
			if InputObject.UserInputState == Enum.UserInputState.Begin then

				-- // Dragging
				if self.Settings.FrameDragging then
					if table.find(self.InputTypes, InputObject.UserInputType) then
						self.DragStart = InputObject.Position
						self.StartPosition = self.Object.Position
						self.Dragging = true

						InputObject.Changed:Connect(function()
							if InputObject.UserInputState == Enum.UserInputState.End then
								self.Dragging = false
								InputObject:Destroy()
							end
						end)
					end
				end
			end
		end)
	end
	
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
		
		self.Object.DescendantAdded:Connect(function(Object)
			self:RegisterElement(Object, Object.ClassName)
		end)

		self.Object.DescendantAdded:Connect(function(Object)
			self.Children[Object.Name] = nil
		end)
	end
end

-- // Constructor
function IXObjectClassModule.new(Context, Object)
	local self = setmetatable({}, IXObjectClassModule)

	self.Object = Object
	self.Context = Context
	
	self.Dragging = false
	self.StartPosition = false
	self.DragInput = false
	self.StartPosition = false
	
	self.InputTypes = {Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch}
	self.MovementTypes = {Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch}
	
	self.OnVisible, self.VisibleEvent = self.Context.Libary:CreateEvent()
	self.OnInvisible, self.InvisibleEvent = self.Context.Libary:CreateEvent()

	self.Children = {}
	self.Settings = {
		["VisibleAnimation"] = self.Context.Settings.FrameVisibleAnimation;
		["FrameDragging"] = self.Context.Settings.FrameDragging;
		["SmoothDragging"] = self.Context.Settings.FrameSmoothDragging;
		["Responsiveness"] = self.Context.Settings.FrameResponsiveness;
	}

	return self
end

return IXObjectClassModule
