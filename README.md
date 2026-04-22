# strata-dotfiles

My Linux dotfiles — zsh, tmux, neovim, kitty, and Claude Code — with a one-click Python installer.

## install

```bash
git clone https://github.com/samayc0616/strata-dotfiles.git ~/strata-dotfiles
cd ~/strata-dotfiles
python3 install.py
```

Run with no flags to install everything. Existing files are backed up to `~/.dotfiles-backup/<timestamp>/` before anything is overwritten.

## partial install

Pass one or more flags to install a subset:

```bash
python3 install.py --nvim --zsh
```

| flag       | what it installs                                                          |
|------------|---------------------------------------------------------------------------|
| `--zsh`    | `~/.zshrc`, `~/.p10k.zsh`, [zinit][zinit] plugin manager                  |
| `--tmux`   | `~/.tmux.conf`, `~/.tmux/tmux-help.sh` (`prefix + ?` popup), [tpm][tpm] (plugins install on first tmux launch via `prefix + I`) |
| `--nvim`   | `~/.config/nvim` + the `nvim` binary if it's not on `PATH`                |
| `--apps`   | kitty, starship, htop, git (prompts for name/email), fzf, zoxide, eza, Meslo Nerd Font, **and all `--bin` scripts** |
| `--bin`    | personal scripts (in `apps/bin/`) symlinked into `~/bin` — subset of `--apps` for lightweight installs |
| `--claude` | Claude Code `settings.json` + Monokai Pro statusline                      |
| `--update` | `git pull` + re-link config files for **already-installed** modules only; skips binary installs and refuses to add new modules. Errors if nothing is installed yet. |

## what's in here

```
strata-dotfiles/
├── install.py                    # the installer
├── zsh/                          # zshrc + p10k config
├── tmux/                         # tmux.conf + tmux-help.sh (prefix + ? popup)
├── nvim/                         # full ~/.config/nvim (LazyVim-based + monokai-pro)
├── apps/
│   ├── bin/                      # helper scripts -> ~/bin
│   ├── kitty/                    # kitty.conf (Monokai Pro)
│   ├── starship.toml             # prompt (backup to p10k)
│   ├── htop/                     # htoprc
│   └── git/                      # gitconfig template + global ignore
└── claude/                       # Claude Code settings + statusline
```

## statusline preview

The Claude Code statusline is Monokai Pro themed and includes:

```
Opus 4.7 │ ~/repo/src │  branch │ ctx 32% │ 5h 3% · in 4h 34m │ 7d 22% │ $26.58 │ +142 -37
```

- model · directory (anchor bold) · git branch · context % (threshold colored) · 5h rate limit + reset countdown · 7d rate limit · session cost · diff stats
- segments auto-hide when their data is absent (no cost yet, no rate limit pre-first-call, etc.)

## requirements

- Linux (tested on RHEL 9 and Ubuntu 22), x86_64
- `git`, `curl`, `python3` (≥ 3.8) — anything else is installed by the installer
- Optional: `cargo` for `eza` (installer skips with a note if absent)

## re-running / updating

Safe to re-run. Symlinks that already point at the right place are left alone; anything else gets backed up.

To pull the latest repo and refresh only what you already have installed:

```bash
cd ~/strata-dotfiles
python3 install.py --update
```

`--update` auto-detects which modules you installed (by checking symlinks in your `$HOME` that point into the repo), runs `git pull`, and re-links those modules only. It **will not** install modules you never opted into, and will error out if nothing is installed.

You can also combine with specific flags, e.g. `python3 install.py --update --zsh --nvim` — that refreshes those two if they're installed, and warns about any that aren't.

## uninstall

No automated uninstall. Remove the symlinks you care about and (optionally) restore from `~/.dotfiles-backup/<timestamp>/`.

[zinit]: https://github.com/zdharma-continuum/zinit
[tpm]: https://github.com/tmux-plugins/tpm
