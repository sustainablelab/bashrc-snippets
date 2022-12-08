function title() {
    CMD="title"
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]
    then
        echo "Usage:    $CMD any title    (spaces are OK)"
        echo "   OR:    $CMD \"any title\"  (same as above)"
        echo "   OR:    $CMD              (no args: set title to last dir in pwd)"
        echo "   OR:    $CMD \$PWD         (set title to pwd; ~ is expanded)"
        echo "   OR:    $CMD !!:0          (arg0 of prev cmd executed)"
        echo "   OR:    $CMD !-2:0         (arg0 of prev prev cmd executed)"
        echo "   OR:    $CMD !1999:0       (arg0 of cmd executed at history 1999)"
        echo "   OR:    $CMD !1999:1       (arg1 of cmd at history 1999)"
        echo "   OR:    $CMD !1999         (entire cmd at history 1999)"
        echo "   OR:    $CMD -h           (--help : do nothing and display this help)"
        return
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


