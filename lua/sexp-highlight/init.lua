local util = require('sexp-highlight.util')

local highlight_lowest_list; local highlight_node; local recursive_highlight; -- poor man's prototype

local M = {}

local function setup_for_buffer(buffer, options)
    if M.buffers['b'..buffer] == nil then
        M.buffers['b'..buffer] = {
            options = options,
            autocmd = vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { group = M.au, buffer = buffer, callback = highlight_lowest_list })
        }
    end
end

local function disable_for_buffer(buffer)
    vim.api.nvim_del_autocmd(M.buffers['b'..buffer].autocmd)
    vim.api.nvim_buf_clear_namespace(buffer, M.ns, 0, -1)
    M.buffers['b'..buffer] = nil
end

M.toggle_for_current_buffer = function(opts)
    opts = opts or {}
    local options = {
        levels = opts.levels or 4,
        method = opts.method or 'block',
        starting_color = opts.starting_color or nil,
        colors = opts.colors or { start = 25, step = 10 }
    }
    M.levels = options.levels -- TODO: move these two into per-buffer options,
    M.colors = options.colors -- will need to gen. separate highlights for each buffer :(

    -- General setup
    if not M.au then M.au = vim.api.nvim_create_augroup('SexpHighlightAuGroup', { clear = true }) end
    if not M.ns then M.ns = vim.api.nvim_create_namespace("sexp-highlight") end
    M.buffers = M.buffers or {}

    local current_buffer = vim.api.nvim_get_current_buf()

    if M.buffers['b'..current_buffer] == nil then
        if current_buffer then setup_for_buffer(current_buffer, options) end
    else -- already activated in the past
        disable_for_buffer(current_buffer)
        return
    end

    -- Re-setup on colorscheme change
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = M.au,
        buffer = current_buffer,
        callback = function()
            M.toggle_for_current_buffer()
            M.toggle_for_current_buffer() -- insert skull emoji here
        end
    })

    local background = string.format("%x", vim.api.nvim_get_hl_by_name("Normal", true).background)
    if opts.starting_color then background = opts.starting_color end

    -- Create highlights based on current background
    for i = 0, M.levels-1 do
        vim.api.nvim_set_hl(0, 'SexpHighlightLevel'..i+1, {
            bg = '#'..string.format("%x", util.color_shift(background, M.colors.start + (M.colors.step * i)))
        })
    end

    highlight_lowest_list()
end

highlight_lowest_list = function()
    local buffer = vim.api.nvim_get_current_buf()

    -- Clear on each render
    vim.api.nvim_buf_clear_namespace(buffer, M.ns, 0, -1)

    local node = vim.treesitter.get_node()
    if not node then return end

    local root = node:tree():root()

    -- Find nearest list above
    while not util.is_list(node) and node ~= root do
        node = node:parent()
    end

    recursive_highlight(buffer, node, M.levels)
end

highlight_node = function(buffer, node, hlname, method)
    local start_line, start_column, _ = node:start()
    local end_line, end_column, _ = node:end_()

    local first_line_end_column = end_column
    if start_line ~= end_line then
        first_line_end_column = -1
    end

    if method == 'block' then
        vim.api.nvim_buf_add_highlight(buffer, M.ns, hlname, start_line, start_column, first_line_end_column)
        for line = start_line, end_line, 1 do
            vim.api.nvim_buf_add_highlight(buffer, M.ns, hlname, line, start_column, first_line_end_column)
        end
    elseif method == 'line' then
        vim.highlight.range(buffer, M.ns, hlname, {start_line, start_column}, {end_line, end_column})
    end
end

recursive_highlight = function(buffer, node, depth, options)
    if depth <= 0 then return end

    if not options then
        options = M.buffers['b'..buffer].options
    end

    -- Highlight the node
    highlight_node(buffer, node, "SexpHighlightLevel" .. (options.levels+1 - depth), options.method)

    -- Highlight children nodes recursively
    for child, _ in node:iter_children() do
        if util.is_list(child) then
            recursive_highlight(buffer, child, depth - 1)
        end
    end
end

return M
