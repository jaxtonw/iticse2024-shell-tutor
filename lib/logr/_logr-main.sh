# Setup and initializes the logger

#   Kill logger if not bash or zsh
if [[ -n $BASH_VERSION ]]; then
    (return 0 2>/dev/null) && sourced=0 || sourced=1
    _LOGR_LOC="$BASH_SOURCE"
elif [[ -n $ZSH_VERSION ]]; then
    [[ $ZSH_EVAL_CONTEXT =~ :file$ ]] && sourced=0 || sourced=1
    _LOGR_LOC=${(%):-%x}
else
    echo "Don't know this shell... Logger unable to initialize"
    return 1 2> /dev/null || exit 1
fi

# Bail if this is sourced
if [[ $sourced == 1 ]]; then
    # If this was executed...
    printf "The logger *cannot* be treated as an executable program. It must be sourced in a login shell.\nQuitting...\n"
    exit 1
fi
unset sourced


# Used to replicate the realpath command available on *most* systems 
_realpath() {
    if ! command -v realpath &> /dev/null; then
        perl -MFile::Spec -MCwd -lE "print Cwd::abs_path(File::Spec->rel2abs('$1'))"
    else
        realpath "$1"
    fi
}

_LOGR_LOC=$(_realpath "$_LOGR_LOC")
_LOGR_LOC="${_LOGR_LOC%/*}"

_LOGR_SRC_DIR="$_LOGR_LOC/src"

# Add $_LOGR_SRC_DIR to path, if it doesn't exist already
if [[ -d "$_LOGR_SRC_DIR" && ":$PATH:" != *":$_LOGR_SRC_DIR:"* ]]; then
    PATH="$_LOGR_SRC_DIR:$PATH"
fi

source _logr-init.sh
