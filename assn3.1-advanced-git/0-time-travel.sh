#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=15

# Put tutorial library files into $PATH
PATH="$PWD/.lib:$PATH"

source ansi-terminal-ctl.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source editors+viewers.sh
	source generic-error.sh
	source git.sh
	source noop.sh
fi

declare -r _REPO_NAME=iticse2024-shell-tutor-pomodoro
declare -r _REPO_URL_SSH=git@github.com:jaxtonw/$_REPO_NAME

Pomodoro() { (( $# == 0 )) && echo $(red Pomodoro) || echo $(red $*); }
_Git() { (( $# == 0 )) && echo $(blu Git) || echo $(blu $*); }
_master() { (( $# == 0 )) && echo $(grn master) || echo $(grn $*); }


not_in_repo() {
	cat <<-MSG
	This step $(bld must) be completed inside the repository directory.
	You will be unable to complete this step outside of the repository.
	MSG
}

on_wrong_commit() {
	cat <<-MSG
	This step expects to be on commit $(path $1).
	Run $(cmd git checkout -f $1) to proceed.
	MSG
}

must_be_in_repo() {
	if [[ "$PWD" != "$_REPO_PATH" ]]; then
		_tutr_warn not_in_repo
		return 1
	fi
}

must_be_on_commit() {
	if [[ "$(git rev-parse --short HEAD)" != $1 ]]; then
		_tutr_warn on_wrong_commit $1
		return 1
	fi
}

_python3_not_found() {
	cat <<-PNF
	I could not find a working $(_py Python 3) interpreter on your computer.
	It is required for this lesson.

	Contact $_EMAIL for help
	PNF
}

_tutr_lesson_statelog_global() {
	_TUTR_STATE_CODE= # We don't have a meaningful and general state code yet...
	_TUTR_STATE_TEXT=$(_tutr_git_default_text_statelog $_REPO_PATH)
}



setup() {
	export _ORIG_PWD="$PWD"
	export _PARENT="$(cd .. && pwd)"
	if (cd $_PARENT; git status &>/dev/null); then
		export _PARENT="$(cd ../.. && pwd)"
	fi
	export _REPO_PATH="$_PARENT/$_REPO_NAME"

	source screen-size.sh 80 30

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh
	_tutr_assert_program_exists git

	source ssh-connection-test.sh
	_tutr_assert_ssh_connection_is_okay

	if   which python &>/dev/null && [[ $(python -V 2>&1) = "Python 3"* ]]; then
		export _PY=python
	elif which python3 &>/dev/null && [[ $(python3 -V 2>&1) = "Python 3"* ]]; then
		export _PY=python3
	else
		_tutr_die _python3_not_found
    fi

	# reset branches and tags in the Pomodoro repository
	if [[ -d "$_REPO_PATH/.git" ]]; then
		(
		echo "Tidying up the $(Pomodoro) repository, please wait..."
		cd "$_REPO_PATH"
		git checkout --detach
		local IFS=$'\n'
		for branch in $(git branch --no-color); do
			[[ $branch = \** ]] && continue
			git branch --delete --force ${branch#  }
		done

		for tag in $(git tag --list); do
			git tag --delete $tag
		done

		git checkout master
		echo
		)
	fi
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #0: Time Travel with Git

	In this lesson you will learn how to use Git to

	* Time travel between commits
	* Tag an interesting commit in the past
	* See what has changed between commits

	This lesson takes around $_DURATION minutes.

	PROLOGUE
	_tutr_pressenter

	cat <<-PROLOGUE

	Before getting started, I want to remind you of a few key points:

	* If you discover a typo or bug in the lesson, run $(cmd tutor bug) to report it
	* If you're unsure about your next steps, remember $(cmd tutor hint)
	* Throughout this lesson you will run commands that generate extensive
	  output. A number of $(_Git) commands offer suggestions to assist you.
	  However, it is best to focus on the commands taught by this tutorial.
	  Instructions from me are marked with "$(grn Tutor):".  Prioritize these
	  directions over others that lack this prefix.

	Ready to begin?

	PROLOGUE
	_tutr_pressenter
}



cd_dotdot_rw() {
	cd "$_ORIG_PWD"
}

cd_dotdot_ff() {
	cd "$_PARENT"
}

cd_dotdot_prologue() {
	cat <<-MSG
	In this lesson you will clone a small repository to play around in.

	Before you clone it down, $(cmd cd) out of the Shell Tutor's repository.

	I think that the directory $(path ${_PARENT}) would work best.
	MSG
}

cd_dotdot_test() {
	if _tutr_noop; then return $NOOP
	elif [[ "$PWD" != "$_PARENT" ]]; then return $WRONG_PWD
	else return 0
	fi
}

cd_dotdot_hint() {
	_tutr_generic_hint $1 cd "$_PARENT"
}



clone_repository_rw() {
	rm -rf "$_REPO_PATH"
}

clone_repository_ff() {
	git clone $_REPO_URL_SSH
}

clone_repository_pre() {
	if [[ -d "$_REPO_PATH/.git" ]]; then
		_tutr_err repo_already_exists
		return 1
	fi
}

clone_repository_prologue() {
	cat <<-MSG
	Now that you're here, clone the repository from
	  $(path $_REPO_URL_SSH)
	MSG
}

clone_repository_test() {
	HTTPS_URL=99
	if   _tutr_noop rm; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = clone && ${_CMD[2]} = http* ]]; then return $HTTPS_URL
	elif [[ -d "$_REPO_PATH/.git" ]]; then return 0
	else _tutr_generic_test -c git -a clone -a "^($_REPO_URL_SSH(.git)?)$" -d "$_PARENT"
	fi
}

clone_repository_hint() {
	case $1 in
		$NOOP)
			;;

		$STATUS_FAIL)
			cat <<-MSG
			$(cmd git clone) failed unexpectedly.

			If the above error message includes the phrases $(bld fatal: unable to)
			$(bld access) and $(bld Connection refused), that indicates an issue with your
			network connection.  Ensure that you are connected to the internet and
			try again.

			If the error persists or is different, please contact
			$_EMAIL for help.
			Copy the full command and all of its output.
			MSG
			;;

		$WRONG_PWD)
			_tutr_generic_hint $1 git "$_PARENT"
			;;

		$HTTPS_URL)
			cat <<-MSG
			You cloned the repository with an HTTPS URL.  At $(DuckieCorp) you
			should always use SSH URLs.

			Remove the repo you just cloned:
			  $(cmd rm -rf $_REPO_NAME)

			Then re-clone it by running:
			  $(cmd git clone $_REPO_URL_SSH)

			If you do not have an SSH key set up, reach out to
			$_EMAIL for help.
			MSG
			;;

		*)
			_tutr_generic_hint $1 git

			cat <<-MSG

			Clone the demo repo by running
			  $(cmd git clone $_REPO_URL_SSH)
			MSG
			;;
	esac
}



cd_into_repo_rw() {
	cd "$_PARENT"
}

cd_into_repo_ff() {
	cd "$_REPO_PATH"
}

cd_into_repo_prologue() {
	cat <<-MSG
	Enter the directory $(path ${_POMODORO_PRESENT+../}$_REPO_NAME)
	MSG
}

cd_into_repo_test() {
	if   [[ "$PWD" == "$_REPO_PATH" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else return $WRONG_PWD
	fi
}

cd_into_repo_hint() {
	[[ $1 == $NOOP ]] && return
	_tutr_minimal_chdir_hint "$_REPO_PATH"
}

cd_into_repo_post() {
	declare -ag _COMMITS=( $(git log --pretty=%h) )
}




inspect_repo_ls_pre() {
	must_be_in_repo
}

inspect_repo_ls_prologue() {
	cat <<-MSG
	Take a look at the files here with $(cmd ls)
	MSG
}

inspect_repo_ls_test() {
	_tutr_generic_test -c ls -x -d "$_REPO_PATH"
}

inspect_repo_ls_hint() {
	_tutr_generic_hint $1 ls "$_REPO_PATH"
}

inspect_repo_ls_epilogue() {
	_tutr_pressenter
}



inspect_readme_pre() {
	must_be_in_repo
}

inspect_readme_prologue() {
	cat <<-MSG
	Just two files, simple enough.

	But what's a "pomodoro"?  Take a look at $(path README.md) to find out.
	MSG
}

inspect_readme_test() {
	if   _tutr_noop; then return $NOOP
	elif _tutr_is_viewer && (( _RES == 0 )); then
		[[ "$(realpath ${_CMD[1]})" == README.md ]] && return 0
		_tutr_generic_test -c ${_CMD[0]} -a README.md -d "$_REPO_PATH"
	else
		_tutr_generic_test -c less -a README.md -d "$_REPO_PATH"
	fi
}

inspect_readme_hint() {
	[[ $1 == $NOOP ]] && return

	_tutr_generic_hint $1 less "$_REPO_PATH"

	if (( _ATTEMPTS > 3 )); then
		cat <<-MSG

		Read $(path README.md) with $(cmd less README.md)
		MSG
	fi
}

inspect_readme_epilogue() {
	cat <<-MSG
	TIL that $(Pomodoro) is a timer app made by a guy obsessed with $(Pomodoro tomatoes).

	$(Pomodoro Tomatoes).  WHY NOT?
	MSG
}



inspect_repo_log_pre() {
	must_be_in_repo
}

inspect_repo_log_prologue() {
	cat <<-MSG
	Now use $(cmd git log) to review the commit history of this project.
	MSG
}

inspect_repo_log_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then
		return $NOOP
	else
		_tutr_generic_test -c git -a log -d "$_REPO_PATH"
	fi
}

inspect_repo_log_hint() {
	[[ $1 == $NOOP ]] && return

	_tutr_generic_hint $1 git "$_REPO_PATH"

	if (( _ATTEMPTS > 3 )); then
		cat <<-MSG

		Review the commit history with $(cmd git log).
		MSG
	fi
}


inspect_repo_log_epilogue() {
	cat <<-MSG
	By now you should feel pretty at home with this workflow.  You can see
	seven commits' worth of work on a simple timer application, and no tags.

	MSG
	_tutr_pressenter
}




run0_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[0]}
}

run0_prologue() {
	cat <<-MSG
	Why don't you launch $(_py pomodoro.py) to see what a $(Pomodoro tomato) timer looks like.

	Run it using $(_py $_PY).  Use $(kbd Ctrl-C) to quit the timer.
	MSG
}

run0_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run0_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd $_PY pomodoro.py)
	MSG
}

run0_epilogue() {
	cat <<-MSG
	Whoa, that timer goes by fast!

	That has nothing to do with $(Pomodoro tomatoes).  That just makes it easier to test
	during development.  This program is still incomplete, and that will be
	changed before it is released.

	MSG
	_tutr_pressenter
}




edit_pomodoro0_ff() {
	sed -i -e 's/DELAY = .*$/DELAY = 1.0/' pomodoro.py
}

edit_pomodoro0_rw() {
	sed -i -e 's/DELAY = .*$/DELAY = 0.005/' pomodoro.py
}

edit_pomodoro0_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[0]}
}

edit_pomodoro0_prologue() {
	cat <<-MSG
	Let's slow down the clock to experience this program as it was meant to
	operate.  Edit $(_py pomodoro.py) and set the $(bld DELAY) to $(bld 1) second.
	MSG
}

has_1_sec_delay() {
	grep -q -E "^DELAY[[:space:]]*=[[:space:]]*1(\.0*)?$" "$_REPO_PATH/pomodoro.py"
}

edit_pomodoro0_test() {
	_DELETED=99
	_UNSTAGED=98
	_UNCHANGED=97

	_tutr_noop git && return $NOOP
	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	[[ ! -f "$_REPO_PATH/pomodoro.py" ]] && return $_DELETED
	if _tutr_file_unstaged pomodoro.py; then
		has_1_sec_delay && return 0
		return $_UNSTAGED
	else
		return $_UNCHANGED
	fi
}

edit_pomodoro0_hint() {
	local _max=5
	cat <<-MSG
	Attempt $_ATTEMPTS/$_max

	MSG

	if (( _ATTEMPTS < $_max )); then
		case $1 in
			$_DELETED)
				cat <<-MSG
				Whoops!

				Run $(cmd git restore pomodoro.py) to bring it back.
				MSG
				;;

			$_UNSTAGED)
				cat <<-MSG
				That's not what I asked for.  Edit $(_py pomodoro.py) so that the $(bld DELAY) is
				exactly one (1) second long.  If you've messed up the file too much to
				continue, run $(cmd git restore pomodoro.py) to fix it.
				MSG
				;;

			$_UNCHANGED)
				cat <<-MSG
				Edit $(_py pomodoro.py) and set the $(bld DELAY) to exactly one second.

				If you have irrepairably broken the file, use $(cmd git restore pomodoro.py)
				to put it back together so you can try again.
				MSG
				;;

			$WRONG_PWD)
				_tutr_minimal_chdir_hint "$_REPO_PATH"
				;;
		esac
	elif [[ $1 == $WRONG_PWD ]]; then
		_tutr_minimal_chdir_hint "$_REPO_PATH"
	else
		cat <<-MSG
		It seems like this $(_py) script is giving you some trouble!
		I'll make the change for you...  run $(cmd tutor check) to be signed off.
		MSG
		git restore pomodoro.py
		edit_pomodoro0_ff
	fi
}



run1_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[0]}
}

run1_prologue() {
	cat <<-MSG
	Now run it again to get the full $(Pomodoro) experience.

	Reminder: quit the program with $(kbd Ctrl-C) after you get bored.
	MSG
}

run1_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run1_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd $_PY pomodoro.py)
	MSG
}

run1_epilogue() {
	cat <<-MSG
	That's more like it!

	MSG
	_tutr_pressenter
}


on_commit() {
	[[ $1 == $(git rev-parse --short HEAD) ]]
}


go_back0_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[0]}
}

go_back0_prologue() {
	cat <<-MSG
	Let's dive into the development journey of this project.  $(cmd git checkout)
	acts like a time machine for your files, reverting them to a previous state
	without the complications of actual time travel.

	To use $(cmd git checkout), you must specify the point in history you want

	To use git checkout, you must specify the point in history you want to
	revisit.  That moment can be identified by a tag, a commit ID, or a
	commit relative to $(cyn HEAD).  Relative commits allow you to talk to
	$(_Git) in terms such as "N commits ago".  The relative commit that means
	"one commit ago" has this syntax: $(cyn HEAD~).

	Use $(cmd git checkout) to visit the previous commit.
	MSG
}

go_back0_test() {
	_GONE_TOO_FAR=99
	if   [[ "$PWD" != "$_REPO_PATH" ]]; then return $WRONG_PWD
	elif on_commit ${_COMMITS[1]}; then return 0
	elif ! on_commit ${_COMMITS[0]}; then return $_GONE_TOO_FAR
	elif [[ "${_CMD[@]}" == "git checkout HEAD~" && $_RES != 0 ]]; then return 0
	else _tutr_generic_test -c git -a checkout -a HEAD~ -d "$_REPO_PATH"
	fi
}

go_back0_hint() {
	case $1 in
		$_GONE_TOO_FAR)
			cat <<-MSG
			You've gone too far this time!

			It's cool that you already know how to make Git take you where you want
			to go, but to keep this lesson in sync I must insist that you do this
			"the right way".  After all, we are playing with time-travel technology,
			and you don't want to create a paradox.

			I'm going to put you right back on $(_master) so you can try again.

			Use $(cmd git checkout HEAD~) to (try to) go back one commit.
			MSG

			git checkout -f ${_COMMITS[0]}
			sed -i -e 's/DELAY = .*$/DELAY = 1.0/' pomodoro.py
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;

		$WRONG_CMD|$WRONG_ARGS|$TOO_FEW_ARGS|$TOO_MANY_ARGS)
			cat <<-MSG
			Run $(cmd git checkout HEAD~) to go back by one commit
			MSG
			;;
	esac
}

go_back0_epilogue() {
	if on_commit ${_COMMITS[1]}; then
		echo "You already know the cheat code!  Skipping..."
	else
		_tutr_pressenter
		cat <<-MSG

		I wanted to demonstrate for you the care that $(_Git) takes to not throw away
		your work.  If $(_Git) had not stopped you, the change you made to
		$(_py pomodoro.py)'s DELAY constant would have been lost forever.

		Now, that was just a trivial thing that we don't care about, but $(_Git)
		doesn't know that.  It considers $(bld every) change as if it were valuable.

		MSG
		_tutr_pressenter
	fi
}



go_back_with_force_ff() {
	git checkout -f ${_COMMITS[1]}
}

go_back_with_force_rw() {
	git checkout -f ${_COMMITS[0]}
	sed -i -e 's/DELAY = .*$/DELAY = 1.0/' pomodoro.py
}

go_back_with_force_pre() {
	must_be_in_repo
}

# TODO: take into account the status of `git config --get advice.detachedHead` before
#       the explanation of detached heads and `git switch`
go_back_with_force_prologue() {
	cat <<-MSG
	As $(_Git "Git's") message suggests, the only way to leave this commit is to either
	$(cyn commit your work) or $(red throw it away).  Because this change is not important,
	you might run $(cmd git restore pomodoro.py) to discard it before moving on.

	That would work, but requires you to type an extra command.

	There is a way to get rid of this change $(bld and) step back in time in one
	command.  There is an option that makes $(_Git) $(bld forcefully) checkout another
	commit.

	The option to give the $(cmd checkout) subcommand is $(cmd -f) (or $(cmd --force)).

	MSG

	_tutr_pressenter

	cat <<-MSG

	Before you run this command, I want to warn you that $(_Git) might show you
	a big, scary wall of text.  It will mention $(red detached) $(cyn HEAD)s, $(ylw experimental)
	changes, and how to create new branches with $(cmd git switch).

	You can ignore this message for now.  While in the tutorial you should
	just stick to the commands that I teach you.  You can always tell when
	I'm speaking to you because my words start with "$(grn Tutor):".

	There isn't anything wrong with $(cmd git switch); it's just not what I
	want to focus on today.

	MSG

	_tutr_pressenter

	cat <<-MSG

	With that out of the way, forcefully $(cmd checkout) the $(cyn HEAD~) commit.
	MSG
}

go_back_with_force_test() {
	_STILL_HERE=99
	_TOO_FAR_BACK=98
	_DESTINATION=${_COMMITS[1]}

	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	on_commit ${_COMMITS[1]} && return 0
	on_commit ${_COMMITS[0]} && return $_STILL_HERE
	return $_TOO_FAR_BACK
}

go_back_with_force_hint() {
	case $1 in
		$_TOO_FAR_BACK)
			cat <<-MSG
			You went too far back!

			Let me help you out.

			Run $(cmd git checkout -f $_DESTINATION) to go where you need to be.
			MSG
			;;

		$_STILL_HERE)
			cat <<-MSG
			Run $(cmd git checkout -f HEAD~) to forcefully go back one commit.
			MSG
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;
	esac
}

go_back_with_force_epilogue() {
	_tutr_pressenter
	cat <<-MSG

	A $(red detached) $(cyn HEAD) isn't a bad thing.  It just means that you are not on a
	branch right now.  You were on the $(_master) branch, and now you aren't.

	There is nothing to be concerned about.

	MSG
	_tutr_pressenter
}



run2_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[1]}
}

run2_prologue() {
	cat <<-MSG
	I wonder what was changed between this commit and the one we came from?

	Re-run $(_py pomodoro.py) and see if you can notice any difference.
	MSG
}

run2_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run2_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd $_PY pomodoro.py)
	MSG
}

run2_epilogue() {
	cat <<-MSG
	On this commit a big stack trace is printed when $(kbd Ctrl-C) is pressed.
	It may be a little slower... it's hard to tell.

	What you need is a way to see how the source code changed between these
	two versions.

	MSG
	_tutr_pressenter
}




git_diff0_pre() {
	must_be_in_repo
}

git_diff0_prologue() {
	cat <<-MSG
	The $(cmd git diff) command displays the difference between two commits.

	Previously, you used this command to review changes that you made before
	committing them.  If you give this command the name of a commit as an
	argument, it will show you how the project has been changed between $(cyn HEAD)
	and that commit.

	The name of the commit you want to compare is $(_master).

	Run $(cmd git diff master) to see what was changed in this repo's latest commit.
	MSG
}

git_diff0_test() {
	_tutr_generic_test -c git -a diff -a master -d "$_REPO_PATH"
}

git_diff0_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;

		$WRONG_CMD|$WRONG_ARGS|$TOO_FEW_ARGS|$TOO_MANY_ARGS)
			cat <<-MSG
			Run $(cmd git diff master) to see what was changed in this repo's latest commit.
			MSG
			;;
	esac
}

git_diff0_epilogue() {
	cat <<-MSG
	$(cmd git diff master) shows you how to change $(_py pomodoro.py) in the $(_master) commit
	to make it match $(cyn HEAD) (a.k.a. the current commit).

	$(red_ Red) text are lines to $(red_ erase) from the $(_master) version to make $(_py pomodoro.py)
	become like the current code.

	$(grn_ Green) text are lines that need to be $(grn_ added) to the $(_master) commit to make
	it the same as $(cyn HEAD).

	MSG
	_tutr_pressenter

	cat <<-MSG

	In summary, the checked-out version has a longer delay and crashes when
	$(kbd Ctrl-C) is pressed.

	The code at $(_master) has a shorter delay and incorporates a $(_py try)/$(_py except)
	block to catch $(_py KeyboardInterrupt), which supresses the stack trace.

	MSG
	_tutr_pressenter
}




go_back1_ff() {
	git checkout -f ${_COMMITS[2]}
}

go_back1_rw() {
	git checkout -f ${_COMMITS[1]}
}

go_back1_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[1]}
}

go_back1_prologue() {
	cat <<-MSG
	Let's continue our journey.  Go back in time by one more commit with
	$(cmd git checkout HEAD~).

	If you didn't change anything you won't need the $(cmd -f) flag.
	MSG
}

go_back1_test() {
	_STILL_HERE=99
	_TOO_FAR_BACK=98
	_TOO_FAR_FORWARD=97
	_DESTINATION=${_COMMITS[2]}

	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	on_commit ${_COMMITS[2]} && return 0
	on_commit ${_COMMITS[1]} && return $_STILL_HERE
	on_commit ${_COMMITS[0]} && return $_TOO_FAR_FORWARD
	return $_TOO_FAR_BACK
}

go_back1_hint() {
	case $1 in
		$_TOO_FAR_BACK)
			cat <<-MSG
			You went too far back!

			Let me help you out.

			Run $(cmd git checkout $_DESTINATION) to arrive when you need to be.
			Add the $(cmd -f) flag if you need to discard any chagnes on your way.
			MSG
			;;

		$_STILL_HERE)
			cat <<-MSG
			Run $(cmd git checkout HEAD~) to go back one commit.

			MSG
			;;

		$_TOO_FAR_FORWARD)
			cat <<-MSG
			You went in the wrong direction!

			Let me help you out.

			Run $(cmd git checkout $_DESTINATION) to arrive when you need to be.
			Add the $(cmd -f) flag if you need to discard any chagnes on your way.
			MSG
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;
	esac
}




git_diff1_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[2]}
}

git_diff1_prologue() {
	cat <<-MSG
	What was changed between this commit and the one you just left?

	Note the commit ID that was reported when you checked this commit out:

	  Previous HEAD position was ${_COMMITS[1]} ...

	Give this commit ID to $(cmd git diff) to see what was changed
	MSG
}

git_diff1_test() {
	_tutr_generic_test -c git -a diff -a "${_COMMITS[1]}|@\{-1}" -d "$_REPO_PATH"
}

git_diff1_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;

		$WRONG_CMD|$WRONG_ARGS|$TOO_FEW_ARGS|$TOO_MANY_ARGS)
			cat <<-MSG
			Run $(cmd git diff ${_COMMITS[1]}) to see what was changed in this repo's latest commit.
			MSG
			;;
	esac
}




git_show0_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[2]}
}

git_show0_prologue() {
	cat <<-MSG
	Keeping track of commit IDs is a hassle.  If you want to know what the
	current commit accomplished, do you need to go back to its parent and run
	a complex $(cmd git diff) command?

	It seems like there should be an easier way to see what change this commit
	introduced.

	MSG
	_tutr_pressenter

	cat <<-MSG

	The command you are looking for is $(cmd git show).  It displays the commit ID,
	author, commit date, and the commit message.  After that are the code
	changes, following the same $(red_ red) and $(grn_ green) convention as $(cmd git diff).

	You may need to press $(kbd q) to return to the shell.

	Run this command now to see what changes this commit introduced.
	MSG
}

git_show0_test() {
	_tutr_generic_test -c git -a show -d "$_REPO_PATH"
}

git_show0_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"
	cat <<-MSG

	Run $(cmd git show) to proceed
	MSG
}



tag_minutes_pre() {
	_HACKY_COMMIT=${_COMMITS[2]}
}

tag_minutes_ff() {
	git tag minutes $_HACKY_COMMIT
}

tag_minutes_rw() {
	git tag -d minutes
}

tag_minutes_prologue() {
	cat <<-MSG
	Before you move on to look at the next commit, you should tag this one
	so you can refer to it more easily than by its commit ID.

	Since this commit shows the time in minutes and seconds,
	tag it with the name $(ylw minutes)
	MSG
}

tag_minutes_test() {
	TAGGED_WRONG_COMMIT=99
	ON_WRONG_COMMIT=98
	TAG_DOESNT_EXIST=97
	TAG_NAME_SHA1=96

	if [[ "$PWD" != "$_REPO_PATH" ]]; then
		return $WRONG_PWD
	elif git tag --list | command grep -q $_HACKY_COMMIT; then
		return $TAG_NAME_SHA1
	fi

	# noop commands
	if _tutr_noop; then return $NOOP
	elif [[ ${_CMD[*]} == "git help"* ]]; then return $NOOP
	elif [[ ${_CMD[*]} == "git tag -d"* ]]; then return $NOOP
	elif [[ ${_CMD[*]} == "git log"* ]]; then return $NOOP
	fi

	TAG_ON_COMMIT=$(git rev-parse --short minutes 2> /dev/null)

	if [[ -z $TAG_ON_COMMIT ]]; then
		if [[ "$(git rev-parse --short HEAD)" != $_HACKY_COMMIT ]]; then
			return $ON_WRONG_COMMIT
		else
			return $TAG_DOESNT_EXIST
		fi
	elif [[ "$TAG_ON_COMMIT"* == "$_HACKY_COMMIT"* ]]; then
		return 0
	else
		return $TAGGED_WRONG_COMMIT
	fi
}

tag_minutes_hint() {
	case $1 in
		$NOOP)
			return
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			return
			;;

		$TAGGED_WRONG_COMMIT)
			cat <<-MSG
			That wasn't the right commit to tag $(ylw minutes).

			Delete the tag with $(cmd git tag -d minutes), and try again.
			MSG
			;;

		$ON_WRONG_COMMIT)
			cat <<-MSG
			You are on commit $(git rev-parse --short HEAD), but should be on $_HACKY_COMMIT

			Run $(cmd git checkout $_HACKY_COMMIT) to get back on track.
			MSG
			;;

		$TAG_DOESNT_EXIST)
			cat <<-MSG
			Tag the current commit with the name $(ylw minutes).
			This tag's name must be all lowercase.
			MSG
			;;

		$TAG_NAME_SHA1)
			cat <<-MSG
			You created a tag with the name $(ylw_ $_HACKY_COMMIT) instead of $(ylw minutes).

			Delete this tag by running
			  $(cmd git tag -d $_HACKY_COMMIT)

			and try again.
			MSG
			;;
	esac

	if (( _ATTEMPTS > 4 )); then
		cat <<-MSG

		Use this command to place the $(ylw minutes) tag on the right commit:
		  $(cmd git tag -f minutes $_HACKY_COMMIT)
		MSG
	fi
}




go_back2_ff() {
	git checkout -f ${_COMMITS[4]}
}

go_back2_rw() {
	git checkout -f ${_COMMITS[2]}
}

go_back2_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[2]}
}

go_back2_prologue() {
	cat <<-MSG
	With the $(ylw minutes) tag marking your place, go backward by three commits.

	You can do this in one shot by giving $(cyn HEAD~3) as the destination to
	$(cmd git checkout).  You can, in fact, specify an arbitrary number of
	generations to travel backward by writing that number after $(cyn HEAD~).
	($(cyn HEAD~1), of course, is a synonym for $(cyn HEAD~)).
	MSG
}

go_back2_test() {
	_STILL_HERE=99
	_TOO_FAR_BACK=98
	_TOO_FAR_FORWARD=97
	_ONE_MORE_TO_GO=96
	_TWO_MORE_TO_GO=95
	_DESTINATION=${_COMMITS[5]}

	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	on_commit ${_COMMITS[5]} && return 0
	on_commit ${_COMMITS[4]} && return $_ONE_MORE_TO_GO
	on_commit ${_COMMITS[3]} && return $_TWO_MORE_TO_GO
	on_commit ${_COMMITS[2]} && return $_STILL_HERE
	on_commit ${_COMMITS[1]} && return $_TOO_FAR_FORWARD
	on_commit ${_COMMITS[0]} && return $_TOO_FAR_FORWARD
	return $_TOO_FAR_BACK
}

go_back2_hint() {
	case $1 in
		$_TOO_FAR_BACK)
			cat <<-MSG
			You went too far back!

			Let me help you out.

			Run $(cmd git checkout $_DESTINATION) to arrive when you need to be.
			Add the $(cmd -f) flag if you need to discard any chagnes on your way.
			MSG
			;;

		$_STILL_HERE)
			cat <<-MSG
			Run $(cmd git checkout HEAD~3) to go back by three commits.

			MSG
			;;

		$_TOO_FAR_FORWARD)
			cat <<-MSG
			You went in the wrong direction!

			Let me help you out.

			Run $(cmd git checkout $_DESTINATION) to arrive when you need to be.
			Add the $(cmd -f) flag if you need to discard any chagnes on your way.
			MSG
			;;

		$_TWO_MORE_TO_GO)
			cat <<-MSG
			You went back by only one commit.

			From here you must go to commit $(cyn HEAD~2)
			MSG
			;;

		$_ONE_MORE_TO_GO)
			cat <<-MSG
			You went back by two commits.  That means you are almost there!

			From here you only need to go back to the commit $(cyn HEAD~)
			MSG
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;
	esac
}



git_diff2_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

git_diff2_prologue() {
	cat <<-MSG
	Use $(cmd git diff) to see how much this commit differs from the commit you
	just tagged.
	MSG
}

git_diff2_test() {
	_tutr_generic_test -c git -a diff -a "minutes|${_COMMITS[2]}.*|@\{-1}" -d "$_REPO_PATH"
}

git_diff2_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;

		*)
			if (( _ATTEMPTS > 3 )); then
				cat <<-MSG
				Run $(cmd git diff minutes) to see what was changed since the commit you
				tagged with the name $(ylw minutes).
				MSG
			else
				git_diff2_prologue
			fi
			;;
	esac
}

git_diff2_epilogue() {
	cat <<-MSG
	As a reminder, the colors in $(cmd git diff)'s output show how one could edit
	the currently checked out code to make it be the same as the commit named
	on the command line.

	* $(red_ Red) text needs to be erased in $(ylw minutes) to make it match this version
	* $(grn_ Green) is text that must be added

	MSG

	_tutr_pressenter

	cat <<-MSG

	That shows how the repository had changed in the three commits leading up
	to the commit you tagged $(ylw minutes).  In other words, the $(red_ red) and $(grn_ green)
	changes are what the original programmer did after they committed the
	code you have just checked out.

	MSG
	_tutr_pressenter
}



git_show1_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

git_show1_prologue() {
	cat <<-MSG
	Now, run the command that shows what changes were brought about by the
	currently checked out commit.
	MSG
}

git_show1_test() {
_tutr_generic_test -c git -a show -d "$_REPO_PATH"
}

git_show1_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"

	if (( _ATTEMPTS > 4 )); then
		cat <<-MSG

		Run $(cmd git show) to proceed
		MSG
	fi
}




run3_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

run3_prologue() {
	cat <<-MSG
	Given what you can see in the code, can you guess what the program
	does at this point in time?

	Run $(_py pomodoro.py) to test your understanding of the code.
	MSG
}

run3_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run3_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd $_PY pomodoro.py)
	MSG
}

run3_epilogue() {
	cat <<-MSG
	This version of $(_py pomodoro.py) counts seconds and prints its output one
	line at a time.

	It was in the next commit that the \\r trick was introduced so that new
	output lines overwrite the old ones so the screen doesn't fill up.

	MSG
	_tutr_pressenter
}



git_log0_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

git_log0_prologue() {
	cat <<-MSG
	Take another look at the $(_Git) log to get a sense of where you are.
	MSG
}

git_log0_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then
		return $NOOP
	else
		_tutr_generic_test -c git -a log -d "$_REPO_PATH"
	fi
}

git_log0_hint() {
	[[ $1 == $NOOP ]] && return

	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Review the commit history with $(cmd git log).
	MSG
}

git_log0_epilogue() {
	cat <<-MSG
	That's strange... why are there only three commits?

	Where are the commits that that you just visited?
	Did the repository lose those changes?

	MSG
	_tutr_pressenter
}



git_log1_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

git_log1_prologue() {
	cat <<-MSG
	Don't worry, no commits have been lost!

	You cannot see the earlier commits due to the way commits in Git are
	connected to each other.  Connections between commits in Git are
	unidirectional; a commit can know who its immediate ancestors are, but
	not its children.

	This means that looking back to the past is simple: just follow the
	link to a commit's parent, then to that commit's parent, all the way
	back to the beginning.

	MSG

	_tutr_pressenter

	cat <<-MSG

	It is not possible to traverse in the opposite direction.  When you run
	$(cmd git log) without an argument, it starts from the current commit and
	looks backward.

	If you want to see what happened after a certain point, you will need to
	obtain the name of a commit.  The latest commit in this repository is
	named $(_master).  So, to view the log starting from that commit, run
	$(cmd git log master)
	MSG
}

git_log1_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then
		return $NOOP
	else
		_tutr_generic_test -c git -a log -a master -d "$_REPO_PATH"
	fi
}

git_log1_hint() {
	[[ $1 == $NOOP ]] && return

	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Review the commit history starting from the $(_master) commit with
	$(cmd git log master).
	MSG
}



git_checkout_master_ff() {
	git checkout -f ${_COMMITS[0]}
}

git_checkout_master_rw() {
	git checkout -f ${_COMMITS[4]}
}

git_checkout_master_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[5]}
}

git_checkout_master_prologue() {
	cat <<-MSG
	To bring this lesson full-circle, use $(cmd git checkout) to return to
	$(_master), which is where you started.
	MSG
}

git_checkout_master_test() {
	_STILL_HERE=99
	_TOO_FAR_BACK=98
	_ONE_MORE_TO_GO=96
	_DESTINATION=${_COMMITS[0]}

	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	on_commit ${_COMMITS[0]} && return 0
	on_commit ${_COMMITS[1]} && return $_ONE_MORE_TO_GO
	on_commit ${_COMMITS[4]} && return $_STILL_HERE
	return $_TOO_FAR_BACK
}

git_checkout_master_hint() {
	case $1 in
		$_TOO_FAR_BACK)
			cat <<-MSG
			You are not quite back to the future.
			MSG
			;;

		$_STILL_HERE)
			cat <<-MSG
			You're still here?
			MSG
			;;

		$_ONE_MORE_TO_GO)
			cat <<-MSG
			You are really close!
			MSG
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			return
			;;
	esac
	if (( _ATTEMPTS > 3 )); then
		cat <<-MSG

		Let me help you out.

		Run $(cmd git checkout master) to go back to the start.
		Add the $(cmd -f) flag if you need to discard any changes on your way.
		MSG
	fi
}

git_checkout_master_epilogue() {
	cat <<-MSG
	It's good to be back!

	MSG
	_tutr_pressenter
}



run4_pre() {
	must_be_in_repo && must_be_on_commit ${_COMMITS[0]}
}

run4_prologue() {
	cat <<-MSG
	Just to make sure everything is truly back to normal, run $(_py pomodoro.py)
	one last time.
	MSG
}

run4_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run4_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd $_PY pomodoro.py)
	MSG
}

run4_epilogue() {
	cat <<-MSG
	$(_Git) has a mind like a steel trap.  It is pretty incredible to think
	that your entire journey took place inside this directory!

	MSG
	_tutr_pressenter
}




epilogue() {
	cat <<-EPILOGUE
	${_C}  _____                        __       __     __  _
	${_C} / ___/__  ___  ___ ________ _/ /___ __/ /__ _/ /_(_)__  ___  ___
	${_C}/ /__/ _ \\/ _ \\/ _ \`/ __/ _ \`/ __/ // / / _ \`/ __/ / _ \\/ _ \\(_-<
	${_C}\\___/\\___/_//_/\\_, /_/  \\_,_/\\__/\\_,_/_/\\_,_/\\__/_/\\___/_//_/___/
	${_C}              /___/

	${_Y}        _____          ${_Z}
	${_Y}     _.'_____\`._       ${_Z}
	${_Y}   .'.-'  12 \`-.\`.     ${_Z}
	${_Y}  /,' 11      1 \`.\\    ${_Z}  You've got this time-travel thing down
	${_Y} // 10      /   2 \\\\   ${_Z}  pat!  I hope that you will be able to
	${_Y};;         /       ::  ${_Z}  find good uses for this skill in your
	${_Y}|| 9  ----O      3 ||  ${_Z}  own projects.
	${_Y}::                 ;;  ${_Z}
	${_Y} \\\\ 8           4 //   ${_Z}  The next lesson will build on these
	${_Y}  \\\`. 7       5 ,'/    ${_Z}  concepts and give you more practice
	${_Y}   '.\`-.__6__.-'.'     ${_Z}  checking out different points of the
	${_Y}    ((-._____.-))      ${_Z}  $(_Git) timeline.
	${_Y}    _))       ((_      ${_Z}
	${_Y}   '--'SSt    '--'     ${_Z}


	EPILOGUE
	_tutr_pressenter
}


cleanup() {
	cat <<-:

	$(_tutr_progress)

	You worked on this lesson for $(_tutr_pretty_time)
	:

	if (( $1 == $_COMPLETE )); then
		echo Run $(cmd ./tutorial.sh) to start the next lesson
	else
		echo Run $(cmd ./tutorial.sh) to retry this lesson
	fi
	echo
}


# If the pomodoro repository is missing, add some extra steps
# to clone it.
_CLONE_POMODORO=()
if [[ ! -d "$_REPO_PATH/.git" ]]; then
	_CLONE_POMODORO+=(cd_dotdot clone_repository)
else
	_POMODORO_PRESENT=1
fi


source main.sh && _tutr_begin \
	${_CLONE_POMODORO[@]} \
	cd_into_repo \
	inspect_repo_ls \
	inspect_readme \
	inspect_repo_log \
	run0 \
	edit_pomodoro0 \
	run1 \
	go_back0 \
	go_back_with_force \
	run2 \
	git_diff0 \
	go_back1 \
	git_diff1 \
	git_show0 \
	tag_minutes \
	go_back2 \
	git_diff2 \
	git_show1 \
	run3 \
	git_log0 \
	git_log1 \
	git_checkout_master \
	run4


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=0 colorcolumn=76:
