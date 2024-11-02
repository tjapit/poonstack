# poonstack.nvim

<div align="center">
<br>
    <h3> 
        <code>harpoon</code> + <code>stackmap</code> 
    </h3>
<br>
</div>

Inspired by teej's video on making Neovim Lua Plugin From Scratch[^teej-neovim-plugin] and because I
need something like this for work.

[^teej-neovim-plugin]: [TJ DeVries - Neovim Lua Plugin From Scratch](https://www.youtube.com/watch?v=n4Lp4cV8YR0&ab_channel=TJDeVries)

- [Documentation](#Documentation)
- [Problem](#Problem)
- [Solution](#Solution)
- [Installation](#Installation)

## Documentation

See `:help poonstack.nvim`

`poonstack` keeps track of your harpoons on a per-branch basis within a
project. If you're like me and you have trouble context-switching on the job,
when there's an urgent bug that needs hotfixing, you might have to delete your
current harpoon'd files and start over to trace the bug.

This plugin tries to ease that burden so that when you create a new `hotfix`
branch, you can breathe in peace knowing that the harpoon'd files for the
`feature` that you were working on is safely stored and will automagically load
back in when you switch back from your `hotfix` to `feature` branch.

## Problem

> I have a hard time switching between tasks, the cost of context switching is
> sometimes too big depending on the task. Sometimes there's just sudden bugs
> that appear on regression testing, from CS, from QA, etc. To mitigate this, I
> use `harpoon` like a RAM for my brain to store the files related to the
> branch I'm currently working on (`feature`, or `hotfix`, or whatever). But
> the problem is that `harpoon` saves its list on a per-project basis. Not on a
> per-branch basis.
>
> There is `git-worktree` and I can just switch projects and have `harpoon`
> work that way, but I've tried `git-worktree` before and didn't like the
> additional commands that I have to tack on to each git operations. I'm
> comfortable with switching branches, with what I know.
>
> I keep a doc of what I'd love to improve on my Neovim experience, this one
> has popped up twice now. Indicating that it's been kind of a thorn on my
> side. Then I remembered that I've watched and followed along with teej's
> tutorial on making a Neovim plugin with Lua from scratch. So... why not just
> make my own plugin?

## Solution

> The idea of having a stack to pop off and push on list of `harpoon` items
> came from teej's `stackmap.nvim`, where you sort of pop off/on keymaps based
> on the mode you're in. So why not pop off/on `harpoon` list based on the
> current branch you're on? Perfect! This would definitely help me with
> context-switching between tasks. If there's a bug that comes along and needs
> a hotfix, I can just create a new branch, leave the current feature branch
> I'm working on (with full knowledge that the `harpoon` list for that branch
> is safe), and continue working on that hotfix with its new set of `harpoon`
> items. Neat!
>
> At first it was going to be `harpoon-saver` (bleugh, I know), but then
> `poonstack` came to me.
>
> It's the perfect name.[^poon]

[^poon]:
    <small>no, it has nothing to do with that
    [poon](https://www.urbandictionary.com/define.php?term=poon), get your mind
    out of the gutter.</small>

## Installation

- Required plugins:
  - `ThePrimeagen/harpoon`
  - `nvim-telescope/telescope.nvim`
- Install with your plugin manager of choice. The example below uses Packer,

```lua
use({
  "tjapit/poonstack.nvim",
  requires = {
    "nvim-telescope/telescope.nvim",
    "ThePrimeagen/harpoon"
  }
})
```

## Configuration

TODO: add configuration options

```lua
require("poonstack").setup()
```
