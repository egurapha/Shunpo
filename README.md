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
![Code Formatting](https://img.shields.io/github/actions/workflow/status/egurapha/Shunpo/code_formatting.yml?branch=main&label=Code%20Formatting&style=flat-square)
![Unit Tests](https://img.shields.io/github/actions/workflow/status/egurapha/Shunpo/unit_testing.yml?branch=main&label=Unit%20Tests&style=flat-square)

Requirements
----
Bash 3.2 or newer.

Installation
----
Run `install.sh && source ~/.bashrc`.

### Building with Nix Flakes

To build the project using Nix flakes, follow these steps:

1. Ensure you have Nix installed. If not, you can install it from [here](https://nixos.org/download.html).
2. Run the following command to enter a development shell with all dependencies:
   ```sh
   nix develop
   ```
3. To build the project, run:
   ```sh
   nix build
   ```

### Development Shell with Nix Flakes

To enter a development shell with all dependencies using Nix flakes, follow these steps:

1. Ensure you have Nix installed. If not, you can install it from [here](https://nixos.org/download.html).
2. Run the following command to enter the development shell:
   ```sh
   nix develop
   ```

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
 
Uninstalling
----
Run `uninstall.sh`

