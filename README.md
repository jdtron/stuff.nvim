# stuff.nvim

JD's nvim stuff - a loose collection of my nvim utilities.

Currently, this includes
- project navigation 
- file/directory bookmarks

## Features

- **Project picker** — Browse directories under a configured root and jump into a project.
  - **Workspace support** — Mark directories with a .workspace file to organize projects into nested groups.
  - **Terminal title** — Automatically set the terminal title to the selected project's directory name.
- **Bookmarks** — Quickly navigate to bookmarked files and directories.
  - **Editable bookmarks** — Manage bookmarks in a plain-text file.

## Requirements

- [neovim](https://neovim.io/)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- `find` command available in your environment (used by the project picker)

## Installation

Install with your preferred plugin manager.

### lazy

```
{
    "jdtron/stuff.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("stuff").setup({
            projects = {
                root = "~/Projects",
            },
            bookmarks = true,
        })
    end,
}
```

## Configuration

Call require("stuff").setup() to enable the modules you need.

```lua
require("stuff").setup({
    projects = {
        root = "~/Projects",
    },
    bookmarks = true,
})
```

### Projects

| Option |  Type  | Description                             |
|--------|--------|-----------------------------------------|
| root   | string | Root directory containing your projects |


The projects module is enabled by providing a projects configuration table. The root option is required.

Run require("stuff.projects").select() to open the project picker.

The picker uses telescope to display the immediate subdirectories of the configured root.
Selecting a regular directory changes Neovim's working directory to it and sets the terminal title to the directory's name.

#### Workspaces

A directory containing a .workspace file is treated as a workspace rather than a regular project. Selecting it opens another picker showing its immediate subdirectories.

For example:

~/Projects/
├── personal/
│   ├── .workspace
│   ├── website/
│   └── dotfiles/
├── work/
│   ├── .workspace
│   ├── backend/
│   └── frontend/
└── playground/


Selecting personal or work opens the corresponding nested project list. Selecting a directory inside one of those workspaces changes the working directory to that project.

The .workspace file is simply a marker; its contents are not used.

### Bookmarks

Enable bookmarks with:

```lua
require("stuff").setup({
    bookmarks = true,
})
```

Bookmarks are stored in a plain-text file at:

```lua
stdpath("data")/bookmarks
```

On a typical Neovim installation, this is inside your Neovim data directory.

Each non-empty line represents a file or directory path. Paths are expanded using Neovim's expand() function, so entries can use forms such as ~.

For example:

```
~/Projects/website
~/Projects/dotfiles
~/.config/nvim/init.lua
```

You can edit this list directly from Neovim using `:EditBookmarks`.

#### Commands

| Command          | Description                         |
|------------------|-------------------------------------|
| `:Bookmarks`     | Open the bookmark picker            |
| `:EditBookmarks` | Open the bookmarks file for editing |

The bookmark picker displays files and directories with different icons. Selecting a directory changes Neovim's working directory; selecting a file opens it in the current window.

Missing or unsupported paths produce a warning notification.

## Lua API

The modules can also be invoked directly:

-- Open the project picker
require("stuff.projects").select()

-- Open the bookmark picker
require("stuff.bookmarks").select()

-- Edit the bookmarks list
require("stuff.bookmarks").edit()
