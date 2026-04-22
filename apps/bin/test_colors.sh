#!/bin/bash
# Comprehensive terminal color test script

echo "=== Terminal Color Support Test ==="
echo ""

# Test 1: Basic 16 colors
echo "1. Basic 16 Colors (ANSI):"
echo "   Foreground colors:"
for i in {0..7}; do
    echo -en "  \e[3${i}m Color $i \e[0m"
done
echo ""
for i in {0..7}; do
    echo -en "  \e[9${i}m Bright $i \e[0m"
done
echo ""
echo ""

echo "   Background colors:"
for i in {0..7}; do
    echo -en "  \e[4${i}m Color $i \e[0m"
done
echo ""
for i in {0..7}; do
    echo -en "  \e[10${i}m Bright $i \e[0m"
done
echo ""
echo ""

# Test 2: 256 color palette
echo "2. 256 Color Palette:"
echo "   System colors (0-15):"
for i in {0..15}; do
    printf "\e[48;5;%dm %3d \e[0m" $i $i
    if [ $(((i + 1) % 8)) -eq 0 ]; then
        echo ""
    fi
done
echo ""

echo "   216 color cube (16-231):"
for i in {16..231}; do
    printf "\e[48;5;%dm %3d \e[0m" $i $i
    if [ $(((i - 15) % 6)) -eq 0 ]; then
        echo -n " "
    fi
    if [ $(((i - 15) % 36)) -eq 0 ]; then
        echo ""
    fi
done
echo ""

echo "   Grayscale ramp (232-255):"
for i in {232..255}; do
    printf "\e[48;5;%dm %3d \e[0m" $i $i
    if [ $(((i - 231) % 12)) -eq 0 ]; then
        echo ""
    fi
done
echo ""
echo ""

# Test 3: True Color (24-bit RGB)
echo "3. True Color (24-bit RGB) Test:"
echo "   RGB Gradient:"
for r in {0..255..32}; do
    for g in {0..255..32}; do
        for b in {0..255..32}; do
            printf "\e[48;2;%d;%d;%dm  \e[0m" $r $g $b
        done
        echo -n " "
    done
    echo ""
done
echo ""

# Test 4: Color gradient bars
echo "4. Smooth Gradients (True Color):"
echo "   Red gradient:"
for i in {0..255..4}; do
    printf "\e[48;2;%d;0;0m \e[0m" $i
done
echo ""

echo "   Green gradient:"
for i in {0..255..4}; do
    printf "\e[48;2;0;%d;0m \e[0m" $i
done
echo ""

echo "   Blue gradient:"
for i in {0..255..4}; do
    printf "\e[48;2;0;0;%dm \e[0m" $i
done
echo ""
echo ""

# Test 5: Text styles
echo "5. Text Styles:"
echo -e "   \e[1mBold\e[0m"
echo -e "   \e[2mDim\e[0m"
echo -e "   \e[3mItalic\e[0m"
echo -e "   \e[4mUnderline\e[0m"
echo -e "   \e[5mBlink\e[0m"
echo -e "   \e[7mReverse\e[0m"
echo -e "   \e[8mHidden\e[0m (hidden text)"
echo -e "   \e[9mStrikethrough\e[0m"
echo ""

# Test 6: Combined styles and colors
echo "6. Combined Styles:"
echo -e "   \e[1;31mBold Red\e[0m"
echo -e "   \e[4;32mUnderlined Green\e[0m"
echo -e "   \e[3;34mItalic Blue\e[0m"
echo -e "   \e[1;4;35mBold Underlined Magenta\e[0m"
echo -e "   \e[7;33mReverse Yellow\e[0m"
echo ""

# Test 7: Terminal capabilities
echo "7. Terminal Capabilities:"
echo "   TERM: $TERM"
echo "   COLORTERM: $COLORTERM"
tput colors 2>/dev/null && echo "   Colors supported (tput): $(tput colors)" || echo "   tput: not available"
echo ""

# Test 8: Color cube visualization
echo "8. Color Cube (6x6x6):"
for level in {0..5}; do
    echo "   Level $level:"
    for g in {0..5}; do
        echo -n "   "
        for r in {0..5}; do
            color=$((16 + 36 * r + 6 * g + level))
            printf "\e[48;5;%dm  \e[0m" $color
        done
        echo ""
    done
done
echo ""

echo "=== Test Complete ==="
echo ""
echo "If you can see:"
echo "  ✓ 16 different basic colors"
echo "  ✓ A full 256-color palette"
echo "  ✓ Smooth RGB gradients in red, green, and blue"
echo "  ✓ Bold, italic, and underlined text"
echo ""
echo "Then your terminal has full color support!"
