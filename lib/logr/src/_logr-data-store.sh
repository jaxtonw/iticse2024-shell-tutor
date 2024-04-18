_logrf_constructColumnEntry() {
    # Takes a string, outputs the correctly formatted string as a valid single column entry in the CSV file
    # Takes any " characters and doubles them up, then adds a " to the beginning of first line and a " to the end of the last line
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
    fi

    echo "$@" | sed -e 's/"/""/g' -e '1s/^/"/g' -e '$s/$/"/g'

    if [[ -n $BASH ]]; then
        set +o noglob
    fi
}

_logrf_printHeader() {
    # Create the log file header

    # TODO: add expandCommand as a logged value
    __LOGR_DEFAULT_HEADER="sessionID,shellLvl,timestamp,cwd,command,exitCode,cmdDuration"
    # sessionID == $_LOGR_SESSION_ID
    # shellLvl == $SHLVL
    # timestamp == $_LOGR_currTime
    # cwd == $PWD
    # command == ${__LOGR_CMD[@]}
    # exitCode == $__LOGR_RES
    # cmdDuration == $__LOGR_CMD_DURATION

    # TODO: Make this dynamic instead of being hardcoded
    # TODO: Look at data from _LOGR_ADDITIONAL_ENTRIES list to add additional data to row
    # TODO: Set it up so _LOGR_ADDITIONAL_ENTRIES will be formatted like "HEADER1:VAR1,HEADER2:VAR2,..." instead of hardcoded with shell tutor values

    __LOGR_EXTRA_HEADERS="shellTutor_step,shellTutor_stepName,shellTutor_testExitCode,shellTutor_statelog_code,shellTutor_statelog_text"
    # shellTutor_step == $_I

    __LOGR_HEADER=$__LOGR_DEFAULT_HEADER
    if [[ -n $__LOGR_EXTRA_HEADERS ]]; then
        __LOGR_HEADER+=",$__LOGR_EXTRA_HEADERS"
    fi
    echo $__LOGR_HEADER
}

_logrf_printRow() {
    local __LOGR_ROW=""
    # sessionID
    __LOGR_ROW+=$_LOGR_SESSION_ID,
    # shellLvl
    __LOGR_ROW+=$SHLVL,
    # timestamp
    __LOGR_ROW+=$__LOGR_CMD_STARTIME,
    # cwd 
    __LOGR_ROW+="$(_logrf_constructColumnEntry "$__LOGR_OG_PWD"),"
    # command
    __LOGR_ROW+="$(_logrf_constructColumnEntry "${__LOGR_CMD[@]}"),"
    # exitCode
    __LOGR_ROW+="$__LOGR_RES,"
    # cmdDuration == $__LOGR_CMD_DURATION
    __LOGR_ROW+="$__LOGR_CMD_DURATION,"
    # shellTutor_step
    __LOGR_ROW+="$__LOGR_TUTR_STEP,"
    # shellTutor_stepName
    __LOGR_ROW+="$__LOGR_TUTR_STEPNAME,"
    # shellTutor_testExitCode
    __LOGR_ROW+="$__LOGR_TUTR_TEST_RES,"
    # shellTutor_statelog_code
    __LOGR_ROW+="$__LOGR_TUTR_STATE_CODE,"
    # shellTutor_statelog_text
    __LOGR_ROW+=$(_logrf_constructColumnEntry "$__LOGR_TUTR_STATE_TEXT")

    printf %s "$__LOGR_ROW"$'\n'
}

# _logrf_initializeLogFile() {
#   TODO: Bring this back in the future, if the initialization of the log file should be moved away from general logger initialization 
#     # Initializes the log file
#         # Creates new file
#         # Creates session file?
#         # Parses _LOGR_ADDITIONAL_ENTRIES
#         # Writes header
#         # Stores reference to current log file
# }

_logrf_environmentSnapshot() {
    # This outputs to STDOUT the environment snapshot; redirect the output of this file to the session log file 

    # Capture the following:
    #   $HOME
    #   CWD of shell startup
    #   Shell level
    #   Current time
    #   PATH environment variable?
    #   LANG
    #   __LOGR_OS 
    #   __LOGR_PLAT 
    #   __LOGR_ARCH 
    #   __LOGR_SH
    #   __LOGR_SH_VERSION
    cat <<HERE
HOME=$HOME
LOGR_SESSION_ID=$_LOGR_SESSION_ID
STARTUP_PWD=$PWD
SHLVL=$SHLVL
CURRENT_TIME=$(_logrf_currTimeSec)
PATH=$PATH
LANG=$LANG
OS=$__LOGR_OS
PLAT=$__LOGR_PLAT
ARCH=$__LOGR_ARCH
SHELL=$__LOGR_SH
SHELL_VERSION=$__LOGR_SH_VERSION
TUTOR_LESSON=$_TUTR
TUTOR_REVISION=$_TUTR_REV
HERE
}
