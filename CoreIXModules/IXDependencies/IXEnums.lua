-- // About
-- // Enums for the IXFramework

-- // Variables
local IXSettingsModule = {}

IXSettingsModule.__index = IXSettingsModule
IXSettingsModule.Name = "IXFrameworkEnums" 

-- // Constructor
function IXSettingsModule.new(Context)
	local self = setmetatable({}, IXSettingsModule)
	
	self.Context = Context
	
	-- // Enums
	self["AnimationType"] = {}
	self["AnimationType"]["None"] = {UID = 1; Name = "None";}
	self["AnimationType"]["Float"] = {UID = 2; Name = "Float";}
	self["AnimationType"]["Rotate"] = {UID = 3; Name = "Rotate";}
	self["AnimationType"]["Bounce"] = {UID = 4; Name = "Bounce";}
	
	self["ViewportCameraMode"] = {}
	self["ViewportCameraMode"]["Spin"] = {UID = 1; Name = "Spin"}
	self["ViewportCameraMode"]["None"] = {UID = 1; Name = "None"}
	
	return self.Context.Libary:ToObject(self)
end

return IXSettingsModule
