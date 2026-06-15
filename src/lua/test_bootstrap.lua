local function prepend_package_path(path)
	if not string.find(package.path, path, 1, true) then
		package.path = path .. ";" .. package.path
	end
end

prepend_package_path("./?.lua")
prepend_package_path("./src/?.lua")

return {
	W3CData = require("lua.w3cdata"),
	W3CEvents = require("lua.w3cEvents"),
	W3CChecksum = require("lua.w3cChecksum"),
	W3CSchema = require("lua.w3cschema"),
	json = require("lua.json"),
}
