# poonstack.nvim

inspo: [TJ DeVries - Neovim Lua Plugin From Scratch](https://www.youtube.com/watch?v=n4Lp4cV8YR0&ab_channel=TJDeVries)

<br>
<div align="center">
    <h3> 
        <code>harpoon</code> + <code>stackmap</code> 
    </h3>
</div>
<br>

Inspired by teej's video on making Neovim Lua Plugin From Scratch and because I
need something like this for work.

Problem

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

Ideation

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

## Functional Requirement

1. It shall save the current branch's `harpoon` list to a `poonstack` file

   1. It shall be named based on the absolute path of the current working
      directory with its slashes (`/`) replaced with percents (`%`)
   2. It shall be a `json` file
      - e.g. `/Users/username/something/cool > %Users%username%something%cool.json`

2. It shall save the `poonstack` file to a `poonstack` directory

   - e.g. `~/.local/state/nvim/poonstack/`

3. It shall save the current branch's `harpoon` list to the file on,

   1. `BufWritePost`
   2. `BufLeave`
   3. Git branch switch

4. It shall load the `harpoon` list from the `poonstack` file on,

   1. Neovim startup
   2. Git branch switch

5. It shall NOT save/load the `harpoon` when the current working directory is not
   tracked
