#!/usr/bin/env python3
"""
Generate verible.filelist from a .scr file
Usage: gen_verible_filelist.py <path_to_scr> <path_to_verif_dir>
"""

import sys
import os
from pathlib import Path


def main():
    if len(sys.argv) != 3:
        print("Usage: gen_verible_filelist.py <path_to_scr> <path_to_verif_dir>")
        print("Example: gen_verible_filelist.py /path/to/file.scr /path/to/verif")
        sys.exit(1)

    scr_file = Path(sys.argv[1])
    verif_dir = Path(sys.argv[2])
    output_file = verif_dir / "verible.filelist"

    if not scr_file.exists():
        print(f"Error: SCR file not found: {scr_file}")
        sys.exit(1)

    if not verif_dir.exists():
        print(f"Error: Verif directory not found: {verif_dir}")
        sys.exit(1)

    # Extract file paths
    valid_extensions = {'.v', '.sv', '.svh', '.vh'}
    file_paths = []

    with open(scr_file, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and lines starting with +define+ or +incdir+
            if not line or line.startswith('+define+') or line.startswith('+incdir+'):
                continue

            # Check if line ends with valid extension
            if any(line.endswith(ext) for ext in valid_extensions):
                file_paths.append(line)

    # Write to output file
    with open(output_file, 'w') as f:
        for path in file_paths:
            f.write(f"{path}\n")

    print(f"Generated verible.filelist with {len(file_paths)} files at: {output_file}")


if __name__ == "__main__":
    main()
