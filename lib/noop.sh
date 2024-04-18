# Declare a command a NO-OP in a *_test function
#
# Returns true if ${_CMD[0]} is in a set of commands
# which I don't want to nag the user with a hint.
#
# Extra arguments to this function augment the set of NO-OP commands.
declare -A _NOOP
_NOOP=(
    ls 1
    dir 1
    pwd 1
    tutor 1
    clear 1
    reset 1
)

_tutr_noop() {
	while (( $# > 0 )); do
		if [[ ${_CMD[0]} = $1 ]]; then
			return 0
		else
			shift
		fi
	done

    [[ -n "${_CMD[0]}" && -n ${_NOOP[${_CMD[0]}]} ]]
}
