# Load all functions for the logger
source _logr-bash-preexec.sh
source _logr-utils.sh
source _logr-platform.sh
source _logr-data-store.sh
source _logr-hooks.sh
source _logr-default-configs.sh


# Start the brand new log session if this is not 
CURR_SEC=$(_logrf_currTimeSec)
[[ -z $_LOGR_SESSION_ID ]]         && export _LOGR_SESSION_ID=$(_logrf_uuidGen)
[[ -z "$_LOGR_SESSION_LOG_FILE" ]] && export _LOGR_SESSION_LOG_FILE="$_LOGR_LOG_FILE_DIR/$CURR_SEC-$_LOGR_SESSION_ID-$_LOGR_LOG_FILE_SESSION_SUFFIX.csv"
[[ -z "$_LOGR_ENV_LOG_FILE" ]]     && export _LOGR_ENV_LOG_FILE="$_LOGR_LOG_FILE_DIR/$CURR_SEC-$_LOGR_SESSION_ID-$_LOGR_LOG_FILE_ENV_SUFFIX.log"


# Add the preexec/precmd functions to the pre(exec/cmd)_functions array, if it's not already there
has_logrf_preexec=false
for _func in ${preexec_functions[@]}; do
    if [[ $_func == _logrf_preexec ]]; then
        has_logrf_preexec=true
        break
    fi
done

if [[ $has_logrf_preexec == false ]]; then
    # We want our preexec function to be last due to the measure of command time
    # Having it execute after all preexec functions gets the most accurate timing possible
    preexec_functions+=(_logrf_preexec)
fi

has_logrf_precmd=false
for _func in ${precmd_functions[@]}; do
    if [[ $_func == _logrf_precmd ]]; then
        has_logrf_precmd=true
        break
    fi 
done

if [[ $has_logrf_precmd == false ]]; then
    # We want our precmd function first due to the measure of command time
    # Having it execute before other precmd functions gets most accurate timing possible 
    precmd_functions=(_logrf_precmd_head ${precmd_functions[@]} _logrf_precmd_tail)
fi

unset _func has_logrf_precmd has_logrf_preexec


# Need to create the log files if they don't exist 
[[ ! -d "$_LOGR_LOG_FILE_DIR" ]] && mkdir -p "$_LOGR_LOG_FILE_DIR"
[[ ! -f "$_LOGR_SESSION_LOG_FILE" ]] && _logrf_printHeader > "$_LOGR_SESSION_LOG_FILE"
[[ ! -f "$_LOGR_ENV_LOG_FILE" ]] && _logrf_environmentSnapshot > "$_LOGR_ENV_LOG_FILE"
