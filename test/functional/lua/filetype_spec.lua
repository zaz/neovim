local helpers = require('test.functional.helpers')(after_each)
local exec_lua = helpers.exec_lua
local eq = helpers.eq
local clear = helpers.clear
local pathroot = helpers.pathroot

local root = pathroot()

describe('vim.filetype', function()
  before_each(function()
    clear()

    exec_lua [[
      local bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(bufnr)
    ]]
  end)

  it('works with extensions', function()
    eq('radicalscript', exec_lua [[
      vim.filetype.add({
        extension = {
          rs = 'radicalscript',
        },
      })
      return vim.filetype.match('main.rs')
    ]])
  end)

  it('prioritizes filenames over extensions', function()
    eq('somethingelse', exec_lua [[
      vim.filetype.add({
        extension = {
          rs = 'radicalscript',
        },
        filename = {
          ['main.rs'] = 'somethingelse',
        },
      })
      return vim.filetype.match('main.rs')
    ]])
  end)

  it('works with filenames', function()
    eq('nim', exec_lua [[
      vim.filetype.add({
        filename = {
          ['s_O_m_e_F_i_l_e'] = 'nim',
        },
      })
      return vim.filetype.match('s_O_m_e_F_i_l_e')
    ]])

    eq('dosini', exec_lua([[
      local root = ...
      vim.filetype.add({
        filename = {
          ['config'] = 'toml',
          [root .. '/.config/fun/config'] = 'dosini',
        },
      })
      return vim.filetype.match(root .. '/.config/fun/config')
    ]], root))
  end)

  it('works with patterns', function()
    eq('markdown', exec_lua([[
      local root = ...
      vim.env.HOME = '/a-funky+home%dir'
      vim.filetype.add({
        pattern = {
          ['~/blog/.*%.txt'] = 'markdown',
        }
      })
      return vim.filetype.match('~/blog/why_neovim_is_awesome.txt')
    ]], root))
  end)

  it('works with functions', function()
    eq('foss', exec_lua [[
      vim.filetype.add({
        pattern = {
          ["relevant_to_(%a+)"] = function(path, bufnr, capture)
            if capture == "me" then
              return "foss"
            end
          end,
        }
      })
      return vim.filetype.match('relevant_to_me')
    ]])
  end)
end)
