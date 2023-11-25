# Sibling-swap.nvim: swaps closest siblings with Tree-Sitter

Neovim plugin to swap places of siblings, e.g., `arguments`, `parameters`, `attributes`, `pairs in objects`, `array's items` e.t.c., which located near and separated by `allowed_separators` or space.

- **Zero-config (almost)**: No need to setup specific language – should works from scratch with all languages supported by [Tree-Sitter](https://tree-sitter.github.io/tree-sitter/);
- **Simple**: Just grab this node and move;
- **Sticky-cursor**: The cursor follows the text on which it was called;
- **Smart**: Able to replace operand in binary expressions and Mathematical operations to opposite[^1].

> [^1]: If you want to swap operand and operators with by one key from anywhere in binary expressions, look at [binary-swap.nvim](https://github.com/Wansmer/binary-swap.nvim)

<https://user-images.githubusercontent.com/46977173/203991867-c80abbd3-e3de-4af9-b721-252c03d44e5f.mov>

## Requirements

1. [Neovim 0.8+](https://github.com/neovim/neovim/releases)
2. [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
3. Read the [WARNING](#warning)

## Installation

With [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  'Wansmer/sibling-swap.nvim',
  requires = { 'nvim-treesitter' },
  config = function()
    require('sibling-swap').setup({--[[ your config ]]})
  end,
})
```

## Configuration

### Default config

```lua
local DEFAULT_SETTINGS = {
  allowed_separators = {
    ',',
    ';',
    'and',
    'or',
    '&&',
    '&',
    '||',
    '|',
    '==',
    '===',
    '!=',
    '!==',
    '-',
    '+',
    ['<'] = '>',
    ['<='] = '>=',
    ['>'] = '<',
    ['>='] = '<=',
  },
  use_default_keymaps = true,
  -- Highlight recently swapped node. Can be boolean or table
  -- If table: { ms = 500, hl_opts = { link = 'IncSearch' } }
  -- `hl_opts` is a `val` from `nvim_set_hl()`
  highlight_node_at_cursor = false,
  -- keybinding for movements to right or left (and up or down, if `allow_interline_swaps` is true)
  -- (`<C-,>` and `<C-.>` may not map to control chars at system level, so are sent by certain terminals as just `,` and `.`. In this case, just add the mappings you want.)
  keymaps = {
    ['<C-.>'] = 'swap_with_right',
    ['<C-,>'] = 'swap_with_left',
    ['<space>.'] = 'swap_with_right_with_opp',
    ['<space>,'] = 'swap_with_left_with_opp',
  },
  ignore_injected_langs = false,
  -- allow swaps across lines
  allow_interline_swaps = true,
  -- swaps interline siblings without separators (no recommended, helpful for swaps html-like attributes)
  interline_swaps_without_separator = false,
}
```

### Options

#### Separators

`allowed_separators`: list of separators for detecting suitable siblings. 'Separators' meaning unnamed treesitter node.
If you need to change separator to the opposite value (e.g., in binary expressions), set it like `key = value`.
If you want to disable something separator - set it to `false`.

**Example**:

```lua
require('sibling-swap').setup({
  allowed_separators = {
    -- standart
    '=',
    -- with opposite value
    ['>>'] = '<<',
    ['<<'] = '>>',
    -- disable
    ['&'] = false,
  }
})
```

#### Keymaps

`use_default_keymaps` - use default keymaps or not.
`keymaps` - keymaps by default.

If you want to change it, here is two way to do it:

1. Change it in options (like above). Be sure what `use_default_keymaps` is 'true';
2. Add `vim.keymap.set('n', 'YOUR_PREFER_KEYS', require('sibling-swap').swap_with_left)` anywhere in your config. Be sure what `use_default_keymaps` is 'false';

#### Injected languagas

`ignore_injected_langs`: 'true' is not recommended. If set to 'true', plugin will not to recognize injected languages, e.g. blocks of code in `markdown`, `js` in `html` or `js` in `vue`.

Here is two reason to set it 'true':

If you no work with filetypes allowing injected languages;
If you want to be able to swap node with injected language when cursor is placed on injected, e.g.:

```vue
<template>
  <app-item @click="clic|kHandler" class="class" />
                        |
  <!-- The 'clickHandler' is a javascript and it have not any -->
  <!-- siblings. If 'ignore_injected_langs' is 'false', the plugin will do nothing. -->
  <!-- If 'ignore_injected_langs' is 'true', attribute '@click="clickHandler"' will -->
  <!-- swap. But in section 'script' or 'stile' the plugin will not working. -->
</template>

<script setup>
const one = { tw|o: 'two', one: 'one' }
                |
    // If 'ignore_injected_langs' is 'true', Tree-Sitter recognize
    // all <script> section as injected language and it will be
    // ignored.
</script>
```

## Warning

Plugin work with SIBLINGS. Its meaning what any siblings which located near, has ‘allowed’ separator or space between
each other and placed in same level in ‘treesitter’ tree - are suitable for swaps.
It allows no setup each language by separate.
It supposed, what you understand it before using.

**Examples**:

```javascript
function test (a) { return a; }
//        |
//  cursor here and you trigger 'swap_with_right', code will transform to
function (a) test { return a; }
// because 'test' and '(a)' on same line, on one level in tree and has space between each other
```

```html
<p class="swap" is="left">Swap me</p>
<!--   |         -->
<!-- cursor here and you trigger 'swap_with_left', code will transform to -->
<class="swap" p is="left">Swap me</p>
<!-- because 'class="swap"' and 'p' on same line, on one level in tree and has space between each other -->
```
