_completed() {
    [ -n "$DEBUG" ] && echo "DEBUG| _completed() PWD=$PWD ORIG_PWD=$_ORIG_PWD"
    if   [ -n "$1" ]; then
        local L="${_ORIG_PWD-$PWD}/.$1"
    elif [ -n "$_TUTR" ]; then
        local L="${_ORIG_PWD-$PWD}/.${_TUTR#./}"
    else
        echo 1>&2 '_completed(): provide a lesson file with an argument or $_TUTR'
        return 1
    fi

    if [ ! -s "$L" ]; then
        [ -n "$DEBUG" ] && echo "DEBUG| _completed($L) => 2"
        return 2
    elif ! command grep -q lesson_complete "$L"; then
        [ -n "$DEBUG" ] && echo "DEBUG| _completed($L) => 1"
        return 1
    else
        [ -n "$DEBUG" ] && echo "DEBUG| _completed($L) => 0"
        return 0
    fi
}
