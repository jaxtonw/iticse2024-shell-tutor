# Will be the primary 'engine' of the shell tutor

_logrf_preexec() {
    if [[ -n $BASH ]]; then
        # Bash performs pathname (glob) expansion on all values assigned to
        # variables.  This replaces * and ? from incoming commands with the filenames
        # they expand to, thus losing information about the command actually input.
        #
        # This also differs from Zsh's behavior.
        #
        # Disable glob expansion just long enough to record the user's actual command.
        #   TODO: Check if this was already disabled; if so, leave it disabled
        set -o noglob
        __LOGR_CMD=( "$1" )
        set +o noglob
    elif [[ -n $ZSH_NAME ]]; then
        __LOGR_CMD=( ${(z)1} )
    fi

    # We want to know the original $CWD *before* the command is run; the executed command might change it!
    __LOGR_OG_PWD=$PWD

    _logrf_shelltutor_preexec

    # set a command start time
    __LOGR_CMD_STARTIME=$(_logrf_currTimeMillis)
}

_logrf_shelltutor_preexec() {
    # FOR THE SHELL TUTOR ONLY
    __LOGR_TUTR_STEP=$_I
    __LOGR_TUTR_STEPNAME=${_STEPS[$_I]}
}

_logrf_precmd() {
    # Precmd:
    #   Executes AFTER the last command, but BEFORE the prompt is drawn and the user can input another command
    #   Will get executed even on an empty 'enter' press
    #   _logrf_precmd will execute both the head and tail functions, for convenience. This should be used if a user doesn't
    #   need to separate the _head and _tail precmd functions

    _logrf_precmd_head
    _logrf_precmd_tail
}

_logrf_precmd_head() {
    __LOGR_RES=$?

    # Ensure that preexec was actually executed
    # If precmd executes and prexec doesn't, that indicates the user just hit enter with no command being run
    # This is important, as it shows activity but no meaningful command
    if [[ -n $__LOGR_CMD_STARTIME ]]; then 
        __LOGR_CMD_ENDTIME=$(_logrf_currTimeMillis)
        if [[ $__LOGR_SH == Zsh ]]; then
            __LOGR_CMD_DURATION=$(( $__LOGR_CMD_ENDTIME - $__LOGR_CMD_STARTIME ))
        elif command -v bc &> /dev/null; then
            __LOGR_CMD_DURATION=$( echo "$__LOGR_CMD_ENDTIME - $__LOGR_CMD_STARTIME" | bc )
        else
            __LOGR_CMD_DURATION=$( awk "BEGIN { print $__LOGR_CMD_ENDTIME - $__LOGR_CMD_STARTIME }" )
        fi
    else
        __LOGR_RES=
        __LOGR_CMD_STARTIME=$(_logrf_currTimeMillis)
        __LOGR_CMD_DURATION=0
        __LOGR_OG_PWD=$PWD
    fi
}

_logrf_shelltutor_precmd_tail() {
    __LOGR_TUTR_TEST_RES=$_TEST_RES
    __LOGR_TUTR_STATE_CODE=$_TUTR_STATE_CODE
    __LOGR_TUTR_STATE_TEXT=$_TUTR_STATE_TEXT
}

_logrf_precmd_tail() {
    _logrf_shelltutor_precmd_tail

    # This is where we actually call the function to do the logging
    _logrf_printRow >> "$_LOGR_SESSION_LOG_FILE"

    unset __LOGR_CMD_STARTIME __LOGR_CMD_ENDTIME __LOGR_RES __LOGR_CMD __LOGR_OG_PWD
}

# _logrf_initialize() {
#     source src/platform.sh
# }
