#!/usr/bin/env python3
"""
strata-dotfiles installer.

    python3 install.py                  # install everything
    python3 install.py --nvim --zsh     # install only listed modules

Flags:
    --zsh     zshrc, p10k, zinit
    --tmux    tmux.conf, tpm
    --nvim    nvim config + binary (if missing)
    --apps    kitty, htop, git (prompted), fzf, zoxide, eza, fd, Meslo Nerd Font
              (all installs are user-local — no sudo required)
    --bin     personal scripts -> ~/bin
    --claude  Claude Code settings + Monokai statusline

Anything that would be overwritten is moved to ~/.dotfiles-backup/<timestamp>/ first.
"""

import argparse
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parent
HOME = Path.home()
TIMESTAMP = datetime.now().strftime("%Y%m%d-%H%M%S")
BACKUP_DIR = HOME / ".dotfiles-backup" / TIMESTAMP

UPDATE_MODE = False  # set by --update; skips binary installs, only refreshes symlinks


# ---------- output helpers (Monokai Pro) ----------
class C:
    R = "\033[0m"
    B = "\033[1m"
    PINK = "\033[38;2;255;97;136m"
    CYAN = "\033[38;2;120;220;232m"
    YELLOW = "\033[38;2;255;216;102m"
    GREEN = "\033[38;2;169;220;118m"
    ORANGE = "\033[38;2;252;152;103m"
    PURPLE = "\033[38;2;171;157;242m"
    GREY = "\033[38;2;114;112;114m"


def info(msg): print(f"  {C.CYAN}i{C.R} {msg}")
def ok(msg):   print(f"  {C.GREEN}✓{C.R} {msg}")
def warn(msg): print(f"  {C.YELLOW}!{C.R} {msg}")
def err(msg):  print(f"  {C.PINK}✗{C.R} {msg}", file=sys.stderr)


# ---------- primitives ----------
USER_BINS = (HOME / "bin", HOME / ".local/bin")


def have(tool: str) -> bool:
    """True if `tool` is runnable — on PATH, or already dropped into a user bin dir.

    The user bin check matters when the installer runs from a shell that predates
    the PATH entries zshrc adds (fresh machine, first install): the binary is
    there, it's just not visible to this process yet.
    """
    if shutil.which(tool) is not None:
        return True
    return any(os.access(d / tool, os.X_OK) and (d / tool).is_file() for d in USER_BINS)


def linux_arch() -> str:
    """Return the normalized Linux arch string (x86_64 or aarch64)."""
    import platform
    m = platform.machine()
    if m in ("x86_64", "amd64"):
        return "x86_64"
    if m in ("aarch64", "arm64"):
        return "aarch64"
    return m  # caller handles unsupported


def run(cmd, check=True, shell=False):
    if isinstance(cmd, str) and not shell:
        cmd = cmd.split()
    return subprocess.run(cmd, shell=shell, check=check)


def sh(snippet: str):
    """Run a shell snippet (for pipelines and curl | bash installers)."""
    return subprocess.run(["bash", "-c", snippet], check=True)


def backup(path: Path):
    """Move an existing path to BACKUP_DIR, preserving its relative location under $HOME."""
    if not path.exists() and not path.is_symlink():
        return
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    try:
        rel = path.relative_to(HOME)
    except ValueError:
        rel = Path(path.name)
    dest = BACKUP_DIR / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(path), str(dest))
    info(f"backed up {path} → {dest}")


def symlink(src: Path, dst: Path):
    """Create dst -> src. Back up any existing file/dir/symlink at dst first."""
    src = src.resolve()
    if dst.is_symlink() or dst.exists():
        if dst.is_symlink() and dst.resolve() == src:
            ok(f"already linked: {dst}")
            return
        backup(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.symlink_to(src)
    ok(f"linked {dst} → {src}")


def download(url: str, dest: Path):
    info(f"downloading {url}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    urllib.request.urlretrieve(url, dest)


# ---------- prebuilt binaries from GitHub releases ----------
def latest_release_tag(repo: str):
    """Latest release tag for a GitHub repo (e.g. "v0.10.0"), or None.

    Follows the /releases/latest redirect rather than asking api.github.com.
    The unauthenticated API is rate-limited *per source IP*, so on a shared
    login node (everyone behind one NAT) it is routinely exhausted — which is
    exactly how the old `curl … | sh` vendor installers failed here.
    """
    url = f"https://github.com/{repo}/releases/latest"
    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            final = resp.geturl()
    except Exception as e:
        warn(f"{repo}: could not resolve latest release ({e})")
        return None
    if "/tag/" not in final:
        warn(f"{repo}: unexpected redirect target {final}")
        return None
    return final.rstrip("/").rsplit("/tag/", 1)[1]


def extract_binary(archive: Path, name: str, dest_dir: Path) -> bool:
    """Pull the single file named `name` out of archive into dest_dir, +x. True on success."""
    dest_dir.mkdir(parents=True, exist_ok=True)
    target = dest_dir / name

    def write(fileobj):
        with open(target, "wb") as out:
            shutil.copyfileobj(fileobj, out)
        target.chmod(0o755)

    if archive.name.endswith(".zip"):
        with zipfile.ZipFile(archive) as zf:
            for member in zf.infolist():
                if not member.is_dir() and Path(member.filename).name == name:
                    with zf.open(member) as src:
                        write(src)
                    return True
        return False

    with tarfile.open(archive) as tf:
        for member in tf.getmembers():
            if member.isfile() and Path(member.name).name == name:
                write(tf.extractfile(member))
                return True
    return False


def install_release_binary(name: str, repo: str, assets, dest: Path = None) -> bool:
    """Install one prebuilt binary from a GitHub release into ~/.local/bin.

    `assets` is an ordered list of filename templates; the first one that
    downloads wins. Templates may use {arch}, {tag} (v1.2.3) and {version}
    (1.2.3). Put musl builds first — they're statically linked, so they run on
    distros whose glibc is older than the build host's.
    """
    if have(name):
        ok(f"{name} already installed")
        return True

    arch = linux_arch()
    if arch not in ("x86_64", "aarch64"):
        warn(f"{name}: unsupported arch {arch} — install manually from "
             f"https://github.com/{repo}/releases")
        return False

    dest = dest or (HOME / ".local/bin")
    needs_tag = any(("{tag}" in a or "{version}" in a) for a in assets)
    tag = latest_release_tag(repo)
    if tag is None and needs_tag:
        err(f"{name}: cannot determine the latest release — skipping")
        return False
    version = tag[1:] if (tag and tag.startswith("v")) else tag

    with tempfile.NamedTemporaryFile(suffix=Path(assets[0]).suffix, delete=False) as tmp:
        tpath = Path(tmp.name)
    try:
        for template in assets:
            asset = template.format(arch=arch, tag=tag, version=version)
            base = (f"https://github.com/{repo}/releases/download/{tag}" if tag
                    else f"https://github.com/{repo}/releases/latest/download")
            try:
                download(f"{base}/{asset}", tpath)
            except Exception:
                info(f"  {asset} not available, trying next...")
                continue
            if extract_binary(tpath, name, dest):
                ok(f"installed {name} to {dest / name}")
                return True
            warn(f"  {asset} contained no '{name}' binary, trying next...")
        err(f"{name}: no usable release asset found — see https://github.com/{repo}/releases")
        return False
    finally:
        tpath.unlink(missing_ok=True)


# ---------- modules ----------
def install_zsh():
    print(f"\n{C.B}{C.PINK}» zsh{C.R}")
    symlink(REPO / "zsh/zshrc", HOME / ".zshrc")
    symlink(REPO / "zsh/p10k.zsh", HOME / ".p10k.zsh")
    if UPDATE_MODE:
        return
    zinit_home = HOME / ".local/share/zinit/zinit.git"
    if zinit_home.exists():
        ok("zinit already installed")
    else:
        info("installing zinit...")
        sh("curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh | bash")


def install_tmux():
    print(f"\n{C.B}{C.PINK}» tmux{C.R}")
    symlink(REPO / "tmux/tmux.conf", HOME / ".tmux.conf")
    symlink(REPO / "tmux/tmux-help.sh", HOME / ".tmux/tmux-help.sh")
    if UPDATE_MODE:
        return
    tpm = HOME / ".tmux/plugins/tpm"
    if tpm.exists():
        ok("tpm already present")
    else:
        info("cloning tmux plugin manager...")
        run(["git", "clone", "https://github.com/tmux-plugins/tpm", str(tpm)])
        info("inside tmux, hit  prefix + I  to install plugins")


def install_nvim():
    print(f"\n{C.B}{C.PINK}» nvim{C.R}")
    symlink(REPO / "nvim", HOME / ".config/nvim")
    if UPDATE_MODE:
        return
    if have("nvim"):
        ok(f"nvim already on PATH: {shutil.which('nvim')}")
    else:
        install_nvim_binary()


def install_nvim_binary():
    arch = linux_arch()
    asset = {
        "x86_64":  "nvim-linux-x86_64.tar.gz",
        "aarch64": "nvim-linux-arm64.tar.gz",
    }.get(arch)
    if asset is None:
        warn(f"nvim binary: unsupported arch {arch} — install manually from https://github.com/neovim/neovim/releases")
        return
    url = f"https://github.com/neovim/neovim/releases/latest/download/{asset}"
    dest = HOME / ".local/share/nvim-release"
    dest.mkdir(parents=True, exist_ok=True)
    tarball = dest / "nvim.tar.gz"
    download(url, tarball)
    with tarfile.open(tarball) as tf:
        tf.extractall(dest)
    tarball.unlink()
    extracted = next(p for p in dest.iterdir() if p.is_dir() and p.name.startswith("nvim"))
    nvim_bin = extracted / "bin/nvim"
    (HOME / "bin").mkdir(exist_ok=True)
    symlink(nvim_bin, HOME / "bin/nvim")
    info("ensure ~/bin is on your PATH (zshrc handles this)")


def step(label: str, fn):
    """Run one install step in isolation. Returns the label if it failed, else None.

    Each tool install is independent, so one bad download must not take the rest
    of the module down with it (a rate-limited zoxide used to silently skip eza,
    fd and the Nerd Font).
    """
    try:
        fn()
        return None
    except KeyboardInterrupt:
        raise
    except Exception as e:
        err(f"{label}: {e}")
        return label


def install_apps():
    print(f"\n{C.B}{C.PINK}» apps{C.R}")
    symlink(REPO / "apps/kitty", HOME / ".config/kitty")
    symlink(REPO / "apps/htop/htoprc", HOME / ".config/htop/htoprc")
    symlink(REPO / "apps/git/gitignore_global", HOME / ".config/git/ignore")
    # apps/bin scripts are part of --apps too
    install_bin()
    if UPDATE_MODE:
        return
    failed = [f for f in (
        step("git config", configure_git),
        step("fzf", install_fzf),
        step("zoxide", install_zoxide),
        step("eza", install_eza),
        step("fd", install_fd),
        step("Meslo Nerd Font", install_nerd_font),
    ) if f]
    if failed:
        raise RuntimeError(f"these app steps failed: {', '.join(failed)}")


def configure_git():
    gitconfig = HOME / ".gitconfig"
    if gitconfig.exists():
        ok(f"{gitconfig} already exists — leaving alone")
        return
    if not sys.stdin.isatty():
        warn("no terminal attached — skipping git identity prompt "
             "(rerun `python3 install.py --apps` interactively)")
        return
    print(f"\n  {C.YELLOW}git config — who are you?{C.R}")
    try:
        name = input(f"    {C.GREY}full name:{C.R} ").strip() or "Your Name"
        email = input(f"    {C.GREY}email:    {C.R} ").strip() or "you@example.com"
    except EOFError:
        warn("no input — skipping git config")
        return
    template = (REPO / "apps/git/gitconfig.template").read_text()
    gitconfig.write_text(template.format(name=name, email=email))
    ok(f"wrote {gitconfig}")


def install_fzf():
    if have("fzf"):
        ok("fzf already installed")
        return
    fzf_dir = HOME / ".fzf"
    if not fzf_dir.exists():
        info("cloning fzf...")
        run(["git", "clone", "--depth=1", "https://github.com/junegunn/fzf.git", str(fzf_dir)])
    info("running fzf install...")
    run([str(fzf_dir / "install"), "--all", "--no-bash", "--no-fish"])


def install_zoxide():
    """zoxide (smart `cd`) — zshrc evals `zoxide init` on every shell start.

    Deliberately *not* the upstream `curl … | sh` installer: that script asks
    api.github.com for the latest version, and gets rate-limited to death on
    shared machines. zoxide ships linux binaries as musl only.
    """
    install_release_binary(
        "zoxide", "ajeetdsouza/zoxide",
        ["zoxide-{version}-{arch}-unknown-linux-musl.tar.gz"],
    )


def install_eza():
    """eza (better `ls`) — zshrc aliases ls/ll/lrt onto it. No sudo, no cargo."""
    install_release_binary(
        "eza", "eza-community/eza",
        # musl is x86_64-only upstream; the gnu fallback covers aarch64.
        ["eza_{arch}-unknown-linux-musl.tar.gz",
         "eza_{arch}-unknown-linux-gnu.tar.gz"],
    )


def install_fd():
    """fd — backs FZF_DEFAULT_COMMAND / FZF_ALT_C_COMMAND, i.e. Ctrl-T and Alt-C."""
    install_release_binary(
        "fd", "sharkdp/fd",
        ["fd-{tag}-{arch}-unknown-linux-musl.tar.gz",
         "fd-{tag}-{arch}-unknown-linux-gnu.tar.gz"],
    )


def install_nerd_font():
    """Install MesloLGLDZ Nerd Font (needed for branch glyph, devicons, etc.)."""
    font_dir = HOME / ".local/share/fonts/MesloNerdFont"
    if font_dir.exists() and any(font_dir.glob("*.ttf")):
        ok("Meslo Nerd Font already installed")
        return
    url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    font_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".zip", delete=False) as tmp:
        zpath = Path(tmp.name)
    try:
        download(url, zpath)
        with zipfile.ZipFile(zpath) as zf:
            zf.extractall(font_dir)
    finally:
        zpath.unlink(missing_ok=True)
    ok(f"installed Meslo Nerd Font to {font_dir}")
    if have("fc-cache"):
        run(["fc-cache", "-f"])
        ok("refreshed font cache")
    else:
        warn("fc-cache not found — run it manually after install")


def install_bin():
    print(f"\n{C.B}{C.PINK}» bin{C.R}")
    bin_dir = HOME / "bin"
    bin_dir.mkdir(exist_ok=True)
    for script in sorted((REPO / "apps/bin").iterdir()):
        if script.is_file():
            symlink(script, bin_dir / script.name)


def install_claude():
    print(f"\n{C.B}{C.PINK}» claude{C.R}")
    symlink(REPO / "claude/settings.json", HOME / ".claude/settings.json")
    symlink(REPO / "claude/statusline-command.sh", HOME / ".claude/statusline-command.sh")
    symlink(REPO / "claude/load-project-skills.sh", HOME / ".claude/load-project-skills.sh")


MODULES = {
    "zsh":    install_zsh,
    "tmux":   install_tmux,
    "nvim":   install_nvim,
    "apps":   install_apps,
    "bin":    install_bin,
    "claude": install_claude,
}

# Canonical "is this module installed?" paths — at least one must be a symlink
# into REPO for the module to count as installed.
INSTALL_MARKERS = {
    "zsh":    [HOME / ".zshrc", HOME / ".p10k.zsh"],
    "tmux":   [HOME / ".tmux.conf", HOME / ".tmux/tmux-help.sh"],
    "nvim":   [HOME / ".config/nvim"],
    "apps":   [HOME / ".config/kitty", HOME / ".config/htop/htoprc"],
    "bin":    [],  # see module_installed() — checks any symlink under ~/bin pointing into REPO/bin
    "claude": [HOME / ".claude/settings.json", HOME / ".claude/statusline-command.sh"],
}


def _points_into_repo(path: Path) -> bool:
    if not path.is_symlink():
        return False
    try:
        target = path.resolve(strict=False)
    except Exception:
        return False
    try:
        target.relative_to(REPO)
        return True
    except ValueError:
        return False


def module_installed(name: str) -> bool:
    if name == "bin":
        bin_dir = HOME / "bin"
        if not bin_dir.exists():
            return False
        for entry in bin_dir.iterdir():
            if _points_into_repo(entry):
                return True
        return False
    return any(_points_into_repo(p) for p in INSTALL_MARKERS.get(name, []))


# ---------- main ----------
def main():
    global UPDATE_MODE
    p = argparse.ArgumentParser(
        description="strata-dotfiles installer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="run with no module flags to install everything.",
    )
    for name in MODULES:
        p.add_argument(f"--{name}", action="store_true", help=f"select {name}")
    p.add_argument("--update", action="store_true",
                   help="refresh already-installed modules (git pull + re-link); "
                        "skips binary installs and does NOT add new modules")
    args = p.parse_args()

    explicit = [name for name in MODULES if getattr(args, name)]

    if args.update:
        UPDATE_MODE = True
        installed = [n for n in MODULES if module_installed(n)]
        if not installed:
            err("nothing installed — run `python3 install.py` first.")
            sys.exit(1)
        # narrow to explicit flags if given, else all installed
        selected = [n for n in explicit if n in installed] if explicit else installed
        skipped = sorted(set(explicit) - set(installed))
        if skipped:
            warn(f"skipping not-installed: {' '.join(skipped)}")
        if not selected:
            err("no installed modules match the flags given.")
            sys.exit(1)
    else:
        selected = explicit or list(MODULES)

    banner = f"{C.B}{C.PINK}strata-dotfiles{C.R}"
    mode = "updating" if UPDATE_MODE else "installing"
    print(f"\n{banner}  {mode}: {C.CYAN}{' '.join(selected)}{C.R}")
    print(f"             backups: {C.GREY}{BACKUP_DIR}{C.R}")

    for tool in ("git", "curl"):
        if not have(tool):
            err(f"{tool} is required. install it and retry.")
            sys.exit(1)

    if UPDATE_MODE and (REPO / ".git").exists():
        info(f"\ngit pull in {REPO}")
        try:
            run(["git", "-C", str(REPO), "pull", "--ff-only"])
        except subprocess.CalledProcessError:
            warn("git pull failed — continuing with local files")

    failed = []
    for name in selected:
        try:
            MODULES[name]()
        except subprocess.CalledProcessError as e:
            err(f"{name} failed: {e}")
            failed.append(name)
        except KeyboardInterrupt:
            err(f"{name} interrupted")
            sys.exit(130)
        except Exception as e:
            err(f"{name} error: {e}")
            failed.append(name)

    print()
    if failed:
        err(f"completed with errors in: {' '.join(failed)}")
        sys.exit(1)
    verb = "updated" if UPDATE_MODE else "done"
    print(f"{C.B}{C.GREEN}✓ {verb}.{C.R} open a new shell to pick up changes.")


if __name__ == "__main__":
    main()
