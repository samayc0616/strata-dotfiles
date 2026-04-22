#!/usr/bin/env python3
"""
Generate SystemVerilog filelist from FuseSoC core file dependencies
Recursively extracts all file dependencies from .core files
"""

import argparse
import yaml
import sys
from pathlib import Path
from collections import deque

def parse_core_file(core_path):
    """Parse a FuseSoC .core file and extract file dependencies"""
    with open(core_path, 'r') as f:
        data = yaml.safe_load(f)

    files = []
    filesets = data.get('filesets', {})

    for fileset_name, fileset in filesets.items():
        fileset_files = fileset.get('files', [])
        for file_entry in fileset_files:
            if isinstance(file_entry, str):
                files.append(file_entry)
            elif isinstance(file_entry, dict):
                # Handle dict format: {file: path, ...}
                for key in file_entry:
                    files.append(key)

    # Also check old format in 'files' section
    if 'files' in data:
        for file_entry in data['files']:
            if isinstance(file_entry, str):
                files.append(file_entry)

    return files

def find_core_files(search_paths):
    """Find all .core files in search paths"""
    core_files = []
    for search_path in search_paths:
        path = Path(search_path)
        if path.is_dir():
            core_files.extend(path.rglob('*.core'))
    return core_files

def resolve_file_path(file_ref, core_dir, root_dir):
    """Resolve a file reference to an absolute path"""
    # Handle various file reference formats
    file_ref = file_ref.strip()

    # Remove file type annotations (e.g., : {file_type: verilogSource})
    if ':' in file_ref and '{' not in file_ref:
        file_ref = file_ref.split(':')[0].strip()

    # Try resolving relative to core directory first
    file_path = core_dir / file_ref
    if file_path.exists():
        return file_path.resolve()

    # Try resolving relative to root directory
    file_path = root_dir / file_ref
    if file_path.exists():
        return file_path.resolve()

    # Return None if file doesn't exist
    return None

def generate_filelist(root_dir, core_name=None, output_file=None):
    """Generate filelist from FuseSoC cores"""
    root_path = Path(root_dir).resolve()

    # Find all core files
    print(f"Searching for .core files in {root_path}")
    core_files = find_core_files([root_path])
    print(f"Found {len(core_files)} .core files")

    # Extract all SV/V files
    all_files = set()
    processed_cores = set()

    for core_file in core_files:
        if core_name and core_name not in str(core_file):
            continue

        try:
            core_dir = core_file.parent
            files = parse_core_file(core_file)

            for file_ref in files:
                # Only process Verilog/SystemVerilog files
                if any(file_ref.endswith(ext) for ext in ['.sv', '.svh', '.v', '.vh']):
                    resolved = resolve_file_path(file_ref, core_dir, root_path)
                    if resolved and resolved.exists():
                        all_files.add(str(resolved))

            processed_cores.add(core_file.name)
        except Exception as e:
            print(f"Warning: Failed to process {core_file}: {e}", file=sys.stderr)

    # Sort files
    sorted_files = sorted(all_files)

    # Write to output
    if output_file:
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            for file in sorted_files:
                f.write(file + '\n')
        print(f"\nGenerated {output_path} with {len(sorted_files)} files")
    else:
        for file in sorted_files:
            print(file)

    print(f"\nProcessed {len(processed_cores)} cores")
    print(f"Total files: {len(sorted_files)}")

    return sorted_files

def main():
    parser = argparse.ArgumentParser(
        description='Generate SystemVerilog filelist from FuseSoC .core files'
    )
    parser.add_argument('root_dir', help='Root directory to search for .core files')
    parser.add_argument('-c', '--core', help='Filter by core name (substring match)')
    parser.add_argument('-o', '--output', help='Output file path')
    parser.add_argument('--veridian', action='store_true',
                       help='Also create veridian.filelist in the root directory')

    args = parser.parse_args()

    files = generate_filelist(args.root_dir, args.core, args.output)

    # Also create veridian.filelist if requested
    if args.veridian and not args.output:
        veridian_path = Path(args.root_dir) / 'veridian.filelist'
        with open(veridian_path, 'w') as f:
            for file in files:
                f.write(file + '\n')
        print(f"\nAlso created {veridian_path}")

if __name__ == '__main__':
    main()
