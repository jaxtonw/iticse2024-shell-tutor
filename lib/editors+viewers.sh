declare -A _EDITORS
_EDITORS=(
    charm 1
    code 1
    emacs 1
    nano 1
    nvi 1
    nvim 1
    open 1
    pycharm.sh 1
    pycharm 1
    vi 1
    vim 1
)

# Editors are a subset of viewers.
# hack: copy _EDITORS into _VIEWERS
_tmp=$(declare -p _EDITORS)
eval "${_tmp/_EDITORS/_VIEWERS}"
unset _tmp
_VIEWERS+=(
    less 1
    more 1
    most 1
    pg 1
    view 1
    cat 1
)


# In the tests below, the final ':- ' in the subscript forces a lookup of the
# key ' ' when neither $1 nor _CMD[0] are present.  This is because associative
# arrays in Bash cannot take the empty string as a subscript (prints a warning)

# Is the argument in the set of _EDITORS?
# When no args are given, look at the most recently-run command
_tutr_is_editor() {
    [[ -n ${_EDITORS[${1:-${_CMD[0]:- }}]} ]]
}

# Is the argument in the set of _VIEWERS?
# When no args are given, look at the most recently-run command
_tutr_is_viewer() {
    [[ -n ${_VIEWERS[${1:-${_CMD[0]:- }}]} ]]
}
