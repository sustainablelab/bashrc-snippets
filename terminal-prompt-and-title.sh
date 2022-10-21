# --- Terminal Prompt ---
# !\! : !history number
# \u : user
# Example: !1458 mike$ 
#
# Ignore the debian_chroot stuff and the color_prompt stuff.
# That has to do with other code in the .bashrc that is irrelevant to setting
# the terminal prompt here.
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}!\! \[\033[01;32m\]\u\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}!\! \u\$ '
fi
unset color_prompt force_color_prompt

# --- Terminal Title : Default ---
# If this is an xterm, set the title to the pwd.
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\w\a\]$PS1"
    ;;
*)
    ;;
esac

# --- Terminal Title : set with 'title' ---
# This snippet is originally by Gabriel Staples.
# See https://unix.stackexchange.com/a/566383/372166
#
# The code above sets my terminal title to the pwd.
# But sometimes I don't want the pwd.
# Instead I want the tab name (terminal title) to reflect what that tab is
# doing.
#
# Examples:
#
# 1. Title the tab, then launch 'screen' to monitor a serial device:
# $ title Serial Monitor
# $ screen /dev/ttyUSB0
#
# 2. Launch a program, then title the tab with the program name
# $ firefox &
# $ title !:0
# # Ctrl-Shift-T
# $ kicad &
# $ title !:0
# # Ctrl-Shift-T
# $ mbed-studio &
# $ title !:0
#
# 3. Show the absolute pwd
# $ title $PWD
#
# 4. Show only the last directory of the pwd
# $ title
# (same as)
# $ title $(basename $PWD)
function title() {
    CMD="title"
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]
    then
        echo "Usage:    $CMD any title    (spaces are OK)"
        echo "   OR:    $CMD \"any title\"  (same as above)"
        echo "   OR:    $CMD              (no args: set title to last dir in pwd)"
        echo "   OR:    $CMD \$PWD         (set title to pwd; ~ is expanded)"
        echo "   OR:    $CMD !:0          (name of last command executed)"
        echo "   OR:    $CMD -h           (--help : display this help)"
    fi
    if [ -z "$1" ]
    then
        # TITLE=\\w
        TITLE=$(basename $PWD)
    else
        TITLE="$@"
    fi
    ESCAPED_TITLE="\[\e]2;${TITLE}\a\]" # set TITLE to args "e.g.: title alice bob"
    PS1_STRIPPED="$(echo "$PS1" | sed 's|\\\[\\e\]2;.*\\a\\\]||g')"
    PS1="${PS1_STRIPPED}${ESCAPED_TITLE}"
}

