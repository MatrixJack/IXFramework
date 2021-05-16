-- // About
-- // Base instance functions for the Assembler

-- // Variables
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXButtonClass" 
IXObjectClassModule.Aliases = {
	"TextButton", 
	"ImageButton"
}

-- // Functions
function IXObjectClassModule:OnActivated(Function, ...)
	local Disconnected = false
	local FunctionData = {
		Function;
		{...};
	}
	
	table.insert(self.Connections.Active, FunctionData)
	
	return function()
		if Disconnected then return end
		
		table.remove(self.Connections.Active, table.find(FunctionData))
		Disconnected = true
	end
end

function IXObjectClassModule:OnMouseEnter(Function, ...)
	local Disconnected = false
	local FunctionData = {
		Function;
		{...};
	}

	table.insert(self.Connections.Enter, FunctionData)

	return function()
		if Disconnected then return end

		table.remove(self.Connections.Enter, table.find(FunctionData))
		Disconnected = true
	end
end

function IXObjectClassModule:OnMouseLeave(Function, ...)
	local Disconnected = false
	local FunctionData = {
		Function;
		{...};
	}

	table.insert(self.Connections.Leave, FunctionData)

	return function()
		if Disconnected then return end

		table.remove(self.Connections.Leave, table.find(FunctionData))
		Disconnected = true
	end
end

function IXObjectClassModule:IsMouseOver(X, Y)
	local X = X or Mouse.X
	local Y = Y or Mouse.Y
	
	local MousePointGuis = PlayerGui:GetGuiObjectsAtPosition(X, Y)
	
	return self.Object == MousePointGuis[1]
end

function IXObjectClassModule:Enable()
	self.Attributes.ButtonEnabled = true
end

function IXObjectClassModule:Disable()
	self.Attributes.ButtonEnabled = false
end

function IXObjectClassModule:Activate(...)
	self.ActivatedCallback({}, 0, ...)
end

function IXObjectClassModule:UpdateDefaults()
	self.Cache.BackgroundColor3 = self.Object.BackgroundColor3
end

-- // Internal
function IXObjectClassModule:ConstructClassConnections()
	self.Object.Active = true
	
	do -- // Connections
		self.ActivatedCallback = function(InputObject, Count, ...)
			if not self.Settings.ButtonEnabled or not self.Attributes.ButtonEnabled then return end
			if self.Settings.ButtonDebounce and self.Attributes.ButtonDebounce then return end
			if self.Settings.ButtonDebounce then self.Attributes.ButtonDebounce = true end
			
			if self.Settings.ButtonActiveSound then
				if self.Settings.ButtonActiveSoundID ~= "" then
					self.Context.Libary:PlayID(self.Settings.ButtonActiveSoundID)
				else
					self.Context.Libary:Warn("No Assign ButtonSound ID. Set ID or Disable Feature.")
				end
			end
			
			for Index, Connection in ipairs(self.Connections.Active) do
				self.Context.Libary:Spawn(Connection[1], unpack(Connection[2]))
			end
			
			if self.Settings.ButtonDebounce then
				wait(self.Settings.ButtonDebounceTick)
				self.Attributes.ButtonDebounce = false
			end
		end
		
		self.Object.MouseEnter:Connect(function(X, Y)
			if not self.Settings.ButtonEnabled or not self.Attributes.ButtonEnabled then return end
			
			if self.Settings.ButtonHoverAnimation ~= self.Context.Enum.AnimationType.None then
				self:PlayAnimation(self.Settings.ButtonHoverAnimation, true)
			end
			
			if self.Settings.ButtonCustomHighlight then
				self.Object.AutoButtonColor = false
				
				if not self.Attributes.ButtonDown then
					self.Object.BackgroundColor3 = self.Settings.MouseHoverHighlight
				end
			end
			
			for Index, Connection in ipairs(self.Connections.Enter) do
				self.Context.Libary:Spawn(Connection[1], unpack(Connection[2]))
			end
		end)
		
		self.Object.MouseLeave:Connect(function(X, Y)
			self:PlayAnimation(self.Settings.ButtonHoverAnimation, false)
			
			if not self.Attributes.ButtonDown then
				self.Object.BackgroundColor3 = self.Cache.BackgroundColor3
			end
				
			for Index, Connection in ipairs(self.Connections.Leave) do
				self.Context.Libary:Spawn(Connection[1], unpack(Connection[2]))
			end
		end)
		
		self.Object.InputBegan:Connect(function(InputObject)
			if not self.Settings.ButtonEnabled or not self.Attributes.ButtonEnabled then return end
			
			-- // Clicked/Holding
			if table.find(self.ActiveInputTypes, InputObject.UserInputType) then
				self.Attributes.ButtonDown = true
				
				if self.Settings.ButtonCustomHighlight then
					self.Object.AutoButtonColor = false
					self.Object.BackgroundColor3 = self.Settings.MouseActiveHighlight
				end
				
				if self.Settings.ButtonActivateAnimation ~= self.Context.Enum.AnimationType.None then
					self:PlayAnimation(self.Settings.ButtonActivateAnimation, true)
				end
				
				InputObject.Changed:Connect(function()
					if InputObject.UserInputState == Enum.UserInputState.End then
						if self.Settings.ButtonCustomHighlight then
							if self:IsMouseOver() then
								self.Object.BackgroundColor3 = self.Settings.MouseHoverHighlight
							else
								self.Object.BackgroundColor3 = self.Cache.BackgroundColor3
							end
						end
						
						self:PlayAnimation(self.Settings.ButtonActivateAnimation, false)
						self.Attributes.ButtonDown = false
						InputObject:Destroy()
					end
				end)
			end
		end)
	end
	
	do -- // Default/Internal Connections
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
	
	self.Object.Activated:Connect(self.ActivatedCallback)
end

-- // Constructor
function IXObjectClassModule.new(Context, Object)
	local self = setmetatable({}, IXObjectClassModule)
	
	self.Object = Object
	self.Context = Context

	self.Settings = {
		["ButtonEnabled"] = self.Context.Settings.ButtonEnabled;

		["ButtonHoverAnimation"] = self.Context.Settings.ButtonHoverAnimation;
		["ButtonActivateAnimation"] = self.Context.Settings.ButtonActivateAnimation;

		["ButtonCustomHighlight"] = self.Context.Settings.ButtonCustomHighlight;
		["MouseHoverHighlight"] = self.Context.Settings.MouseHoverHighlight;
		["MouseActiveHighlight"] = self.Context.Settings.MouseActiveHighlight;

		["ButtonDebounce"] = self.Context.Settings.ButtonDebounce;
		["ButtonDebounceTick"] = self.Context.Settings.ButtonDebounceTick;

		["ButtonActiveSound"] = self.Context.Settings.ButtonActiveSound;
		["ButtonActiveSoundID"] = self.Context.Settings.ButtonActiveSoundID;
	}
	
	self.ActiveInputTypes = {
		Enum.UserInputType.MouseButton1;
		Enum.UserInputType.Touch;
	}
	
	self.Attributes = {
		["ButtonEnabled"] = self.Settings.ButtonEnabled;
		["ButtonDebounce"] = false;
		["ButtonDown"] = false;
		["ClickCount"] = 0;
	}
	
	self.Cache = {}
	self.Connections = {}
	
	self.Connections.Active = {}
	self.Connections.Enter = {}
	self.Connections.Leave = {}
	
	self:UpdateDefaults()

	return self
end

return IXObjectClassModule
