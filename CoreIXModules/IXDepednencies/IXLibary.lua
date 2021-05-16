-- // About
-- // IXLibary gives other modules important functions

-- // Variables
local SoundService = game:GetService("SoundService")

local IXLibartCache = {}
local IXLibaryModule = {}

-- // Module functions
function IXLibaryModule:ToObject(Table)
	local Proxy = newproxy(true)
	local Metatable = getmetatable(Proxy)
	
	Metatable.__index = Table
	Metatable.__newindex = Table
	Metatable.__tostring = function() return Table.Name end
	Metatable.__metatable = "this metatable is locked"
	
	return Proxy
end

-- // Event Functions
function IXLibaryModule:CreateEvent()
	local EventBindable = Instance.new("BindableEvent")

	local function Fire()
		EventBindable:Fire()
	end
	
	local function Connect(Callback)
		local Connection = EventBindable.Event:Connect(Callback)
		
		return function()
			Connection:Disconnect()
		end
	end
	
	return Connect, Fire
end

-- // Threading Functions
function IXLibaryModule:CSpawn(Function, ...)
	local Thread = coroutine.create(Function)
	local Success, Result = coroutine.resume(Thread, ...)

	if not Success then
		coroutine.wrap(error)(Result)
		print(debug.traceback(Thread))
	end
end

function IXLibaryModule:BSpawn(Function, ...)
	if IXLibartCache[Function] then
		IXLibartCache[Function]:Fire(...)
	else
		local Bindable = Instance.new("BindableEvent")

		Bindable.Event:Connect(Function)
		Bindable:Fire(...)
		
		IXLibartCache[Function] = Bindable
	end
end

function IXLibaryModule:Spawn(Function, ...)
	-- // Not Stack Friendly
	-- return self:CSpawn(Function, ...)
	
	-- // Stack Friendly
	return self:BSpawn(Function, ...)
end

-- // Sound Functions
function IXLibaryModule:PlayID(ID)
	local SoundObject = IXLibartCache[ID]
	
	if not SoundObject then
		SoundObject = Instance.new("Sound")
		SoundObject.Parent = SoundService
		
		IXLibartCache[ID] = SoundObject
	end
	
	SoundService:PlayLocalSound(SoundObject)
end

-- // Console Functions
function IXLibaryModule:Log(String, ...)
	print(("[IXFramework]: %s"):format(String:format(...)))
end

function IXLibaryModule:Warn(String, ...)
	warn(("[IXFramework]: %s"):format(String:format(...)))
end

return IXLibaryModule
