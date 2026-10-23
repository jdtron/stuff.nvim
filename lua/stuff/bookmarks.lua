local M = {}

local uv = vim.uv or vim.loop
local bookmarks_file = vim.fn.stdpath("data") .. "/bookmarks"

--- Ensure the bookmarks file exists.
local function ensure_bookmarks_file()
    vim.fn.mkdir(vim.fn.fnamemodify(bookmarks_file, ":h"), "p")

    local file = io.open(bookmarks_file, "a")
    if file then
        file:close()
    end
end

--- Read bookmarks from disk.
---@return string[]
local function read_bookmarks()
    ensure_bookmarks_file()

    local file = io.open(bookmarks_file, "r")
    if not file then
        return {}
    end

    local bookmarks = {}
    for line in file:lines() do
        line = vim.trim(line)
        if line ~= "" then
            table.insert(bookmarks, vim.fn.expand(line))
        end
    end

    file:close()
    return bookmarks
end

--- Open a file or change cwd to a directory.
---@param path string
local function open_bookmark(path)
    local stat = uv.fs_stat(path)

    if not stat then
        vim.notify(
            "Bookmark does not exist: " .. path,
            vim.log.levels.WARN
        )
        return
    end

    if stat.type == "directory" then
        vim.cmd.cd(vim.fn.fnameescape(path))
    elseif stat.type == "file" then
        vim.cmd.edit(vim.fn.fnameescape(path))
    else
        vim.notify(
            "Unsupported bookmark: " .. path,
            vim.log.levels.WARN
        )
    end
end

--- Open the Telescope bookmark picker.
function M.select()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local bookmarks = read_bookmarks()

    if #bookmarks == 0 then
        vim.notify("No bookmarks found", vim.log.levels.INFO)
        return
    end

    pickers.new({}, {
        prompt_title = "Bookmarks",
        finder = finders.new_table({
            results = bookmarks,
            entry_maker = function(path)
                local stat = uv.fs_stat(path)
                local is_dir = stat and stat.type == "directory"

                return {
                    value = path,
                    display = (is_dir and "󰉋 " or "󰈔 ")
                        .. vim.fn.fnamemodify(path, ":~"),
                    ordinal = path,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection then
                    open_bookmark(selection.value)
                end
            end)

            return true
        end,
    }):find()
end

--- Open the bookmarks file for editing.
function M.edit()
    ensure_bookmarks_file()
    vim.cmd.edit(vim.fn.fnameescape(bookmarks_file))
end

--- Register user commands.
function M.setup()
    vim.api.nvim_create_user_command("Bookmarks", function()
        M.open()
    end, {
        desc = "Choose a file or directory bookmark",
    })

    vim.api.nvim_create_user_command("EditBookmarks", function()
        M.edit()
    end, {
        desc = "Edit the bookmarks list",
    })
end

return M
