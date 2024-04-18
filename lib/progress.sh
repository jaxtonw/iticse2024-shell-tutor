# vim: set noexpandtab tabstop=4 shiftwidth=4:

source completed.sh


# Center a string and store in $REPLY
# The field width may be specified, defaulting to strlen+2
_center() {
	if (( $# < 2 )); then
		local width=$(( ${#1} + 2 ))
	else
		local width=$2
	fi
	local pad=$(( width - ${#1} ))
	local left=$(( pad / 2 ))
	local right=$(( pad - left ))
	printf -v REPLY "%*s%s%*s" $left "" "$1" $right ""
}


# Trims up to one char from the end of a string.
# Which side of the string is trimmed depends on whether
# it's on the left or right side of the tutorial map.
# Strings in the middle of the map are unmodified
#
# This is needed to ensure the map of the first Shell Tutor
# sequence fits into 80 columns.
#
# The result is stored in $REPLY
#  $1 = string
#  $2 = position in array
#  $3 = max index of array
_trim_ends() {
	if (( $2 == 0 )); then
		REPLY=${1:1}
	elif (( $2 == $3 - 1 )); then
		REPLY=${1:0:-1}
	else
		REPLY=$1
	fi
}


# Display a progress map for this tutorial
#   Completed lessons are colored BLUE (44m)
#   The current lesson is YELLOW (43m)
#   Incomplete lessons are colored RED (41m)
_tutr_progress() {
	if [[ -n $BASH ]]; then
		local RESTORE_FAILGLOB=$(shopt -p failglob)
		shopt -u failglob
	elif [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt ksh_arrays
	fi

	local digits0=("  __  "  " _ " " ___ " " ____"  " _ _  " " ___ "  "  __ "  " ____ "  " ___ "  " ___ ")
	local digits1=(" /  \\ " "/ |" "|_  )" "|__ /"  "| | | " "| __|"  " / / "  "|__  |"  "( _ )"  "/ _ \\");
	local digits2=("| () |"  "| |" " / / " " |_ \\" "|_  _|" "|__ \\" "/ _ \\" "  / / "  "/ _ \\" "\\_, /")
	local digits3=(" \\__/ " "|_|" "/___|" "|___/"  "  |_| " "|___/"  "\\___/" " /_/  "  "\\___/" " /_/ ")
	local hilite
	local output0=()
	local output1=()
	local output2=()
	local output3=()
	local output4=()
	local CURRENT=${_TUTR##*/}
	local LESSONS=( "${_ORIG_PWD:-$PWD}"/[0-9]-*.sh )
	for ((i=0; i < ${#LESSONS[@]}; i++)); do
		[[ -n $DEBUG ]] && printf "DEBUG| i=$i LESSON=${LESSONS[$i]}\n"

		if _completed $(basename "${LESSONS[$i]}"); then
			[[ -n $DEBUG ]] && printf "DEBUG| hilite=blue\n"
			hilite=$'\x1b[1;37;44m'
		elif [[ $(basename "${LESSONS[$i]}") == $CURRENT ]]; then
			[[ -n $DEBUG ]] && printf "DEBUG| hilite=yellow\n"
			hilite=$'\x1b[0;30;43m'
		else
			[[ -n $DEBUG ]] && printf "DEBUG| hilite=red\n"
			hilite=$'\x1b[1;37;41m'
		fi

		local name=${LESSONS[$i]}
		name=${name#*/?-}
		name=${name%.sh}
		if (( ${#name} > ${#digits0[$i]} )); then
			local width=$((${#name} + 2))
		else
			local width=$((${#digits0[$i]} + 2))
		fi

		_center "${digits0[$i]}" $width
		_trim_ends "$REPLY" $i ${#LESSONS[@]}
		output0+=("${hilite}${REPLY}")

		_center "${digits1[$i]}" $width
		_trim_ends "$REPLY" $i ${#LESSONS[@]}
		output1+=("${hilite}${REPLY}")

		_center "${digits2[$i]}" $width
		_trim_ends "$REPLY" $i ${#LESSONS[@]}
		output2+=("${hilite}${REPLY}")

		_center "${digits3[$i]}" $width
		_trim_ends "$REPLY" $i ${#LESSONS[@]}
		output3+=("${hilite}${REPLY}")

		_center "$name" $width
		_trim_ends "$REPLY" $i ${#LESSONS[@]}
		output4+=("${hilite}${REPLY}")
	done

	printf $'%s\x1b[0m' "${output0[@]}"; echo
	printf $'%s\x1b[0m' "${output1[@]}"; echo
	printf $'%s\x1b[0m' "${output2[@]}"; echo
	printf $'%s\x1b[0m' "${output3[@]}"; echo
	printf $'%s\x1b[0m' "${output4[@]}"; echo

	[[ -n $BASH ]] && eval $RESTORE_FAILGLOB
}


# _tutr_lesson_complete_msg disposition [final-lesson]
#   disposition: success/failure status of the lesson
#      $_COMPLETE means that the lesson was successfully completed
#      any other value indicates an incomplete lesson
#   final: set to a message to print upon completion of the final lesson
#      in the tutorial
_tutr_lesson_complete_msg() {
	cat <<-:

	$(_tutr_progress)

	You worked on this lesson for $(_tutr_pretty_time)
	:

	local disposition=$1
	local final=$2
	if [[ -n "$final" && $disposition == $_COMPLETE ]] ; then
		echo "$final"
		echo Run $(cmd ./tutorial.sh) to retry any lesson
	elif (( $disposition == $_COMPLETE )); then
		echo Run $(cmd ./tutorial.sh) to start the next lesson
	else
		echo Run $(cmd ./tutorial.sh) to retry this lesson
	fi
	echo
}
