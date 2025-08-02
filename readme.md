# FM Picker for neovim

Companion plugin for fm : 

- [Repositary](https://github.com/qkzk/fm) 
- [Crates.io](https://crates.io/crates/fm-tui)
- [Docs.rs](https://docs.rs/fm-tui/latest/fm/)



A file manager picker using Toggleterm and a Rust TUI (`fm`). Communicates with Neovim via Unix sockets.

## Requirements

- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [fm](https://github/qkzk/fm)

## Installation

```lua
use {
  'qkzk/fm-picker.nvim',
  requires = { 'akinsho/toggleterm.nvim' }
}
```

## Usage

```vimscript
:FmPickerToggle
```
