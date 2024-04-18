# vim: set expandtab tabstop=4 shiftwidth=4:

source stdlib.sh

preexec_functions+=(_tutr_preexec)
precmd_functions+=(_tutr_precmd)


if [[ -n $ZSH_NAME ]]; then
    emulate -L zsh
    # Make the statusbar appear above the prompt in Zsh on MacOS
    setopt prompt_subst
fi


# Detect or install the rc-file shim
if [[ -z "$_TUTR" ]]; then
    case $SHELL in
        *zsh)  _SHIMFILE="$HOME/.zshrc" ;;
        *bash) _SHIMFILE="$HOME/.bashrc" ;;
        *) _tutr_die printf "'Unable to install tutorial shim into your shell's startup file'" ;;
    esac

    if [[ ! -f "$_SHIMFILE" ]] || ! grep -q "# shell tutorial shim DO NOT MODIFY" "$_SHIMFILE"; then
        _tutr_install_shim "$_SHIMFILE"
    fi

    # Where we were before the beginning
    export _ORIG_PWD="$PWD"

    source record.sh
    export _TUTR=${ZSH_ARGZERO-$0} _TUTR_REV=$(git describe --always --dirty)
    _lockout
    if _tutr_has_function setup && ! setup ""; then
        _tutr_die printf "'$0 setup error: contact $_EMAIL for help'"
    fi

    trap "_record_completion ${_TUTR#./} SIGHUP" SIGHUP

    # Spawn a new shell which will enter the lesson because of the shim in its RC file
    $SHELL

    # Record lesson completion status
    _DISPOSITION=-1
    if [[ -s "$_ORIG_PWD/.c" && $(cat "$_ORIG_PWD/.c") -ge ${#_STEPS[@]} ]]; then
            _record_completion ${_TUTR#./} lesson_complete
            _DISPOSITION=$_COMPLETE
    else
        _record_completion ${_TUTR#./} LESSON_INCOMPLETE
    fi
    command rm -f "$_ORIG_PWD/.c"
    _tutr_has_function cleanup && cleanup $_DISPOSITION

    # We want to run _tutr_begin() only once.  Because of the way we spawn a
    # subshell AND source the lesson script, _tutr_begin() would be invoked again
    # after the end of a lesson.
    #
    # This snippet of code returns 1 or 0 to ensure that _tutr_begin is only run
    # at the beginning of a lesson.
    false
else
    [[ -z $DISABLE_TUTR_LOGR ]] && source "$PWD/.lib/logr/_logr-main.sh"
    true
fi

## WARNING!!! DO NOT ADD ANY COMMANDS BELOW THIS LINE!
##
## The last thing this script should do is run either `true` or `false`.
## Adding another command can cause the prologue to be re-displayed upon exit
