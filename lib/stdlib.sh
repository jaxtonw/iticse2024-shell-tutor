# vim: set expandtab tabstop=4 shiftwidth=4:

# Contact for bug reports
typeset -r _EMAIL=$'\x1b[1;36mjaxton.winder@gmail.com\x1b[0m'

# Exit code indicating the lesson was completed successfully
typeset -r _COMPLETE=7

# *_test() status code for commands that are neither correct nor incorrect
typeset -r NOOP=7

# Count number of moves taken so far to solve the current step
typeset -i _TOTAL_ATTEMPTS=0
typeset -i _NOOP_ATTEMPTS=0
typeset -i _ATTEMPTS=0


# This function is run *BEFORE* a command.
_tutr_preexec() {
    if [[ -n $BASH ]]; then
        # Bash performs pathname (glob) expansion on all values assigned to
        # variables.  This replaces * and ? from incoming commands with the filenames
        # they expand to, thus losing information about the command actually input.
        #
        # This also differs from Zsh's behavior.
        #
        # Disable glob expansion just long enough to record the user's actual command.
        set -o noglob
        _CMD=( $1 )
        set +o noglob
    elif [[ -n $ZSH_NAME ]]; then
        _CMD=( ${(z)1} )
    fi
}


# This function is run *AFTER* a command and *BEFORE* the prompt is drawn.
#
# Perhaps should have been called preprompt()
_tutr_precmd() {
    local _RES=$?
    [[ -n $DEBUG ]] && printf "\nDEBUG| precmd($1): _RES=$_RES\n"

    # This is needed for ${_CMD[0]} to work in the step's *_test
    if [[ -n $ZSH_NAME ]]; then
        emulate -L zsh
        setopt ksh_arrays
    fi

    # Ensure that no state logging values persist between commands
    _TUTR_STATE_CODE=
    _TUTR_STATE_TEXT=

    # This if statement prevents running all of this code when the user simply
    # hits ENTER at the prompt
    if [[ -n $_CMD ]]; then

        # We run the statelog (if it exists) BEFORE the test, as the test will frequently
        #   do a tutor performed action (such as replacing a file). We want the statelog
        #   to capture things *before* the tutor performed action
        if _tutr_has_function $_STATELOG; then
            $_STATELOG
        fi

        # Check whether the test now passes
        $_TEST
        _TEST_RES=$?
        if [[ $_TEST_RES == 0 ]]; then
            [[ -n $DEBUG ]] && printf "\nDEBUG| precmd(): \x1b[1;32m$_TEST passed\x1b[0m\n"

            # Run this step's _post and _epilogue functions, if extant
            _tutr_has_function $_POST && $_POST
            _tutr_has_function $_EPILOGUE && _tutr_info $_EPILOGUE

            # Reset the move counters
            (( _TOTAL_ATTEMPTS = _NOOP_ATTEMPTS = _ATTEMPTS = 0 ))

            # Clear the command line before running the next test
            # Some steps are completed based upon the state of the system,
            # others look only at the command which was run.
            #
            # Clearing this array prevents the latter steps from passing based
            # upon the previous command text.
            _CMD=()

            # Move onto the next step and run its tests
            _tutr_next_step
        else
            (( _TOTAL_ATTEMPTS++ ))
            (( _TEST_RES == NOOP && _NOOP_ATTEMPTS++ ))
            (( _ATTEMPTS = _TOTAL_ATTEMPTS - _NOOP_ATTEMPTS ))
            _tutr_info $_HINT $_TEST_RES
            [[ -n $DEBUG ]] && printf "\nDEBUG| precmd(): \x1b[1;31m$_TEST failed with status $_TEST_RES\x1b[0m\n"
        fi
    fi

    [[ -n $DEBUG ]] && echo "DEBUG| precmd(): _CMD='$1'"
    _CMD=$1  # is this line even needed anymore?
}


# Display the contents of _CMD, numbered
_tutr_debug_CMD() {
    local I=0
    for W in ${_CMD[@]}; do
        echo "$I. $W"
        (( I++ ))
    done
}


# Set the tutor's informative output apart from a command's with a bold green
# "Tutor:" in the gutter
_tutr_info() {
    echo
    eval "$@" | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
    echo
}


# Set the tutor's warning output apart from a command's with a bold yellow
# "Tutor:" in the gutter
_tutr_warn() {
    echo
    eval "$@" | sed -e $'s/.*/\x1b[1;33mTutor\x1b[0m: &/'
    echo
}

# Set the tutor's error output apart from a command's with a bold red
# "Tutor:" in the gutter
_tutr_err() {
    echo
    eval "$@" | sed -e $'s/.*/\x1b[1;31mTutor\x1b[0m: &/'
    echo
}


# Display a command's output the same as _tutr_err then exit
_tutr_die() {
    _tutr_err "$@"
    exit 1
}


# Detect when the user copies & pastes "Tutor:" from the gutter
alias Tutor:="
echo
printf \"\x1b[1;31mTutor\x1b[0m: Whoops, you pasted \\\"Tutor:\\\" as part of your command.\n\"
printf \"\x1b[1;31mTutor\x1b[0m: Be careful when copying what I say to you!\n\"
false"


# "Press ENTER to continue" prompt
# This was originally written in terms of _tutr_getc, but sometimes extra
# keystrokes "leaked" out and showed up on the screen.  It was rewritten
# to minimize function calls and branching to avoid race conditions
_tutr_pressenter() {
    [[ -n $_SK_P ]] && return
    [[ -n $DEBUG ]] && echo "DEBUG| _tutr_pressenter"
    echo $'\x1b[7m[Press ENTER]\x1b[0m'
    trap : SIGINT
    if [[ -n $ZSH_NAME ]]; then
        while true; do
            read -r -k -s
            [[ $REPLY == $'\n' ]] && return
        done
    else
        while true; do
            # FYI: The read builtin in Bash versions <=4 does not have the -N flag.
            # Therefore, I must compare $REPLY to the empty string.
            read -r -n 1 -s
            [[ -z $REPLY ]] && return
        done
    fi
    trap SIGINT
}


# Read a single key from STDIN in a shell-agnostic way.
# The key is stored in globabl $REPLY.
# FYI: The read builtin in Bash versions <=4 does not have the -N flag,
#      thus newlines come across as the empty string.
_tutr_getc() {
    [[ -n $DEBUG ]] && echo "DEBUG| _tutr_getc"
    if [[ -n $BASH ]]; then
        read -r -n 1 -s
    elif [[ -n $ZSH_NAME ]]; then
        read -r -k -s
    fi
}


# "Press any key to continue" prompt
_tutr_pressanykey() {
    [[ -n $_SK_P ]] && return
    [[ -n $DEBUG ]] && echo "DEBUG| _tutr_pressanykey"
    (( $# == 0 )) && echo $'\x1b[7m[Press any key]\x1b[0m' || printf $'\x1b[7m[%s]\x1b[0m\n' "$*"
    _tutr_getc
}


# Yes/no prompt
# Returns
#   0 When an affirmative response is given: "Y" and "y"are considered affirmative
#   1 When negative: "N", "n" and ENTER are negative
#   Otherwise, the prompt is repeated
_tutr_yesno() {
    while true; do
        printf "\n\x1b[1;33mTutor\x1b[0m: $@ [y/N] "
        _tutr_getc
        [[ -n $DEBUG ]] && echo "_tutr_yesno [$REPLY]"

        case $REPLY in
            [Yy])
                echo  # move cursor down before the next thing is printed
                return 0 ;;
            ""|$'\n'|[Nn])
                echo
                return 1 ;;
        esac
    done
}


typeset -r _OVRRD=da75adf137de37f95d40be7d23408509a0e941e0
_invalidation_prompt() {
    if [[ -n "$_S" ]]; then
        return 0
    elif [[ -z "$_S" && -n "$OVERRIDE" \
        && $(echo $OVERRIDE | git hash-object --stdin) == $_OVRRD ]]; then
        return 0
    else
        _tutr_warn printf '"This will invalidate the lesson"'
        _tutr_yesno "Are you sure?"
        return $?
    fi
}



# Enable user to interact with the tutor
tutor() {
    if [[ -n $ZSH_NAME ]]; then
        emulate -L zsh
        setopt ksh_arrays
    fi
    case $1 in
        hint)
            _tutr_info $_PROLOGUE
            ;;

        check)
            : # Intentional NO-OP - _test will be run automatically anyway
            ;;

        where)
            printf $'\x1b[1;32mTutor\x1b[0m: You are on step \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m\n' $_I $_MAX_STEP
            local i
            for ((i=0; i <= _MAX_STEP; ++i)); do
                if ((i == _I)); then
                    printf $'\x1b[1;32mTutor\x1b[0m: \x1b[1;35m%2s. \x1b[4m%s\x1b[0m\n' $i ${_STEPS[$i]}
                else
                    printf $'\x1b[1;32mTutor\x1b[0m: %2s. %s\n' $i ${_STEPS[$i]}
                fi
            done
            ;;

        next)
            if (( _I <= _MAX_STEP )); then
                _invalidation_prompt || return
                _tutr_fastfwd || _tutr_die echo "Failed to fast-forward to step $_I. ${_STEPS[$_I]}"
                _tutr_next_step $((_I + 1))
            fi
            ;;

        prev)
            if (( _I > 0 )); then
                _invalidation_prompt || return
                _tutr_next_step $((_I - 1))
                _tutr_rewind || _tutr_die echo "Failed to rewind to step $_I. ${_STEPS[$_I]}"
            fi
            ;;

        goto)
            if   [[ -z "$2" ]]; then
                printf $'\x1b[1;31mTutor\x1b[0m: Usage: tutor goto STEP\n'
            elif [[ $2 == $_I ]]; then
                printf $'\x1b[1;31mTutor\x1b[0m: You are already on step \x1b[1;35m%s. %s\x1b[0m\x1b[0m\n' $2 ${_STEPS[$2]}
            elif [[ $2 == $ || $2 == '^' ]] || (( $2 >= 0 && $2 <= _MAX_STEP )); then
                _invalidation_prompt || return
                if [[ $2 == $ ]]; then
                    set -- $1 $(( _MAX_STEP + 1 ))
                elif [[ $2 == '^' ]]; then
                    set -- $1 0
                fi
                printf $'\x1b[1;33mTutor\x1b[0m: Going to step \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m: \x1b[1;4;35m%s\x1b[0m\n' $2 $_MAX_STEP ${_STEPS[$2]}

                if (( $2 < $_I )); then
                    # Rewind
                    # loop backward from ($_I - 1) to $2
                    # (start at $_I-1 b/c we don't need to undo the currently unfinished step)
                    for (( _I=_I-1; $_I > $2; _I-- )); do
                        _tutr_rewind || _tutr_die echo "Failed to rewind to step $_I. ${_STEPS[$_I]}"
                    done
                    # rewind once more to undo the result of the target step
                    _tutr_rewind || _tutr_die echo "Failed to rewind to step $_I. ${_STEPS[$_I]}"
                else
                    # Fast Forward
                    # loop forward from $_I to ($2 - 1)
                    for (( ; $_I < $2; _I++ )); do
                        _tutr_fastfwd || _tutr_die echo "Failed to fast-forward to step $_I. ${_STEPS[$_I]}"
                    done
                fi

                # $_I is now at the right position; enter the step
                printf $'\n\x1b[1;33mTutor\x1b[0m: You are on step \x1b[1;35m%s. \x1b \x1b[1;4;35m%s\x1b[0m\n' $_I ${_STEPS[$_I]}
                _tutr_next_step $(( $_I ))
            else
                printf $'\x1b[1;31mTutor\x1b[0m: Cannot goto step \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m\n' $2 $_MAX_STEP
            fi
            ;;

        which|what|name)
            printf $'\x1b[1;33mTutor\x1b[0m: The name of this step is "\x1b[1;4;35m%s\x1b[0m"\n' ${_STEPS[$((_I))]}
            ;;

        fix)
            if _tutr_has_function $_PRE; then
                printf $'\x1b[1;33mTutor\x1b[0m: Trying a fix; if this does not work, run "tutor bug"\n'
                $_PRE
            else
                printf $'\x1b[1;33mTutor\x1b[0m: I cannot fix this step; run "tutor bug" and report the problem\n'
            fi
            ;;

        exit|quit)
            printf $'\x1b[1;32mTutor\x1b[0m: Leaving tutorial...\x1b[0m\n'
            exit 1
            ;;

        bug|stuck)
			printf $'\n'
			printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m/\\/\\\x1b[0m             Uh-oh, you found a bug!\n'
			printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m  \\_\\  _..._\x1b[0m\n'
			printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m  (" )(_..._)\x1b[0m    I apologize, this should\n'
			printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m   ^^  // \\\\\x1b[0m      not have happened.\n'
			printf $'\x1b[1;32mTutor\x1b[0m:\n'
			printf $'\x1b[1;32mTutor\x1b[0m: Tell me all about it in an email to %s.\n' $_EMAIL

			cat <<-BUG | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
			In your message please explain:

			  * what you tried to do
			  * what you thought should happen
			  * what actually happened
			  * any additional details you feel are important

			Copy as much of the text as you can that precedes the problem to
			give me context.  Include the diagnostic text below the line.

			Thanks in advance!
			_________________________________________________________________________
			BUG

			_tutr_pressenter

			cat <<-MSG

			TUTR_REVISION=$_TUTR_REV
			LESSON=$_TUTR
			STEP=$_I ${_STEPS[$_I]}
			STEPS=${_STEPS[@]}
			PWD=$PWD
			ORIG_PWD=$_ORIG_PWD
			HOME=$HOME
			PATH=$PATH
			SHLVL=$SHLVL
			LANG=$LANG
			MSG

			if [[ -n $WSL_DISTRO_NAME || -n $WSL_INTEROP ]]; then
				cat <<-MSG
				WSL_DISTRO_NAME=$WSL_DISTRO_NAME
				WSL_INTEROP=$WSL_INTEROP
				MSG
			fi

			cat <<-MSG
			UNAME-A=$(uname -a)
			SHELL=$SHELL
			${ZSH_VERSION:+ZSH_VERSION=$ZSH_VERSION}${BASH_VERSION:+BASH_VERSION=$BASH_VERSION}
			$(git --version)

			MSG
            ;;

        *)
            # A heredoc declared with '<<-' requires TABS (\t) in the source
            # It's a really nice feature, but I'm not sure that I want to mix
            # tabs with spaces...
			cat <<-HELP | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
				help       This message
				bug        Use this if you find a problem in the tutorial
				hint       Give a hint about this step
				check      Re-run this step's test() function
				where      Display progress
				name       Display the name of this step
				fix        Attempt to fix the tutorial
				quit       Quit this tutoring session
				HELP
            ;;
    esac
}


# Return TRUE when the function named by $1 exists
_tutr_has_function() {
    if [[ -z $1 ]]; then
        echo Usage: $0 FUNCTION
        return 1
    fi

    if [[ -n $BASH ]]; then
        declare -f $1 >/dev/null
        return $?

    elif [[ -n $ZSH_NAME ]]; then
        functions $1 >/dev/null
        return $?
    fi
}


# Default hint function
_tutr_hint() {
    echo "It's okay to make mistakes.  Try again!"
}


_tutr_rewind() {
    (( _I < 0 )) && return
    (( _S++ ))
    local _RW=${_STEPS[$_I]}_rw
    local _PRE=${_STEPS[$_I]}_pre
    local _POST=${_STEPS[$_I]}_post
    local _SK_P=1
    local _res=0

    _tutr_has_function $_POST && $_POST
    if _tutr_has_function $_RW; then
        printf $'\x1b[1;33mTutor\x1b[0m: REWIND   \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m: \x1b[1;4;35m%s\x1b[0m\n' $_I $_MAX_STEP ${_STEPS[$_I]}
        $_RW
        _res=$?
    else
        printf $'\x1b[1;33mTutor\x1b[0m: SKIP     \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m: \x1b[1;4;35m%s\x1b[0m\n' $_I $_MAX_STEP ${_STEPS[$_I]}
    fi
    _tutr_has_function $_PRE && $_PRE
    return $_res
}


_tutr_fastfwd() {
    _tutr_is_all_done && return
    (( _S++ ))
    local _FF=${_STEPS[$_I]}_ff
    local _PRE=${_STEPS[$_I]}_pre
    local _POST=${_STEPS[$_I]}_post
    local _SK_P=1
    local _res=0

    _tutr_has_function $_PRE && $_PRE
    if _tutr_has_function $_FF; then
        printf $'\x1b[1;33mTutor\x1b[0m: FAST-FWD \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m: \x1b[1;4;35m%s\x1b[0m\n' $_I $_MAX_STEP ${_STEPS[$_I]}
        $_FF
        _res=$?
    else
        printf $'\x1b[1;33mTutor\x1b[0m: SKIP     \x1b[1;35m%s\x1b[0m of \x1b[1;35m%s\x1b[0m: \x1b[1;4;35m%s\x1b[0m\n' $_I $_MAX_STEP ${_STEPS[$_I]}
    fi
    _tutr_has_function $_POST && $_POST
    return $_res
}


# Advance lesson to the next applicable step
_tutr_next_step() {
    if [[ -n $ZSH_NAME ]]; then
        emulate -L zsh
        setopt ksh_arrays
    fi

	[[ -n $DEBUG ]] && echo "DEBUG| _tutr_next_step($1)"

    if [[ -n $1 ]]; then
        # This is how `tutor skip` works
        _I=$1
    else
        # In the normal case we increment _I now so as to not re-run the test
        # of a step that's just been passed off
        (( _I++ ))
    fi

    until _tutr_is_all_done; do
        _PROLOGUE=${_STEPS[$_I]}_prologue
        _PRE=${_STEPS[$_I]}_pre
        _HINT=${_STEPS[$_I]}_hint
        _TEST=${_STEPS[$_I]}_test
        _STATELOG=${_STEPS[$_I]}_statelog
        _EPILOGUE=${_STEPS[$_I]}_epilogue
        _POST=${_STEPS[$_I]}_post
        if ! _tutr_has_function $_HINT; then
            _tutr_has_function $_PROLOGUE \
                && _HINT=$_PROLOGUE \
                || _HINT=_tutr_hint
        fi

        # If there wasn't a step specific statelog, check if there's a global lesson statelog
        if [[ -z $DISABLE_TUTR_LOGR ]] && ! _tutr_has_function $_STATELOG; then
            _tutr_has_function _tutr_lesson_statelog_global \
                && _STATELOG=_tutr_lesson_statelog_global
        fi

        if [[ -n $DEBUG ]]; then
            echo "DEBUG| _I=$_I"
            _tutr_has_function $_PROLOGUE \
                && printf "DEBUG| \x1b[1;32m$_PROLOGUE\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_PROLOGUE is unset\x1b[0m\n"
            _tutr_has_function $_PRE \
                && printf "DEBUG| \x1b[1;32m$_PRE\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_PRE is unset\x1b[0m\n"
            _tutr_has_function $_HINT \
                && printf "DEBUG| \x1b[1;32m$_HINT\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_HINT is unset\x1b[0m\n"
            _tutr_has_function $_TEST \
                && printf "DEBUG| \x1b[1;32m$_TEST\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_TEST is unset\x1b[0m\n"
            _tutr_has_function $_STATELOG \
                && printf "DEBUG| \x1b[1;32m$_STATELOG\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_STATELOG is unset\x1b[0m\n"
            _tutr_has_function $_EPILOGUE \
                && printf "DEBUG| \x1b[1;32m$_EPILOGUE\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_EPILOGUE is unset\x1b[0m\n"
            _tutr_has_function $_POST \
                && printf "DEBUG| \x1b[1;32m$_POST\x1b[0m\n" \
                || printf "DEBUG| \x1b[1;31m$_POST is unset\x1b[0m\n"
        fi

        if _tutr_has_function $_TEST; then

            # Run this step's `pre_` (if extant) before testing
            _tutr_has_function $_PRE && $_PRE

            if ! $_TEST; then
                [[ -n $DEBUG ]] && printf "\nDEBUG| \x1b[1;31m$_TEST failed\x1b[0m\n"
                # Run this step's `prologue_` function, if extant
                _tutr_has_function $_PROLOGUE && _tutr_info $_PROLOGUE
                break

            else
                [[ -n $DEBUG ]] && printf "\nDEBUG| \x1b[1;32m$_TEST passed\x1b[0m\n"
                # go on to the next step
                (( _I++ ))
                continue
            fi

        else
            _tutr_die printf "'ERROR in $0: Required test '$_TEST' does not exist'"
        fi
    done

    _tutr_is_all_done && _tutr_all_done
}


# Detect when the user is all done with this tutorial
_tutr_is_all_done() {
    (( _I >= ${#_STEPS[@]} ))
}


# Conclude and exit the tutorial environment
_tutr_all_done() {
    # Record the user's final command
    [[ -z $DISABLE_TUTR_LOGR ]] && _logrf_precmd_tail
    [[ -n $_S ]] && echo $_S >"$_ORIG_PWD/.s"
    if _tutr_has_function epilogue; then
        _tutr_info epilogue
    else
        echo
        echo $'\x1b[1;32mTutor\x1b[0m: All done!'
        echo $'\x1b[1;32mTutor\x1b[0m: This concludes your lesson'
    fi

    # Disown all background jobs so the shell can exit
    while disown 2>/dev/null; do :; done

    # Indicate that the lesson was completed successfully
    echo $_I >"$_ORIG_PWD/.c"
    exit
}


# Displays the +/- status bar before the prompt
_tutr_statusbar() {
    if (( $# < 2 )); then
        echo "ERROR: too few arguments"
        echo "USAGE: _tutr_statusbar NUMERATOR DENOMINATOR [MESSAGE]"
        return 1
    fi

    local N=$1
    shift
    local D=$1
    shift

    if (( $# > 0 )); then
        local MSG=$'\x1b[1;7m'$@$'\x1b[0m'" - Step $N of $D ["
    else
        local MSG="Step $N of $D ["
    fi

    local REMAIN=$((D - N))
    local PADDING='----------------------------------------------------------------------'
    local COMPLET='++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    while (( ${#PADDING} < D )); do
        PADDING=$PADDING$PADDING
        COMPLET=$COMPLET$COMPLET
    done

    printf "$MSG\x1b[1;32m${COMPLET:0:$N}\x1b[1;31m${PADDING:$N:$REMAIN}\x1b[0m]"
}


# Begin the tutorial by initializing the _STEPS array to this functions arguments
_tutr_begin() {
    [[ -n $BASH ]] && source bash-preexec.sh

    # If _BASE is defined chdir into that directory
    [[ -n $_BASE ]] && cd "$_BASE"

    _tutr_has_function prologue && _tutr_info prologue

    _STEPS=( $@ )
    _MAX_STEP=$((${#_STEPS[@]} - 1))
    _I=0
    _tutr_next_step $_I

    # add a statusbar to the PS1 prompt
    PS1=$'$(_tutr_statusbar $_I $_MAX_STEP $(basename $_TUTR))\n'$PS1

    _tutr_is_all_done && _tutr_all_done
}


# Display seconds as a timestamp in the format HH:MM:SS
# PARAMETERS:
#    (Optional) Number of seconds as an integer; if this is not given the value of $SECONDS is used instead
# SIDE EFFECTS AND RETURN:
#    Display a timestamp, return nothing
_tutr_pretty_time() {
    local seconds=${1:-$SECONDS}
    local -a result

    # convert raw seconds into an array=(seconds minutes hours)
    while [[ $seconds -ne 0 ]]; do
            result=($(( $seconds % 60 )) ${result[@]})
            seconds=$(( $seconds / 60))
    done

    case ${#result[@]} in
            3) printf '%02d:%02d:%02d\n' ${result[@]} ;;
            2) printf '%02d:%02d\n' ${result[@]} ;;
            1) printf '00:%02d\n' ${result[@]} ;;
    esac
}


# Install the shell tutorial shim (with permission) into user's RC file
_tutr_install_shim() {
    if [[ -z $1 ]]; then
        _tutr_die printf "'Usage: $0 SHELL_RC_FILE_NAME'"
    fi

    SHIM='[[ -n "$_TUTR" ]] && source $_TUTR || true  # shell tutorial shim DO NOT MODIFY'

	cat <<-ASK | sed -e $'s/.*/\x1b[1;33mTutor\x1b[0m: &/'
	Before you can begin this lesson I need to install a bit of code
	into your shell's startup file '$1'.

	In case you're curious, the code looks like this:

	  $SHIM

	This is a one-time-only edit.  I won't ask to make any more changes to your
	startup files.
	ASK

    if _tutr_yesno "May I make this one-time change to this file?"; then
        _tutr_info echo "Installing shell tutorial shim into $1..."
		cat <<-SHIM >> "$1"

		$SHIM

		SHIM

        if (( $? != 0 )); then
            _tutr_die printf "'I am unable to modify $1.  Exiting tutorial.'"
        fi
    else
        _tutr_die printf "'You cannot proceed with the tutorial without making this change.'"
    fi
}
