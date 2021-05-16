-- // About
-- // Settings for the IXFramework

-- // Variables
local IXSettingsModule = {}

IXSettingsModule.__index = IXSettingsModule
IXSettingsModule.Name = "IXFrameworkSettings" 

-- // Constructor
function IXSettingsModule.new(Context)
	local self = setmetatable({}, IXSettingsModule)
	
	self.Context = Context
	
	-- // Animation Settings
	self["RotationTick"] = .25
	self["RotationOffset"] = 2.5
	self["RotationReverse"] = false
	
	self["FloatTick"] = .25
	self["FloatOffset"] = 2.5
	self["FloatReverse"] = false
	
	self["BounceTick"] = .25
	self["BounceOffset"] = 2.5
	self["BounceReverse"] = false
	
	-- // Master Frame Settings
	self["MasterDefaultVisible"] = false
	
	-- // Frame Settings
	self["FrameVisibleAnimation"] = self.Context.Enum.AnimationType.Bounce
	self["FrameDragging"] = true
	self["FrameSmoothDragging"] = true
	self["FrameResponsiveness"] = .5
	
	-- // Button Settings
	self["ButtonEnabled"] = true
	
	self["ButtonHoverAnimation"] = self.Context.Enum.AnimationType.Rotate
	self["ButtonActivateAnimation"] = self.Context.Enum.AnimationType.Bounce
	
	self["ButtonCustomHighlight"] = true
	self["MouseHoverHighlight"] = Color3.fromRGB(255, 107, 107)
	self["MouseActiveHighlight"] = Color3.fromRGB(79, 188, 255)
	
	self["ButtonDebounce"] = true
	self["ButtonDebounceTick"] = .25
	
	self["ButtonActiveSound"] = true
	self["ButtonActiveSoundID"] = ""
	
	-- // Text Box Settings
	
	-- // Image Settings
	
	-- // Label Settings
	self["LabelTypewriteTick"] = .1
	self["LabelRainbowTick"] = .05
	self["LabelFadeTick"] = 1.5
	
	-- // Viewport Settings
	self["ViewportCameraMode"] = self.Context.Enum.ViewportCameraMode.None
	self["ViewportThreadTick"] = .05
	
	return self.Context.Libary:ToObject(self)
end

return IXSettingsModule
