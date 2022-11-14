# Sibling-swap.nvim: swaps closest siblings with Tree-Sitter

Neovim plugin to swap places of siblings, e.g., arguments, parameters, attributes, pairs e.t.c., which places on same line and separated by `allowed_separators` or space.
No need to set up specific language – works from scratch with all languages supported by [Tree-Sitter](https://tree-sitter.github.io/tree-sitter/).

## Requirements

1. [Neovim 0.8+](https://github.com/neovim/neovim/releases)
2. [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

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

Default config:

```lua
local DEFAUTL_SETTINGS = {
  allowed_separators = { ',', ';' },
  use_default_keymaps = true,
  keymaps = {
    ['<C-.>'] = 'swap_with_right',
    ['<C-,>'] = 'swap_with_left',
  },
  ignore_injected_langs = false,
}
```

`allowed_separators` - list of separators for detecting suitable siblings;

`use_default_keymaps` - use default keymaps or not;

`keymaps` - keymaps by default;

> If you want to change it, here is two way to do it:
>
> 1. Change it in options (like above). Be sure what `use_default_keymaps` is 'true';
> 2. Add `vim.keymap.set('n', 'YOUR_PREFER_KEYS', require('sibling-swap').swap_with_left)` anywhere in your config. Be sure what `use_default_keymaps` is 'false';

`ignore_injected_langs` - If set to 'true', plugin will not to recognize injected languages, e.g. blocks of code in `markdown`, `js` in `html` or `js` in `vue`. 'true' is not recommended.

> Here is two reason to set it 'true':
>
> If you no work with filetypes allowing injected languages;
> If you want to be able to swap node with injected language when cursor is placed on injected, e.g.:
>
> ```txt
> <template>
>   <app-item @click="clic|kHandler" class="class"/>
>                         |
>     The 'clickHandler' is a javascript and it have not any
>     siblings. If 'ignore_injected_langs' is 'false', the plugin will do nothing.
>     If 'ignore_injected_langs' is 'true', attribute '@click="clickHandler"' will
>     swap. But in section 'script' or 'stile' the plugin will not working.
> </template>
> 
> <script setup>
>   const one = { tw|o: 'two', one: 'one' }
>                   |
>       If 'ignore_injected_langs' is 'true', Tree-Sitter recognize
>       all <script> section as injected language and it will be
>       ignored. 
> </script>
> ```

## Warning

Plugin work with SIBLINGS. Its meaning what any siblings which placed in one line, 
has 'allowed' separator or space between each other and placed 
in same level in 'treesitter' tree - are suitable for swaps.

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
