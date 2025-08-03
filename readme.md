# FM Picker for neovim

A file picker & complete file manager plugin using Toggleterm and `fm`.

`fm` is a Rust TUI file manager. Communicates with Neovim via Unix sockets.

- [Repositary](https://github.com/qkzk/fm) 
- [Crates.io](https://crates.io/crates/fm-tui)
- [Docs.rs](https://docs.rs/fm-tui/latest/fm/)

## What does it do ?

### File picking

1. Open fm `:FmPickerToggle`. Your current buffer is selected.
2. Move to a file and press `Enter` to pick it. The window is hidden.

You can quit fm with `q`.

### Deleting / moving a file in fm 

1. Open fm `:FmPickerToggle`
2. Delete a file opened in a neovim buffer. Close fm with `q`
3. The buffer is removed.

If you rename a file instead of deleting it, nvim does the buffer renaming for us.

## Requirements

- [fm](https://github/qkzk/fm) Version >= 0.2.1
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

## Installation

With Lazy:

```lua
use {
  'qkzk/fm-picker.nvim',
  config = function()
    require('fm_picker').setup {
      -- where is your fm executable located ? `which fm` should tell you!
      fm_path = 'path/to/fm/file_picker/fm',
    }
  end,
  requires = { 'akinsho/toggleterm.nvim' }
}
```

## Usage

```vimscript
:FmPickerToggle
```

Bind a key to this command et voilà.
