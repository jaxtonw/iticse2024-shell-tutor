#!/bin/sh

# Only Bash and Zsh are supported
. .lib/shell-compat-test.sh

printf $'\n'
printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m/\\/\\\x1b[0m             Uh-oh, you found a bug!\n'
printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m  \\_\\  _..._\x1b[0m\n'
printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m  (" )(_..._)\x1b[0m    I apologize, this should\n'
printf $'\x1b[1;32mTutor\x1b[0m:    \x1b[0;33m   ^^  // \\\\\x1b[0m      not have happened.\n'
printf $'\x1b[1;32mTutor\x1b[0m:\n'
printf $'\x1b[1;32mTutor\x1b[0m: Tell me all about it in an email to \x1b[1;36mjaxton.winder@gmail.com\x1b[0m.\n'

cat <<-BUG | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
In your message please explain:

  * which lesson you were in
  * what you tried to do
  * what you thought should happen
  * what actually happened
  * any additional details you feel are important

Copy as much of the text as you can that precedes the problem to
give me context.  Include the diagnostic text below the line.

Thanks in advance!
_________________________________________________________________________

TUTR_REVISION=$(git describe --always --dirty)
PWD=$PWD
HOME=$HOME
PATH=$PATH
SHLVL=$SHLVL
LANG=$LANG
BUG

if [[ -n $WSL_DISTRO_NAME || -n $WSL_INTEROP ]]; then
	cat <<-BUG | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
	WSL_DISTRO_NAME=$WSL_DISTRO_NAME
	WSL_INTEROP=$WSL_INTEROP
	BUG
fi

cat <<-BUG | sed -e $'s/.*/\x1b[1;32mTutor\x1b[0m: &/'
UNAME-A=$(uname -a)
SHELL=$SHELL
$($SHELL --version)
$(git --version)
BUG


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
