#!/bin/sh

LAST=6
CERT=certificate.txt

. .lib/shell-compat-test.sh
PATH=$PWD/.lib:$PATH
source completed.sh
source progress.sh
source stdlib.sh


collect_logfiles() {
	local LOG_FILE_DIR="$PWD/.logr/logfiles"
	local COMPRESSED_FILE_NAME=shell-logs

	if [[ -d "$LOG_FILE_DIR" ]]; then
		if command -v tar &>/dev/null; then
			tar -zcf $COMPRESSED_FILE_NAME.tgz -C "$LOG_FILE_DIR" .

			if [[ $? == 0 ]]; then
				cat <<-:

				I also created the file '$COMPRESSED_FILE_NAME.tgz'
				It contains information that helps us improve the shell tutor.
				:
			else
				cat <<-:

				I was unable to put the log files into a tarball.
				Contact $_EMAIL for help.
				:
				return 1
			fi

		elif command -v zip &>/dev/null; then
			zip --quiet --junk-paths --recurse-paths $COMPRESSED_FILE_NAME.zip "$LOG_FILE_DIR"

			if [[ $? == 0 ]]; then
				cat <<-:

				I also created the file '$COMPRESSED_FILE_NAME.zip'
				It contains information that helps us improve the shell tutor.
				:
			else
				cat <<-:

				I was unable to zip up the command logs for you.
				Contact $_EMAIL for help.
				:
				return 1
			fi

		else
			cat <<-:

			I am unable to collect your command logs.
			Contact $_EMAIL for help.
			:
			return 1
		fi
	fi
}

validate_completion() {
	LESSONS=( [0-$LAST]*-*.sh )
	MISSING=()
	for L in ${LESSONS[@]}; do
		if ! _completed $L; then
			MISSING+=($L)
		fi
	done

	case ${#MISSING[@]} in
		0)
			# "Here, The Cheat, have a trophy!"
			return 0
			;;

		1)
			cat <<-:

			Wait a minute there!  Aren't you forgetting something?
			You still need to do lesson ${MISSING[0]}.

			$(_tutr_progress)

			Come back when you have done that.
			:
			exit 1
			;;

		${#LESSONS[@]})
			cat <<-:

			Um... it's customary to start at the beginning.

			$(_tutr_progress)

			That would be ${LESSONS[0]}.
			:
			exit ${#LESSONS[@]}
			;;

		*)
			cat <<-:
			Hold up! If my calculations are correct, you still need
			to finish ${#MISSING[@]} lessons before you can have your certificate.

			$(_tutr_progress)

			Don't come back until you have completed
			:

			for ((I=0; I < ${#MISSING[@]} - 1; I++)); do
				printf "${MISSING[I]}, "
			done
			printf "\b\b and ${MISSING[${#MISSING[@]} - 1]}\n"
			exit ${#MISSING[@]}
			;;
	esac
}


congrats() {
	local USER="$(whoami)"
	cat <<-':'
	   _______________________________________________________________________
	 / \                                                                      \
	|   |  _____                        __       __     __  _               __|
	 \_ | / ___/__  ___  ___ ________ _/ /___ __/ /__ _/ /_(_)__  ___  ___ / /|
	    |/ /__/ _ \/ _ \/ _ `/ __/ _ `/ __/ // / / _ `/ __/ / _ \/ _ \(_-</_/ |
	    |\___/\___/_//_/\_, /_/  \_,_/\__/\_,_/_/\_,_/\__/_/\___/_//_/___(_)  |
	    |              /___/                                                  |
	    |   _.-'`'-._                                           ________      |
	    |.-'    _    '-.  You completed the shell tutorial!  (`\        `\    |
	    | `-.__  `\_.-'                                       `-\ DIPLOMA \   |
	    |   |  `-``\|        I am so proud of you right          \   (@)   \  |
	    |   `-.....-#        now that ASCII art cannot           _\   |\    \ |
	    | jgs       #           capture my emotions.            ( _)_________)|
	    |           #                                            `----------` |
	    |                                                                     |
	    |                                                                     |
	:

	cat <<-:
	    |      Awarded to: $(printf '%-50.50s' $USER@$HOSTNAME) |
	    |      Date: $(printf '%-56.56s' "$(command date '+%B %d, %Y')") |
	:

	cat <<-':'
	    |                  __               _____     _                       |
	    |                 /  `       /       /  '    //                       |
	    |                /--  __  o /_    ,-/-,__.  // __ __                  |
	    |      Signed:  (___,/ (_<_/ <_  (_/  (_/|_</_(_)/ (_                 |
	    |              ---------------------------------------------------    |
	    |                                                                     |
	    |   __________________________________________________________________|__
	    |  /                                                                    /
	    \_/dc__________________________________________________________________/
	:

	cat <<-:

	This thing on the screen is just for fun.

	The real certificate is a file named '$CERT'.
	:
}


make_certificate() {
	cat <<-: > $CERT
	TUTR_REVISION=$_TUTR_REV
	TIME=$(command date +%s)
	UNAME=$(uname -s)
	SHELL=$SHELL
	${ZSH_VERSION:+ZSH_VERSION=$ZSH_VERSION}${BASH_VERSION:+BASH_VERSION=$BASH_VERSION}
	$(git --version)

	:

	cat .[0-9]*-*.sh >> $CERT
	git hash-object $CERT >> $CERT
}


validate_completion
make_certificate
congrats
[[ -z $DISABLE_TUTR_LOGR ]] && collect_logfiles
echo


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
