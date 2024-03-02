# sexp-highlight.nvim

![image](https://github.com/ArijanJ/sexp-highlight.nvim/assets/56356662/1fe404f8-a3a0-4da3-a916-15088c982916)


This is a small Neovim plugin which will highlight the background of your current s-expression.

It uses [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for parsing the sexp trees, so you'll need a parser installed for your lisp of choice before using this.

I made this for Clojure in particular, but you can easily modify the `is_list` function in `util.lua` to change whether vectors/maps/sets should be highlighted separately (use :InspectTree)

## Installation

- Packer:
```lua
use { 'ArijanJ/sexp-highlight.nvim' }
```

...and other plugin managers should be in this ballpark as well :)

## Usage

All you need to do is map a shortcut to this Lua function:
```lua
require('sexp-highlight').toggle_for_current_buffer()
```

As the name suggests, this'll toggle the plugin for the current buffer. To automate this, look into [the BufNew autocmd](https://neovim.io/doc/user/autocmd.html#BufNew) (or open an issue, doesn't take much to pressure me).

### Configuration

When caling `toggle_for_current_buffer()`, you can pass in a table with these options:
| Option | Description |
|---|---|
| levels | How many levels of nested sexps should be highlighted (color stays the same for all further ones) |
| method | `"block"` or `"line"`, dictates whether the highlighted area will be a block (like visual block mode) or extend to the next line
| colors | `{ start = 30, step = 15 }` - Arbitrary numbers for how much brighter the first layer will be than your background, and how much brighter each following level (step) will be |
| starting_color | Forces a given starting color instead of your background color, format has to be a Lua number in hex format (`0x000000`, no quotes) |

The default call (if you don't pass any options) would look something like this:
```lua
toggle_for_current_buffer({ 
    levels = 4,
    method = 'block',
    starting_color = [uses your background color],
    colors = { start = 25, step = 10}
 })
```

### Light themes
Since this lightens your background color for each level, light themes are very likely to cause color overflows and mess everything up.

Workarounds to this include (and are very much limited to):
- ~~Using a dark theme!~~
- Setting the `starting_color` to a darker one
- Lowering `colors.step`
- Lowering `levels`

![image](https://github.com/ArijanJ/sexp-highlight.nvim/assets/56356662/12c4e986-3396-4ba4-813d-cd1624568970)
