#!/bin/sh

# Only Bash and Zsh are supported
. .lib/shell-compat-test.sh

# Guard against lesson re-entry
if [ -n "$_TUTR" ]; then
    echo "You're already taking lesson $_TUTR, isn't one enough?"
    exit 1
fi

. .lib/completed.sh

# Launch the first unfinished lesson and exit
if [ -z "$MENU" ]; then
    for L in [0-9]-*.sh ; do
        if ! _completed $L; then
            exec $SHELL $L
        fi
    done
fi

# Re-exec into the user's preferred $SHELL (Bash or Zsh) for the interactive menu
# (Needed for systems like Ubuntu where /bin/sh is not powerful enough)
expr "$BASH" : ".*/bash" \| "$ZSH_NAME" : ".*zsh" >/dev/null || exec $SHELL $0 $*

if [[ -n "$ZSH_NAME" ]]; then
    setopt nullglob
fi

PATH=$PWD/.lib:$PATH source progress.sh

if [[ -z "$MENU" ]]; then
	cat <<-:

	You are all done with the tutorial!

	$(_tutr_progress)

	Would you like to do a lesson over again?

	:
elif [[ -f $(echo "$MENU"*) ]]; then
    exec $SHELL $(echo "$MENU"*)
else
	cat <<-:

	$(_tutr_progress)

	Which lesson would you like to run?

	:
fi

select Q in [0-9]-*.sh "No thanks"; do
    if [[ $Q = "No thanks" ]]; then
        break
    elif [[ -z $Q ]]; then
        continue
    else
        exec $SHELL $Q
        break
    fi
done
