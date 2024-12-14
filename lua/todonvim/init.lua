-- todonvim.lua

local M = {}
local api = vim.api
local tasks = {}
local current_selection = 1
local popup_buf, popup_win
local task_line_indices = {}

local function fetch_tasks()
    local file = io.open(vim.fn.getcwd() .. "/tasks.json", "r")
    if file then
        local content = file:read("*a")
        tasks = vim.fn.json_decode(content)
        for idx, task in ipairs(tasks) do
            if type(task) == "string" then
                tasks[idx] = { name = task, done = false }
            else
                if task.name == nil then
                    task.name = "Unnamed Task"
                end
                if task.done == nil then
                    task.done = false
                end
            end
        end
        file:close()
    else
        tasks = {}
    end
end

local function save_tasks()
    local file = io.open(vim.fn.getcwd() .. "/tasks.json", "w")
    if file then
        file:write(vim.fn.json_encode(tasks))
        file:close()
    end
end

local function setup_mappings()
    api.nvim_buf_set_keymap(popup_buf, 'n', 'j', ':lua require("todonvim").navigate_down()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'k', ':lua require("todonvim").navigate_up()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'a', ':lua require("todonvim").add_task()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'D', ':lua require("todonvim").delete_task()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'e', ':lua require("todonvim").modify_task()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'm', ':lua require("todonvim").toggle_done()<CR>', { noremap = true, silent = true })
    api.nvim_buf_set_keymap(popup_buf, 'n', 'q', ':lua require("todonvim").close_popup()<CR>', { noremap = true, silent = true })
end

local function render_popup()
    if not (popup_buf and api.nvim_buf_is_valid(popup_buf)) then
        popup_buf = api.nvim_create_buf(false, true)
    end

    api.nvim_buf_set_option(popup_buf, 'modifiable', true)

    local lines = {}
    task_line_indices = {} 

    table.insert(lines, "        📋 To-Do List")
    table.insert(lines, "-------------------------------")

    for i, task in ipairs(tasks) do
        if not task.done then
            local task_name = task.name or "Unnamed Task"
            table.insert(task_line_indices, i)
            if current_selection == #task_line_indices then
                table.insert(lines, "> " .. task_name)
            else
                table.insert(lines, "  " .. task_name)
            end
        end
    end

    local has_completed = false
    for _, task in ipairs(tasks) do
        if task.done then
            has_completed = true
            break
        end
    end

    if has_completed then
        table.insert(lines, "-------------------------------")
        table.insert(lines, "        ✔️ Completed Tasks")

        -- Add completed tasks
        for i, task in ipairs(tasks) do
            if task.done then
                local task_name = task.name or "Unnamed Task"
                table.insert(task_line_indices, i)
                if current_selection == #task_line_indices then
                    table.insert(lines, "> ~" .. task_name .. "~")
                else
                    table.insert(lines, "  ~" .. task_name .. "~")
                end
            end
        end
    end

    if #task_line_indices == 0 then
        table.insert(lines, "  No tasks available. Press 'a' to add a new task.")
    end

    local popup_height = #lines

    if not (popup_win and api.nvim_win_is_valid(popup_win)) then
        popup_win = api.nvim_open_win(popup_buf, true, {
            relative = 'editor',
            width = 50,
            height = popup_height,
            row = 5,
            col = 10,
            style = 'minimal',
            border = 'rounded',
        })
        setup_mappings()
    else
        api.nvim_win_set_config(popup_win, { height = popup_height })
    end

    api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)

    api.nvim_buf_set_option(popup_buf, 'modifiable', false)

    if #task_line_indices == 0 then
        current_selection = 0
    else
        if current_selection > #task_line_indices then
            current_selection = #task_line_indices
        end
        if current_selection < 1 then
            current_selection = 1
        end
    end

    local cursor_pos = 3  
    cursor_pos = cursor_pos + current_selection - 1

    local total_lines = #lines
    if cursor_pos > total_lines then
        cursor_pos = total_lines
    end
    if cursor_pos < 1 then
        cursor_pos = 1
    end

    if current_selection > 0 then
        api.nvim_win_set_cursor(popup_win, { cursor_pos, 1 })
    else
        api.nvim_win_set_cursor(popup_win, { 1, 1 })
    end
end

function M.navigate_up()
    if current_selection > 1 then
        current_selection = current_selection - 1
        render_popup()
    end
end

function M.navigate_down()
    if current_selection < #task_line_indices then
        current_selection = current_selection + 1
        render_popup()
    end
end

function M.add_task()
    vim.ui.input({ prompt = 'New Task: ' }, function(input)
        if input then
            table.insert(tasks, 1, { name = input, done = false })
            save_tasks()
            current_selection = 1 
            render_popup()
        end
    end)
end

function M.delete_task()
    local task_idx = task_line_indices[current_selection]
    if task_idx then
        table.remove(tasks, task_idx)
        save_tasks()
        if current_selection > #task_line_indices then
            current_selection = #task_line_indices
        end
        render_popup()
    end
end

function M.modify_task()
    local task_idx = task_line_indices[current_selection]
    if task_idx then
        vim.ui.input({ prompt = 'Modify Task: ', default = tasks[task_idx].name or "Unnamed Task" }, function(input)
            if input then
                tasks[task_idx].name = input
                save_tasks()
                render_popup()
            end
        end)
    end
end

function M.toggle_done()
    local task_idx = task_line_indices[current_selection]
    if task_idx then
        local task = tasks[task_idx]
        task.done = not task.done 
        save_tasks()
        table.remove(tasks, task_idx)
        if task.done then
            table.insert(tasks, task)
        else
            table.insert(tasks, 1, task)
        end
        current_selection = 1
        render_popup()
    end
end

function M.close_popup()
    if popup_win and api.nvim_win_is_valid(popup_win) then
        api.nvim_win_close(popup_win, true)
    end
    popup_buf = nil
    popup_win = nil
end

function M.open_popup()
    fetch_tasks()
    render_popup()
end

function M.setup()
end

return M