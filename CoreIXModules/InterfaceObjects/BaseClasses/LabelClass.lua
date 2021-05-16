-- // About
-- // Base instance functions for the Assembler

-- // Variables
local TweenService = game:GetService("TweenService")
local IXObjectClassModule = {}

IXObjectClassModule.__index = IXObjectClassModule
IXObjectClassModule.Name = "IXLabelClass" 
IXObjectClassModule.Aliases = {
	"TextLabel"
}

-- // Functions
function IXObjectClassModule:Enable()

end

function IXObjectClassModule:Disable()

end

function IXObjectClassModule:Fade(FadeIn)
	if FadeIn then
		self.Cache.FadeInTween:Play()
	else
		self.Cache.FadeOutTween:Play()
	end
end

function IXObjectClassModule:Typewrite(Content)
	self.TypewriteMutex = self.TypewriteMutex + 1
	local CIndex = self.TypewriteMutex

	for Index, Value in ipairs(Content:split("")) do
		if self.TypewriteMutex ~= CIndex then
			return
		end

		self.Object.Text = Content:sub(1, Index)
		wait(self.Settings.TypewriteTick)
	end
end

function IXObjectClassModule:Rainbow(Threaded)
	self.RainbowMutex = self.RainbowMutex + 1
	local CIndex = self.RainbowMutex
	local Hue = 0
	
	local function InitiazeRainbowCallback()
		while true do
			if CIndex ~= self.RainbowMutex then
				break
			end
			
			self.Object.TextColor3 = Color3.fromHSV(Hue / 360, 1, 1)

			if Hue + 1 >= 360 then
				Hue = 1
			else
				Hue += 1
			end
			
			wait(self.Settings.RainbowTick)
		end
	end
	
	if Threaded then
		self.Context.Libary:Spawn(InitiazeRainbowCallback)
	else
		InitiazeRainbowCallback()
	end
end

-- // Internal
function IXObjectClassModule:UpdateDefaults()
	if self.Cache.FadeInTween then
		self.Cache.FadeInTween:Destroy()
	end
	
	if self.Cache.FadeOutTween then
		self.Cache.FadeOutTween:Destroy()
	end
	
	self.Cache.FadeInTween = TweenService:Create(self.Object, TweenInfo.new(self.Settings.FadeTick), {TextTransparency = 0})
	self.Cache.FadeOutTween = TweenService:Create(self.Object, TweenInfo.new(self.Settings.FadeTick), {TextTransparency = 1})
end

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
	
	self.TypewriteMutex = 0
	self.RainbowMutex = 0
	
	self.Cache = {}
	self.Settings = {
		["TypewriteTick"] = self.Context.Settings.LabelTypewriteTick;
		["RainbowTick"] = self.Context.Settings.LabelRainbowTick;
		["FadeTick"] = self.Context.Settings.LabelFadeTick;
	}

	return self
end

return IXObjectClassModule
