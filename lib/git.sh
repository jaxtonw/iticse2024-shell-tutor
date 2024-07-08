# Functions for Git repositories

# Note #0
# -------
# `git status` pipes to a curly braced command list in some of these
# functions because, in Bash, variable scope behaves differently when piping
# directly to a `while` loop when run in an interactive shell vs. a script.
#
# Somehow, the curly brace makes this OK.
#
# These functions worked in Zsh without this chicanery.


# Note #1
# -------
# I want to minimize the number of calls to `git status`.
#
# Presently, predicate functions (e.g. _tutr_file_staged,
# _tutr_branch_ahead, etc.) each call their associated status function
# without regard to whether another predicate has already called it
# recently.
#
# One idea is to make a latch around the status function which is reset
# at the top of *_test.  The latch variable would be reset to null, and
# is set to the name of the file about which status was queried.
#
# If the status function is called with a file argument that differs from
# the value of the latch, it is re-run.  Otherwise, it returns the cached
# value from its last run.


# Convert the current Git repo's $1 remote URL into HTTPS
# If $1 is unspecified, use 'origin'
# Store converted URL in $REPLY; unset $REPLY on error
_tutr_git_repo_https_url() {
	local URL
	if git status >/dev/null 2>&1 ; then
		URL=$(git remote get-url ${1:-origin})
		if [[ $URL == git@* ]]; then
			URL=${URL/:/\/}
			URL=${URL/git@/https:\/\/}
		elif [[ $URL = https://* ]]; then
			:
		else
			_tutr_warn echo "Unrecognized URL '$URL'"
			unset REPLY
			return
		fi
		REPLY=${URL/ (*)//}
	else
		echo This is not a Git repository
		unset REPLY
	fi
}


# Read-only return codes used by _git_file_status
typeset -r _GF_CHANGED=1
typeset -r _GF_STAGED=2
typeset -r _GF_ADDED=4
typeset -r _GF_DELETED=8
typeset -r _GF_UNTRACKED=16
typeset -r _GF_IGNORED=32
typeset -r _GF_RENAMED=64

# Get complete Git status of a file in only one call to `git status`
_git_file_status() {
	(( $# == 1 )) || _tutr_die echo _git_file_status takes 1 argument

	git status --ignored --porcelain=v1 | {
		local stat=0 line
		while IFS=$'\n' read line; do
			[[ $line != *$1 ]] && continue
			case $line in
				"?? $1")         (( stat |= _GF_UNTRACKED )) ;;
				"MM $1")         (( stat |= _GF_CHANGED | _GF_STAGED )) ;;
				A[\ MTD]" $1")   (( stat |= _GF_ADDED )) ;;
				?"M $1")         (( stat |= _GF_CHANGED )) ;;
				"M  $1")         (( stat |= _GF_STAGED )) ;;
				"D  $1")         (( stat |= _GF_DELETED | _GF_STAGED )) ;;
				" D $1")         (( stat |= _GF_DELETED )) ;;
				"!! $1")         (( stat |= _GF_IGNORED )) ;;
				R[\ MTD]" "*$1*) (( stat |= _GF_RENAMED )) ;;
			esac
		done
		return $stat
	}
}


# return 0 iff file $1 has no changes; ignores branch status
_tutr_file_clean() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_clean takes 1 argument
	_git_file_status $1
	(( ($? & 127) == 0))
}

# return 0 iff file $1 has only unstaged changes
_tutr_file_unstaged() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_unstaged takes 1 argument
	_git_file_status $1
	(( $? & (_GF_CHANGED|_GF_DELETED) ))
}


# return 0 iff file $1 has only staged changes
_tutr_file_staged() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_staged takes 1 argument
	_git_file_status $1
	(( $? & (_GF_STAGED|_GF_ADDED) ))
}


# return 0 iff file $1 has been added to the index
_tutr_file_added() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_added takes 1 argument
	_git_file_status $1
	(( $? & _GF_ADDED ))
}


# return 0 iff file $1 has staged and/or unstaged changes
_tutr_file_changed() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_changed takes 1 argument
	_git_file_status $1
	(( $? & (_GF_CHANGED|_GF_DELETED|_GF_STAGED|_GF_ADDED) ))
}


# return 0 iff file $1 has been deleted
_tutr_file_deleted() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_deleted takes 1 argument
	_git_file_status $1
	(( $? & _GF_DELETED ))
}


# return 0 iff file $1 is untracked
_tutr_file_untracked() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_untracked takes 1 argument
	_git_file_status $1
	(( $? & _GF_UNTRACKED ))
}


# return 0 iff file $1 is ignored
_tutr_file_ignored() {
	(( $# == 1 )) || _tutr_die echo _tutr_file_ignored takes 1 argument
	_git_file_status $1
	(( $? & _GF_IGNORED ))
}


typeset -r _GB_AHEAD=1
typeset -r _GB_BEHIND=2

# Return a value indicating whether the current branch is ahead or behind
# its remote counterpart.
#
# Store the number of commits the current branch is ahead/behind in $REPLY
_git_branch_status() {
	git status --branch --porcelain=v1 | {
		local stat=0 line
		while IFS=$'\n' read line; do
			if [[ $line == "## "*...*/* ]]; then
				if [[ $line = *\[ahead* ]]; then
					(( stat |= _GB_AHEAD ))
					REPLY=${line##* }
					REPLY=${REPLY%']'*}
				elif [[ $line = *\[behind* ]]; then
					(( stat |= _GB_BEHIND ))
					REPLY=${line##* }
					REPLY=${REPLY%']'*}
				fi
				break
			fi
		done
		return $stat
	}
}


# return 0 iff the current branch is ahead of its remote
_tutr_branch_ahead() {
	_git_branch_status
	(( $? & _GB_AHEAD ))
}

# Return the number of commits the current branch is ahead of its remote
# IMPORTANT!!!
# 0/non-zero DOES NOT indicate success/failure
_tutr_branch_ahead_count() {
    local stat=0

    # `git status` pipes to a curly braced command list because, in Bash,
    # variable scope behaves differently when piping directly to a `while` loop
    # when run in an interactive shell vs. a script.
    #
    # Somehow, the curly brace makes this OK.
    # It worked in Zsh without this chicanery.
    git status --branch --ignored --porcelain=v1 | {
        while IFS=$'\n' read line; do
			if [[ $line == "## "*...*/* ]]; then
				if [[ $line = *ahead* ]]; then
					stat=$line
					stat=${stat##* }
					stat=${stat%']'*}
					(( stat |= _GB_AHEAD ))
				elif [[ $line = *behind* ]]; then
					stat=$line
					stat=${stat##* }
					stat=${stat%']'*}
					(( stat |= _GB_BEHIND ))
				fi
				break
			else
				break
			fi
        done
        return $stat
    }
}


# return 0 iff the current branch is behind its remote
_tutr_branch_behind() {
	_git_branch_status
	(( $? & _GB_BEHIND ))
}


# return 0 iff currently on a branch and that branch matches $1
_tutr_on_branch() {
	(( $# != 1 )) && _tutr_die echo "Usage: _tutr_on_branch BRANCH"

	git status --branch --porcelain=v1 | {
		local branch=$1
		local line bname
		while IFS=$'\n' read line; do
			case $line in
				"## HEAD (no branch)")
					return 1 ;;

				"## "*...*/*)
					# extract branch name & compare
					bname=${line##"## "}
					bname=${bname%%...*}
					[[ $bname == $branch ]]
					return $?
					;;

				"## "*)
					# extract branch name & compare
					bname=${line##"## "}
					[[ $bname == $branch ]]
					return $?
					;;

				*)
					_tutr_warn echo "_tutr_on_branch: did git status change its output format?"
					return 7
					;;
			esac
		done
	}
}


# return 0 iff currently on a branch, that branch matches $1,
# and tracks remote $2
_tutr_on_tracking_branch() {
	(( $# != 2 )) && _tutr_die echo "Usage: _tutr_on_tracking_branch REMOTE BRANCH"

	git status --branch --porcelain=v1 | {
		local remote=$1 branch=$2
		local line bname rname
		while IFS=$'\n' read line; do
			case $line in
				"## HEAD (no branch)")
					return 1 ;;

				"## "*...*/*)
					# extract branch name, remote name & compare
					bname=${line##"## "}
					bname=${bname%%...*}
					rname=${line##*...}
					rname=${rname%% *}
					[[ $bname == $branch && $rname == $remote/$branch ]]
					return $?
					;;

				"## "*)
					# not on a remote tracking branch
					return 1 ;;

				*)
					_tutr_warn echo "_tutr_on_tracking_branch: did git status change its output format?"
					return 7
					;;
			esac
		done
	}
}


# return 0 iff HEAD is detached
_tutr_detached_head() {
	(( $# != 0 )) && _tutr_die echo "Usage: _tutr_detached_head"
	git status --branch --porcelain=v1 | {
		local line
		while IFS=$'\n' read line; do
			[[ $line == "## HEAD (no branch)" ]]
			return $?
		done
	}
}


# Get the status of files in a named directory
# The directory must be specified relative to the root of the repository
#   (matching the name shown by `git status --porcelain=v1`
# Result bits are set if at least ONE file in the directory has that status
_git_dir_status() {
	(( $# != 1 )) && _tutr_die echo _git_dir_status needs a directory name

	git status --ignored --untracked=all --porcelain=v1 $1 | {
		local stat=0 line
		while IFS=$'\n' read line; do
			case $line in
				"?? "*)         (( stat |= _GF_UNTRACKED )) ;;
				"MM "*)         (( stat |= _GF_CHANGED | _GF_STAGED )) ;;
				A[\ MTD]" "*)   (( stat |= _GF_ADDED   )) ;;
				?"M "*)         (( stat |= _GF_CHANGED )) ;;
				"M  "*)         (( stat |= _GF_STAGED  )) ;;
				"D  "*)         (( stat |= _GF_DELETED | _GF_STAGED )) ;;
				" D "*)         (( stat |= _GF_DELETED )) ;;
				"!! "*)         (( stat |= _GF_IGNORED )) ;;
				R[\ MTD]" "*)   (( stat |= _GF_RENAMED )) ;;
			esac
		done
		return $stat
	}
}


# return 0 iff dir $1 has no changes; ignores branch status
_tutr_dir_clean() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_clean takes 1 argument
	_git_dir_status $1
	(( ($? & 127) == 0))
}

# return 0 iff dir $1 has only unstaged changes
_tutr_dir_unstaged() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_unstaged takes 1 argument
	_git_dir_status $1
	(( $? & (_GF_CHANGED|_GF_DELETED) ))
}


# return 0 iff dir $1 has only staged changes
_tutr_dir_staged() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_staged takes 1 argument
	_git_dir_status $1
	(( $? & (_GF_STAGED|_GF_ADDED) ))
}


# return 0 iff dir $1 has been added to the index
_tutr_dir_added() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_added takes 1 argument
	_git_dir_status $1
	(( $? & _GF_ADDED ))
}


# return 0 iff dir $1 has staged and/or unstaged changes
_tutr_dir_changed() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_changed takes 1 argument
	_git_dir_status $1
	(( $? & (_GF_CHANGED|_GF_DELETED|_GF_STAGED|_GF_ADDED) ))
}


# return 0 iff dir $1 has been deleted
_tutr_dir_deleted() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_deleted takes 1 argument
	_git_dir_status $1
	(( $? & _GF_DELETED ))
}


# return 0 iff dir $1 is untracked
_tutr_dir_untracked() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_untracked takes 1 argument
	_git_dir_status $1
	(( $? & _GF_UNTRACKED ))
}


# return 0 iff dir $1 is ignored
_tutr_dir_ignored() {
	(( $# == 1 )) || _tutr_die echo _tutr_dir_ignored takes 1 argument
	_git_dir_status $1
	(( $? & _GF_IGNORED ))
}


_tutr_git_default_text_statelog() {
	TARGET_REPO_PATH=${1:-$PWD}

	cat <<-STATETEXT
	<=== REPO PATH ===>
	${TARGET_REPO_PATH}

	STATETEXT

	if [[ ! -d "$TARGET_REPO_PATH/.git" ]] && ! git -C "$TARGET_REPO_PATH" rev-parse --show-toplevel 2> /dev/null; then
		cat <<-STATETEXT
		<=== IS GIT REPO ===>
		FALSE
		STATETEXT
		return
	fi

	cat <<-STATETEXT
	<=== IS GIT REPO ===>
	TRUE

	<=== PORCELAIN STATUS ===>
	$(git -C "$TARGET_REPO_PATH" status --ignored --untracked=all --porcelain=v1)

	<=== GIT SHORTLOG : git log -100 --oneline --decorate --all --no-color ===>
	$(git -C "$TARGET_REPO_PATH" log -100 --oneline --decorate --all --no-color)

	<=== CONFIGURED REMOTES ===>
	$(git -C "$TARGET_REPO_PATH" remote -v)

	STATETEXT

	# Cannot inspect the .ls-remote file with this function, as it's
	# generated in the _test, which runs *after* this. To add any
	# information from the .ls-remote file, one would need to modify the
	# _test function
	# to append the contents of .ls-remote to the desired location. Not the
	# cleanest solution, but the cost of 'git ls-remote' is too great to have
	# the operation happen here :/
}


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
