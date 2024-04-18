[[ -z $_TUTR ]] || return 1

source completed.sh

# Record the completion token in a hidden file
# $1 = file name
# $2 = completion status
_record_completion() {
    if (( $# < 2 )); then
        echo "_record_completion(): Too few arguments given"
        return 1
    elif [[ $1 = *make-certificate.sh ]]; then
        return 0
    elif [[ -n $_S ]]; then
        printf "%s\t%s\t%s\t%s\t%s\n" $1 $(command date +%s) $SECONDS $2 $_S >> "${_ORIG_PWD+$_ORIG_PWD/}.$1"
    elif [[ -s "${_ORIG_PWD+$_ORIG_PWD/}.s" ]]; then
        printf "%s\t%s\t%s\t%s\t%s\n" $1 $(command date +%s) $SECONDS $2 $(cat "${_ORIG_PWD+$_ORIG_PWD/}.s") >> "${_ORIG_PWD+$_ORIG_PWD/}.$1"
    else
        printf "%s\t%s\t%s\t%s\n" $1 $(command date +%s) $SECONDS $2 >> "${_ORIG_PWD+$_ORIG_PWD/}.$1"
    fi

    [[ -f "${_ORIG_PWD+$_ORIG_PWD/}.s" ]] && command rm -f "${_ORIG_PWD+$_ORIG_PWD/}.s"
    tail -n 1 "${_ORIG_PWD+$_ORIG_PWD/}.$1" | git hash-object --stdin >> "${_ORIG_PWD+$_ORIG_PWD/}.$1"
}


# When a record token exists, the lesson has already been completed.
# Ask the user if they want to proceed
_record_check() {
    if [[ -n $DEBUG ]]; then
        echo 1>&2 "DEBUG| _record_check(): Looking for file ${_TUTR#./} in $PWD"
    fi
    if _completed "${_TUTR#./}"; then
        _tutr_warn echo -n "You have already completed this lesson"
        if ! _tutr_yesno "Would you like to do it again?"; then
            _tutr_info echo -n "SEE YOU SPACE COWBOY..."
            exit 1
        fi
    fi
    return 0
}


# Error message shown when a student tries to run the lessons out of order
_unfinished_business_msg() {
    cat <<-:
	It looks like you have not yet finished [1m$1[0m.
	You must complete that lesson before you can start this one.
	:
    shift

    if (( $# > 0 )); then
        cat <<-:

		Additionally, these prerequisites(s) are also unfinished:
		  [1m$*[0m
		:
    fi

    cat <<-:

	If you have gotten this message in error, please contact
	$_EMAIL for help.
	:
}


# Check if this lesson has already been completed & ask user if they really
# want to repeat it.
#
# Also ensure that lessons are not run out of order
_lockout() {
	[[ $(echo $OVERRIDE | git hash-object --stdin) == \
		$_OVRRD ]] && return 0

	if [[ -z $_TUTR ]]; then
		_tutr_die echo _lockout: environment variable _TUTR is unset
	fi

	_record_check

	if [[ -n $BASH ]]; then
		local RESTORE_FAILGLOB=$(shopt -p failglob)
		shopt -u failglob
	elif [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt ksh_arrays
	fi

    # All lessons from 0 through the previous must be finished before starting this one
	local PREV=${_TUTR##*/}
	PREV=$((${PREV:0:1} - 1))
	local LESSONS=( [0-9]-*.sh )
	local MISSING=()
	for ((i = 0; i <= $PREV; i++)); do
		if ! _completed ${LESSONS[$i]}; then
            [[ -n $DEBUG ]] && echo "  DEBUG| _lockout: ${LESSONS[$i]} is incomplete"
            MISSING+=( ${LESSONS[$i]} )
        fi
	done

	(( ${#MISSING[@]} > 0 )) && _tutr_die _unfinished_business_msg ${MISSING[@]}

	[[ -n $BASH ]] && eval $RESTORE_FAILGLOB
}

