# cheatsheet

Everything interesting configured by this repo. Loosely grouped by tool.

## shell (zsh)

### navigation
| keys | does |
|---|---|
| `cd <partial>` | **zoxide** — jumps to most-frecent matching dir (zoxide aliased over `cd`) |
| `cdi` | zoxide **interactive** picker (fzf-style) |
| `z <partial>` / `zi` | same as `cd` / `cdi` (zoxide's own names still work) |
| `1` / `2` / `3` / `4` / `5` | `cd ..`, `cd ../..`, … up N levels |
| `Ctrl-T` | fzf **file picker** — insert selected path at cursor |
| `Ctrl-R` | fzf **history search** |
| `Alt-C` | copy current command line to clipboard via OSC52 (doesn't execute) |
| `Alt-N` | prepend `notify` to current command + run (pings you on Slack when done) |
| `Shift-Tab` | accept zsh autosuggestion |

### listing (eza)
| cmd | does |
|---|---|
| `ls` | `eza --icons --color=always` |
| `ll` | long listing, sorted newest-first |
| `lrt` | same as `ll` |

### custom functions
| cmd | does |
|---|---|
| `mux` | attach or create tmux session named `main` (no-ops if already inside tmux) |
| `claude` | wrapper: redirects `$TMPDIR` into `$PWD/.claude-tmp/$$` so Claude Code doesn't fill `~/tmp` quota. Auto-sweeps orphaned subdirs. Skipped in `$HOME`. |
| `notify "cmd"` | run a command and ping Slack when it exits |
| `notify --silent "cmd"` | run + notify with no sound |

---

## tmux

**prefix = `Ctrl-a`** (also `Ctrl-b`). **Press `prefix + ?` any time** for the Monokai-themed popup — that's the authoritative live reference.

### prefix bindings
| keys | does |
|---|---|
| `prefix + ?` | help popup |
| `prefix + r` | reload `.tmux.conf` |
| `prefix + c` | new window (inherits current dir) |
| `prefix + C-c` | **new session** |
| `prefix + C-f` | find/switch session by name |
| `prefix + "` or `-` | split horizontal (top/bottom) |
| `prefix + %` or `_` | split vertical (left/right) |
| `prefix + z` | zoom toggle current pane |
| `prefix + S` | toggle synchronize-panes |
| `prefix + m` | toggle mouse |
| `prefix + F` | fzf picker over sessions/windows/panes (tmux-fzf plugin) |

### no-prefix (chorded with Ctrl/Alt)
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate panes (vim-aware — sends through to nvim) |
| `Alt-h/l` | previous / next **window** |
| `Alt-j/k` | previous / next **session** |
| `Alt-1 … 9` | jump to window N |
| `Alt-H/J/K/L` (shift) | resize pane |

### copy mode (vi)
| keys | does |
|---|---|
| `prefix + [` | enter copy mode |
| `v` | begin selection |
| `C-v` | rectangle toggle |
| `y` | copy selection + exit |
| `Esc` | cancel |

---

## neovim (kickstart/LazyVim, leader = `Space`)

### telescope (fuzzy everything)
| keys | does |
|---|---|
| `<leader>sf` | **S**earch **F**iles |
| `<leader>sg` | **S**earch by **G**rep (live_grep) |
| `<leader>sw` | Search current **W**ord |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Find existing buffers |
| `<leader>sh` | Search **H**elp tags |
| `<leader>sk` | Search **K**eymaps (your cheatsheet, in-editor) |
| `<leader>sd` | Search **D**iagnostics |
| `<leader>sr` | Search **R**esume last telescope session |

### windows / panes
| keys | does |
|---|---|
| `Ctrl-h/j/k/l` | navigate windows (plays nice with tmux) |
| `<Esc>` | clear search highlight |
| `<Esc><Esc>` (terminal mode) | exit terminal-mode back to normal |

### editor
| keys | does |
|---|---|
| `<leader>q` | push diagnostics → location list |
| `<leader>ut` | toggle **U**ndo**t**ree |
| `<leader>c` (normal/visual) | **OSC52 copy** — sends to local clipboard over SSH |
| `<leader>cc` | OSC52 copy whole line |

### leader groups (type the prefix and pause — `which-key` shows the rest)
| prefix | group |
|---|---|
| `<leader>c` | **C**ode (actions, format, refactor) |
| `<leader>d` | **D**ocument symbols |
| `<leader>r` | **R**ename |
| `<leader>s` | **S**earch (telescope) |
| `<leader>w` | **W**orkspace |
| `<leader>t` | **T**oggle options |
| `<leader>h` | Git **H**unk (gitsigns) |

### vanilla-vim reminders
| keys | does |
|---|---|
| `:w` / `:q` / `:wq` | write / quit / both |
| `:%s/foo/bar/g` | replace all |
| `gd` / `gr` | goto def / find references (LSP) |
| `K` | hover docs (LSP) |
| `[d` / `]d` | prev / next diagnostic |
| `u` / `Ctrl-r` | undo / redo |

---

## kitty (terminal)

Monokai Pro palette set as both the ANSI 16-color slots and the base background/foreground. Font is `MesloLGM Nerd Font Mono @ 14pt`.

Notable settings baked in:
| setting | value |
|---|---|
| `font_family` | `MesloLGM Nerd Font Mono` (installed by `--apps`) |
| `font_size` | `14.0` |
| `macos_option_as_alt` | `yes` (Option key sends Alt — enables `Alt-h/l/j/k/N/C` over SSH) |
| `clipboard_control` | `write-clipboard write-primary no-append` (OSC52 works cleanly) |
| `allow_remote_control` | `yes` |
| `Home` / `End` | mapped to standard `\x1b[1~` / `\x1b[4~` so readline/vim agree |

### kitty keyboard basics (default bindings)
| keys | does |
|---|---|
| `Ctrl-Shift-C` / `V` | copy / paste |
| `Ctrl-Shift-Enter` | split window |
| `Ctrl-Shift-T` | new tab |
| `Ctrl-Shift-Q` | close window |
| `Ctrl-Shift-F5` | reload config |

---

## prompt (powerlevel10k)

Active prompt. Styled Monokai Pro:
- `#78DCE8` directory (anchor/leaf bold)
- `#AB9DF2` git branch
- `#A9DC76` clean / success · `#FF6188` error / dirty
- `#FFD866` modified files · `#727072` muted separators

Useful p10k commands:
| cmd | does |
|---|---|
| `p10k configure` | re-run the interactive configurator |
| `p10k reload` | reload prompt without restarting shell |

---

## Claude Code

The statusline this repo installs shows:

```
Opus 4.7 │ ~/dir │  branch │ ctx N% │ 5h N% · in Xh Ym │ 7d N% │ $N.NN │ +A -D
```

segments: model · directory (anchor bold) · git branch · context % (green→yellow→orange→pink thresholds) · 5h rate limit + reset countdown · 7d rate limit · session cost · diff stats. each segment auto-hides when data is absent.

### useful slash commands
| cmd | does |
|---|---|
| `/help` | full list |
| `/rename <name>` | name the session (appears on statusline when set) |
| `/clear` | clear context |
| `/model` | switch model |
| `/fast` | toggle fast mode (Opus 4.6) |
| `/loop <interval> <cmd>` | schedule recurring prompts |

---

## what `--apps` installs (binaries & fonts)

| tool | what |
|---|---|
| `fzf` | fuzzy picker (powers `Ctrl-T`, `Ctrl-R`, `prefix + F` in tmux) |
| `zoxide` | smart `cd` |
| `eza` | better `ls` |
| Meslo Nerd Font | powerline glyphs, devicons, branch ``, etc. |

---

## updating

```bash
cd ~/strata-dotfiles
python3 install.py --update
```

Detects which modules you already installed (by checking symlinks under `$HOME` pointing into the repo), pulls latest, re-links only those. Won't add new modules. Errors if nothing's installed.
