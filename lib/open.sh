# an OS-agnostic way to open URLs and files through the desktop environment
_tutr_open() {
    if (( $# == 0 )); then
        _tutr_err  echo Usage: _tutr_open URL_OR_FILENAME
        return 1
    fi

    [[ -z $_OPEN ]] && _tutr_open_init
    [[ $_OPEN == : ]] && return

    # All of these redirections are necessary to keep the tutorial
    # from hanging until the spawned program exits.
    # eval is ugly, but needed for WSL's ugly spawning mechanism (ofc)
    eval "$_OPEN $1 0</dev/null 1>/dev/null 2>/dev/null &"
}


# Separate function so one can obtain the value $_OPEN without opening anything
_tutr_open_init() {
    # initialize _OPEN to the no-op command; if thit platform's "open" command
    # cannot be determined, then _tutr_open will become a no-op
    export _OPEN=:
    local os=$(uname -s)
    case $os in
        Darwin)
            _OPEN=open
            ;;
        *MINGW*|*CYGWIN*)
            _OPEN=start
            ;;
        Linux)
            if [[ -n $WSL_DISTRO_NAME ]]; then
                _OPEN="cmd.exe /c \"start $1\""
            else
                _OPEN=xdg-open
            fi
            ;;
        *)
            _tutr_err echo _tutr_open_setup: Unsupported OS $os, contact $_EMAIL for help
            return 1
            ;;
    esac
}
