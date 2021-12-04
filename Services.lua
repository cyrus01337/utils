local ServicesMeta = {}
local Services = {}


function ServicesMeta:__index(key)
	if typeof(key) ~= "string" then
		return nil
	end

	local serviceFound = rawget(Services, key)

	if not serviceFound then
		serviceFound = game:FindFirstChild(key) or game:GetService(key)
		Services[key] = serviceFound
	end

	return serviceFound
end


return setmetatable(Services, ServicesMeta)
