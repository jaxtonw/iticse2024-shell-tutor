# vim: set expandtab tabstop=4 shiftwidth=4:

# Exit when launched from an unsupported shell
#   Use external `expr` program because I can't be sure this script is
#   evaluated in a shell with a sane `case` statement.
#
#   Furthermore, I can't use the compact regex '.*/\(ba\|z\)sh' because
#   BSD's `expr` does not support branching sub-patterns
if ! expr "$SHELL" : ".*/bash" \| "$SHELL" : ".*/zsh" >/dev/null; then
    1>&2 echo "Your current shell, $SHELL, is incompatible with the tutor"
    1>&2 echo "This tutorial must be run from Bash or Zsh"
    1>&2 echo
    exit 1
fi


# Check that the currently running shell (/bin/sh) supports built-in `[[` conditional expressions
# If it doesn't, re-exec the lesson in $SHELL, which by this point should be either Bash or Zsh
if ! eval "[[ 1 == 1 ]]" >/dev/null 2>&1; then
    exec $SHELL $0
fi
