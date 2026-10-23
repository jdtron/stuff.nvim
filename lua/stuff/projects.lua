---@class ProjectConfig
---@field root string|nil

local M = {
    root = nil,
}

local function is_workspace(path)
    return vim.fn.filereadable(path .. '/.workspace') == 1
end

local function set_project_title(path)
    local project_name = vim.fn.fnamemodify(path, ":t")
    vim.o.title = true
    vim.o.titlestring = project_name
end

---@param config ProjectConfig
M.setup = function (config)
    M.root = config.root

    if M.root == nil then
        error('Missing required config property: root')
    end
end

M.select = function ()
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local function pick_directory(root, title)
        pickers.new({}, {
            prompt_title = title or "Open Project",
            finder = finders.new_oneshot_job({
                "find",
                root,
                "-mindepth", "1",
                "-maxdepth", "1",
                "-type", "d",
            }, {
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = (is_workspace(entry) and "* " or "󰉋 ")
                        .. vim.fn.fnamemodify(entry, ":t"),
                        ordinal = vim.fn.fnamemodify(entry, ":t"),
                        path = entry,
                    }
                end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()

                    if not selection then
                        return
                    end

                    actions.close(prompt_bufnr)

                    if is_workspace(selection.path) then
                        -- Workspace selected: browse its subdirectories.
                        pick_directory(
                            selection.path,
                            "Workspace: " .. vim.fn.fnamemodify(selection.path, ":t")
                        )
                    else
                        -- Regular directory selected: open it.
                        vim.cmd.cd(vim.fn.fnameescape(selection.path))
                        set_project_title(selection.path)
                    end
                end)

                return true
            end,
        }):find()
    end

    pick_directory(vim.fn.expand(M.root))
end

return M
