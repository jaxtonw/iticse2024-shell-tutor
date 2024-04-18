# Enumerate every way a step can go wrong
# Status=1 is reserved because it's the default return value of a failed
# comparison expression, and may occur when a test function falls through.
#
# WRONG_PWD was once = 1, and this led to many spurious reports of being
# in the wrong directory.
typeset -r WRONG_PWD=2
typeset -r WRONG_CMD=3
typeset -r MISSPELD_CMD=4
typeset -r WRONG_ARGS=5
typeset -r TOO_FEW_ARGS=6
# typeset -r NOOP=7  # defined in stdlib.sh
typeset -r TOO_MANY_ARGS=8
typeset -r STATUS_FAIL=9
typeset -r STATUS_WIN=10


# provides spell checking function _tutr_damlev
source damlev.sh


# Compute the longest common prefix of two paths
#
# When called with 2 arguments, store the result into $REPLY
# When called with more arguments, print the result to STDOUT
_tutr_lcp() {
	# Convert path strings into arrays of path components
	if [[ -n $ZSH_NAME ]]; then
		local O=-rA
		emulate -L zsh
		setopt ksh_arrays
	else
		local O=-ra
	fi
	local -a p1 p2
	IFS=/ read $O p1 <<< "$1"
	IFS=/ read $O p2 <<< "$2"

	## Find length of shortest array
	local end
	(( ${#p1[@]} < ${#p2[@]} )) && local end=${#p1[@]} || local end=${#p2[@]}

	## Search for the first differing component, accumulating the common prefix
	local prefix
	local i
	for (( i=0; i < end; ++i)); do
		if   [[ -z ${p1[$i]} ]]; then continue
		elif [[ ${p1[$i]} == ${p2[$i]} ]]; then
			prefix+=/${p1[$i]}
		else
			break
		fi
	done

	## Return the $result
	[[ -n $3 ]] && echo $prefix || REPLY=$prefix
}



# Compute the shortest path between directories $1 and $2
#
# When called with 2 arguments, store the result into $REPLY
# When called with more arguments, print the result to STDOUT
#
# Input: two directories
_tutr_shortest_path() {
	if (( $# >= 2 )); then
		local there="$1"
		local here="$2"
	else
		echo "Usage: _tutr_shortest_path DEST SRC [echo_result]"
		return 1
	fi

	if [[ $there == $here ]]; then
		(( $# >= 3 )) && echo || REPLY=
	else
		# Elide the common prefix of $here and there
		_tutr_lcp "$here" "$there"
		local LCP=$REPLY
		local dest=""

		if [[ -z $LCP ]]; then
			# 0. no common subtree; return $there verbatim
			dest=$there
		else
			local e_here=${here#$LCP}
			local e_there=${there#$LCP}

			# n.b. this pair of param expansions remove any trailing '/' after $LCP!
			e_here=${e_here#/}
			e_there=${e_there#/}

			if [[ -z $e_here && -z $e_there ]]; then
				cat <<-ERROR

				This should not have happened.

				Run ${_g}tutor bug${_z} and email its output to $_EMAIL.
				Scroll back a few steps to copy some of the preceeding text for
				context.

				ERROR
				return 1
			elif [[ -z $e_here ]]; then
				# 1. $there is a subdir of $here; return $e_there sans the leading /
				dest=${e_there#/}
			else
				# 2. $here is a subdir of $there; return ../ for each component of $here ($there is empty in this case)
				# 3. $there is a cousin dir of $here; return $there prepended with ../ for each component of $here
				dest=../$e_there
				while [[ $e_here = */* ]]; do
					dest=../$dest
					e_here=${e_here#*/}
				done
			fi
		fi

		# Make the output pretty: replace $HOME with ~
		[[ "$HOME" = "$dest/*" ]] && dest="~${dest#$HOME}"

		# ... and wrap the destination directory in quotes if it contains spaces
		[[ $dest = *" "* ]] && dest="'$dest'"

		# finally, remove a trailing /
		dest=${dest%/}

		(( $# >= 3 )) && echo $dest || REPLY=$dest
		true
	fi
}

# Display the minimal `cd` command needed to get to a target directory
# Print `cd -` if the target is $OLDPWD
# Prints a `cd` command which appropriately uses relative or absolute paths
# Wraps the directory name in single-quotes if it contains a space
#
# Input: the absolute path of the directory the user should be in
_tutr_minimal_chdir_hint() {
	local _g="[0;32m" _z="[0m" _u="[4m" _c="[0;36m"
	if [[ -n "$1" ]]; then
		local there="$1"
		local here="${2:-$PWD}"

		local tmp=$there
		[[ $there = $HOME/* ]] && tmp="~${there#$HOME}"
		cat <<-MSG
			To proceed you need to be in the directory
			  ${_u}$tmp${_z}
		MSG

		tmp=$here
		if [[ -n $tmp ]]; then
			[[ $here = $HOME/* ]] && tmp="~${here#$HOME}"
			cat <<-MSG
				instead of
				  ${_u}$tmp${_z}
			MSG
		fi

		printf "\nThis command will get you back on track:\n"

		if [[ $there = $OLDPWD ]]; then
			echo "  ${_g}cd -${_z}"
		else
			_tutr_shortest_path "$there" "$here"
			echo "  ${_g}cd ${REPLY}${_z}"
		fi

	else
		cat <<-MSG
		You are presently in the wrong directory.  Unfortunately,
		I can't tell you which directory you should be in.

		Run ${_g}tutor bug${_z} and email its output to $_EMAIL.
		Scroll back a few steps to copy some of the preceeding text for
		context.

		Then, I'm afraid that you'll need to restart this lesson :-(

		MSG
	fi
}



# Decide if the command line was correct by examining the command, args, CWD and exit status
# This function is useful when the correctness can be determined solely by the form of the command.
# Some steps should be tested with a custom function that can consider the extenral state of the system
# (i.e. files do/don't exist, file contents, passage of time, etc.)
#
# Options:
#  -a = ordered args - must be present in this given order
#       This argument must be given once per positional argument
#       It is regarded as a regular expression, i.e.:
#          -a "hint|hant"
#  -d = dir - what must PWD be?
#  -c = cmd - which command is acceptable?
#       This is a regular expression, i.e.:
#          -c "ls|dir"
#  -l = Max acceptable Levenshtein distance for misspelled commands
#       (Default distance = 1; set to 0 to disable spellchecking)
#  -n = Disregard the number of arguments
#  -i = Ignore command's exit status (default is to report on non-zero exit status)
#  -f = Expect command to fail
#  -x = Extra arguments are permitted. Will check for ordered args and if too few
#    	args are given, but allows additional arguments to be specified
#
# Examples:
#
#  Validate 'ls file1.txt file2.txt' in the directory $_BASE, checking for simple typos
#    _tutr_generic_test -c ls -d "$_BASE" -a file1.txt -a file2.txt
#
#  Idem. but disregard misspellings of 'ls' by setting Levenshtein distance = 0
#    _tutr_generic_test -c ls -d "$_BASE" -a file1.txt -a file2.txt -l 0
#
#  Validate 'systemctl restart' considering typos with Lev. dist. between [1,3]
#    _tutr_generic_test -c systemctl -a restart -l 3
#
# TODO: when the user gives an argument with a trailing '/' this command
#       regards it as wrong, even though in most cases it works just fine
#       Use a regex to cope with this
#
# TODO: filenames on macOS and Windows may be given to the shell without regard to case;
#       this function only accepts matching case even when the OS reports success.
_tutr_generic_test() {
	local -a _A=( cmd )
	local _C= _D= _X=
	local _F= _I=  # options -f and -i are mutually exclusive
	local -i _N=0 _L=1

	local OPT
	OPTIND=1  # this declaration is important to Bash; don't remove it!
	while getopts 'a:c:d:fil:nx' OPT; do
		case $OPT in
			a) _A+=("$OPTARG") ;;
			c) _C="$OPTARG" ;;
			d) _D="$OPTARG" ;;
			f) _F=fail _I= ;;
			i) _I=ignore _F= ;;
			l) _L="$OPTARG" ;;
			n) _N=-1 ;;
			x) _X=extra ;;
			*)
				echo "_tutr_generic_test: getopts parse error! 1=$1 2=$2 3=$3 4=$4" >&2
				exit 1
				;;
		esac
	done

	if [[ -z $_C ]]; then
		echo "_tutr_generic_test: Option '-c CMD' is mandatory" >&2
		exit 1
	fi

	_A[0]=$_C

	## When -n was specified don't count # of arguments on cmdline
	(( _N == 0 )) && _N=${#_A[@]}

	if [[ -n $DEBUG ]]; then
		cat <<-:
		DEBUG|
		DEBUG| _tutr_generic_test():
		DEBUG|   _A=$_N(${_A[@]})
		DEBUG|   _C=$_C
		DEBUG|   _D=$_D
		DEBUG|   _F=$_F
		DEBUG|   _I=$_I
		DEBUG|   _L=$_L
		DEBUG|   _X=$_X
		DEBUG|   _CMD='${_CMD[@]}'
		:

		if [[ -n "${_CMD[@]}" ]]; then
			for ((i=0; i<${#_CMD[@]}; ++i)); do
					echo "DEBUG|     _CMD[$i]='${_CMD[$i]}'"
			done
			echo "DEBUG|   _RES=$_RES"
		fi
	fi

	# Check if the user was in the wrong dir ...
	[[ -n "$_D" && "$PWD" != "$_D" ]] && return $WRONG_PWD

	# if command is spelled correctly...
	if [[ ${_CMD[0]} =~ ^$_C$ ]]; then

		if (( _N > 0 )); then
			# ... or has too few args ...
			[[ "${#_CMD[@]}" -lt $_N ]] && return $TOO_FEW_ARGS

			# ... or too many args ...
			[[ "${#_CMD[@]}" -gt $_N && -z $_X ]] && return $TOO_MANY_ARGS
		fi

		# ... or the wrong args
		# (Indexing from 1 works in Zsh b/c the 'ksh_arrays' option is in force)
		for (( _J=1; _J<$_N; _J++ )); do
			# =~ works in Bash and Zsh; the regex pattern goes on RHS
			# IMPORTANT! Do NOT put quotes around the regex pattern!
			# The pattern is not a string to be quoted
			! [[ ${_CMD[$_J]} =~ ^${_A[$_J]}$ ]] && return $WRONG_ARGS
		done

		if [[ $_I = ignore ]]; then
			## When -i is specified we will ignore the exit code of the command;
			return 0
		elif [[ $_F = fail ]]; then
			## When -f is specified we expect the command to have failed
			[[ $_RES != 0 ]] && return 0 || return $STATUS_WIN
		elif [[ $_RES != 0 ]]; then
			## Otherwise, we care that the command's exit code == 0
			return $STATUS_FAIL
		else
			return 0
		fi

	elif [[ $_L != 0 && -n ${_CMD[0]} ]]; then
		# When we get down here it's because the command didn't match the expectation.
		# If spellchecking is an option, see if the user made a typo ...
		_tutr_damlev ${_CMD[0]} $_C $_L && return $MISSPELD_CMD
	fi

	# ... If it wasn't a typo it can only be the wrong command
	return $WRONG_CMD
}


# Display a generic hint based upon how the previous command failed, as determined by _tutr_generic_test
#
# $1 = error code
# $2 = name of cmd they should have run
# $3 = Directory user needs to get into
_tutr_generic_hint() {
	local _g="[0;32m" _z="[0m"
	[[ -n $DEBUG ]] && echo "DEBUG| _tutr_generic_hint($1, $2, $3)"
	case $1 in
		$MISSPELD_CMD)  echo "It looks like you spelled ${_g}$2${_z} wrong" ;;
		$WRONG_CMD)     echo "Use the ${_g}$2${_z} command to proceed" ;;
		$TOO_FEW_ARGS)  echo "You gave ${_g}$2${_z} too few arguments" ;;
		$TOO_MANY_ARGS) echo "You ran ${_g}$2${_z} with too many arguments" ;;
        $WRONG_ARGS)    echo "${_g}$2${_z} got the wrong argument(s)" ;;
		$WRONG_PWD)     _tutr_minimal_chdir_hint "$3" ;;
        $NOOP)          : ;;
		$STATUS_FAIL)   echo "${_g}$2${_z} failed unexpectedly" ;;
		$STATUS_WIN)    echo "${_g}$2${_z} succeeded when it should have failed" ;;
		*)              printf "_tutr_generic_hint(): Why do we have status code ${_m}%s${_z}? CMD=${_g}%s${_z} \$1=%s\n\n" $1 ${_CMD[@]} ;;
	esac
}


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4:
