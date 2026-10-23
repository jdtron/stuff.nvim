---@class Config
---@field projects ProjectConfig
---@field bookmarks boolean

local M = {
    projects = nil,
    bookmarks = nil,
}

---@param config Config
M.setup = function (config)
    config = config or {}

    if config.projects ~= nil then
        M.projects = require('stuff.projects')
        M.projects.setup(config.projects)
    end

    if config.bookmarks then
        M.bookmarks = require('stuff.bookmarks')
        M.bookmarks.setup()
    end
end

return M
