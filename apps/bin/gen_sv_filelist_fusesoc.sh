#!/bin/bash
# Generate SystemVerilog filelist using FuseSoC
# Usage: gen_sv_filelist_fusesoc.sh <core_name> <output_path>
#
# Example: gen_sv_filelist_fusesoc.sh vendor:lib:core:1.0 ~/my_project/veridian.filelist

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <fusesoc_core_name> [output_file]"
    echo "Example: $0 vendor:lib:core:1.0"
    echo ""
    echo "This will generate both veridian.filelist and verible.filelist"
    echo "If output_file is specified, it will be used instead"
    exit 1
fi

CORE_NAME="$1"
OUTPUT_FILE="${2:-}"

# Create a temporary build directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Generating filelist for core: $CORE_NAME"
echo "Using temp directory: $TEMP_DIR"

# Run fusesoc to get the filelist
cd "$TEMP_DIR"
fusesoc run --target=sim --setup-only "$CORE_NAME" 2>&1 | tee fusesoc.log

# Find the generated build directory
BUILD_DIR=$(find "$TEMP_DIR" -name "build" -type d | head -1)

if [ -z "$BUILD_DIR" ]; then
    echo "Error: Could not find fusesoc build directory"
    echo "Check fusesoc.log for errors"
    exit 1
fi

echo "Found build directory: $BUILD_DIR"

# Find all .v, .sv, .svh files in the build directory
# These are the actual source files fusesoc gathered
FILELIST_TMP="$TEMP_DIR/files.list"
find "$BUILD_DIR" -type f \( -name "*.sv" -o -name "*.svh" -o -name "*.v" -o -name "*.vh" \) \
    ! -path "*/obj_dir/*" \
    ! -path "*/.git/*" \
    -print | sort > "$FILELIST_TMP"

FILE_COUNT=$(wc -l < "$FILELIST_TMP")
echo "Found $FILE_COUNT files"

# Determine output location
if [ -n "$OUTPUT_FILE" ]; then
    VERIDIAN_OUTPUT="$OUTPUT_FILE"
    VERIBLE_OUTPUT="${OUTPUT_FILE%.filelist}.verible.filelist"
else
    # Use current directory
    VERIDIAN_OUTPUT="veridian.filelist"
    VERIBLE_OUTPUT="verible.filelist"
fi

# Copy to veridian.filelist (absolute paths)
cp "$FILELIST_TMP" "$VERIDIAN_OUTPUT"
echo "Generated: $VERIDIAN_OUTPUT ($FILE_COUNT files)"

# Also create verible.filelist (verible uses same format)
cp "$FILELIST_TMP" "$VERIBLE_OUTPUT"
echo "Generated: $VERIBLE_OUTPUT ($FILE_COUNT files)"

echo ""
echo "Done! Restart your LSP server to use the new filelists."
echo ""
echo "Veridian config (veridian.toml):"
echo "[files]"
echo "include_paths = []"
echo ""
echo "Or use the filelist directly - veridian auto-detects veridian.filelist"
