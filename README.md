<div align="center">
  <picture>
    <source srcset="assets/shunpo_logo.png" media="(prefers-color-scheme: dark)">
    <img src="assets/shunpo_logo_inverted.png" alt="Logo" width="400" style="margin: 0; padding: 0;">
  </picture>
  <h4><i>Quick navigation with minimal mental overhead.</i></h4>
</div>

----
Shunpo is a minimalist bash tool that tries to make directory navigation in terminal just a little bit faster by providing a simple system to manage bookmarks and jump to directories with only a few keystrokes.
If you frequently need to use commands like `cd`, `pushd`, or `popd`, Shunpo is for you.  

![Powered by 🍵](https://img.shields.io/badge/Powered%20by-%F0%9F%8D%B5-blue?style=flat-square)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Buy%20me%20Tea-ff5f5f?logo=kofi&style=flat-square)](https://ko-fi.com/egurapha)
![Built With Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3?logo=nixos&logoColor=white&style=flat-square)
![Code Formatting](https://img.shields.io/github/actions/workflow/status/egurapha/Shunpo/code_formatting.yml?branch=main&label=Code%20Formatting&style=flat-square)
![Unit Tests](https://img.shields.io/github/actions/workflow/status/egurapha/Shunpo/unit_testing.yml?branch=main&label=Unit%20Tests&style=flat-square)

Requirements
----
Bash 3.2 or newer.

Installation
----
Run `install.sh && source ~/.bashrc`. For nix, click [here](nix/NixREADME.md).

Tutorial
----
Click [here](https://www.youtube.com/watch?v=TN66A3MPo50) for a video tutorial.  
<img src="assets/shunpo_demo.gif" width="600" height="auto" alt="Shunpo Demo">

Commands
----
#### Bookmarking:
`sb`: Add the current directory to bookmarks.  
`sg`, `sg [#]` : Go to a bookmark.  
`sr`, `sr [#]` : Remove a bookmark.  
`sl`: List all bookmarks.  
`sc`: Clear all bookmarks.   

#### Navigation:
`sj`, `sj [#]`: "Jump" up to a parent directory.  
`sd`: "Dive" down to a child directory.

#### Selection:
`0~9`: Select an option.
`n`: Next page.
`p`: Previous page.
`b`: Move selection back to parent directory. (For `sd` only.)
`Enter`: Navigate to selected directory (For `sd` only.)

Customization
----
You can customize the selection keys by editing the config file at `~/.config/shunpo/config`:

```bash
# Selection keys (exactly 10 characters, one per menu item)
SHUNPO_SELECTION_KEYS="asdfghjkl;"
```

**Rules:**
- Must be exactly 10 characters (one for each menu item)
- Cannot contain `n`, `p`, or `b` (reserved for navigation)
- No duplicate characters allowed
- Invalid configs fall back to the default `1234567890`

**Note:** CLI arguments (e.g., `sg 3`, `sj 1`) always use numeric indices 0-9, regardless of your custom keys.

Uninstalling
----
Run `uninstall.sh`

