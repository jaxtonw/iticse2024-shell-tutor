#!/bin/sh

# TODO: Add steps to delete the topic branches after they have been merged
#       into master.
# TODO: Forcibly delete the unmerged 'figlet' branch at the end of the
#       tutoial.

. .lib/shell-compat-test.sh

_DURATION=25

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

_REPO_NAME=pomodoro
_REPO_URL_SSH=git@gitlab.cs.usu.edu:duckiecorp/$_REPO_NAME
_SUGGESTED_REMOTE_REPO_NAME=$_REPO_NAME

Pomodoro() { (( $# == 0 )) && echo $(red Pomodoro) || echo $(red $*); }
_Git() { (( $# == 0 )) && echo $(blu Git) || echo $(blu $*); }
_master() { (( $# == 0 )) && echo $(grn master) || echo $(grn $*); }
_colors() { (( $# == 0 )) && echo $(grn colors) || echo $(grn $*); }
_bar() { (( $# == 0 )) && echo $(grn bar) || echo $(grn $*); }
_figlet() { (( $# == 0 )) && echo $(grn figlet) || echo $(grn $*); }


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


# Generic TEST function for steps where the user must check out a branch
_checkout_BRANCH_test() {
	[[ -n $DEBUG ]] && set -x
	local branch=$1
	_STILL_ON_MASTER=99
	_WRONG_BRANCH=98
	_USE_FORCE=97
	_CREATED_BRANCH=96
	_DETACHED_HEAD=95

	[[ "$PWD" != "$_REPO_PATH" ]] && return $WRONG_PWD
	_tutr_on_tracking_branch origin $branch && return 0

	if _tutr_on_branch $branch; then
		return $_CREATED_BRANCH
	elif _tutr_detached_head; then
		return $_DETACHED_HEAD
	elif [[ ${_CMD[@]} =~ "git (checkout|switch) $branch" ]] && _tutr_dir_changed "$_REPO_PATH"; then
		return $_USE_FORCE
	elif _tutr_on_tracking_branch origin master; then
		return $_STILL_ON_MASTER
	else
		return $_WRONG_BRANCH
	fi
}

# Generic HINT function for steps where the user must check out a branch
_checkout_BRANCH_hint() {
	local branch=$2
	case $1 in
		$_STILL_ON_MASTER)
			if (( _ATTEMPTS < 3 )); then
				cat <<-MSG
				Still here?

				Check out the $(bld $branch) branch to proceed.
				MSG
			else
				cat <<-MSG
				Run $(cmd git checkout $branch) to get your repository onto the $(bld $branch) branch
				MSG
			fi
			;;

		$_USE_FORCE)
			cat <<-MSG
			$(cmd git ${_CMD[1]}) refuses to work because doing so will undo the changes you
			have made to the files here.

			$(_Git) is all about preserving work, after all.

			However, we really must be going.  You can use $(cmd git restore :/) to discard
			any changes in this repository before checking out the $(bld $branch) branch, or you
			may run $(cmd git ${_CMD[1]} --force $branch) to $(bld forcibly) check it out.
			MSG
			;;

		$_WRONG_BRANCH)
			if (( _ATTEMPTS < 2 )); then
				cat <<-MSG
				You need to be on the $(bld $branch) branch!
				MSG
			else
				cat <<-MSG
				Run $(cmd git checkout $branch) to get your repository onto the '$branch' branch
				MSG
			fi
			;;

		$_CREATED_BRANCH)
			cat <<-MSG
			You created a local branch named $branch.  This is not quite what I
			asked you to do, so you'll have to try again.  First, I will clean this
			branch up and put you back on $(_master)...

			MSG

			git checkout master
			git branch --delete --force $branch

			cat <<-MSG

			Run $(cmd git checkout $branch) to get your repository onto the '$branch' branch
			MSG
			;;

		$_DETACHED_HEAD)
			cat <<-MSG
			${_y}   _______
			${_y}  |.--+--.|
			${_y}  ||  |  ||
			${_y}  ||${_c}--\`--${_y}||
			${_y}  ||${_c}    ,${_y}||     ${_Z}  You put the repo into detached HEAD mode
			${_y}  ||${_c}  ,' ${_y}||     ${_Z}  with that one.  Are you in the mood for a
			${_y}  ||${_c},'   ${_y}||     ${_Z}  revolution or something?
			${_y}  ||     ||
			${_y}  ||_____||${_w}__
			${_y}  |${_w} ___.  ${_y}|${_w}  \`. ${_Z}  Well, let's not lose our heads over it.
			${_y}  |${_w}(${_B}o o${_w})) ${_y}|${_w}  ,(
			${_y}  |${_w}\`.-,'  |${_w}-'_ )${_Z}
			${_y}  |______ |${_w}\\' -'${_Z}  Re-attach $(cyn HEAD) with $(cmd git checkout $branch).
			${_w} _${_y}\\     /${_w}_) )
			${_w}'"\`${_y}\\___/${_w}/_)'
			${_w}       ''^
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			;;
	esac
	[[ -n $DEBUG ]] && set +x
}


# Generic TEST function for steps running 'git log' on a specific branch
_git_log_BRANCH_test() {
	[[ -n $DEBUG ]] && set -x
	local branch=$1
	_WRONG_BRANCH=99

	if   [[ "$PWD" != "$_REPO_PATH" ]]; then return $WRONG_PWD
	elif ! _tutr_on_tracking_branch origin $branch; then return $_WRONG_BRANCH
	else _tutr_generic_test -c git -a log -d "$_REPO_PATH"
	fi
}

# Generic HINT function for steps running 'git log' on a specific branch
_git_log_BRANCH_hint() {
	local branch=$2

	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO_PATH"
			;;

		$_WRONG_BRANCH)
			cat <<-MSG
			You need to be on the $(bld $branch) branch!
			Use $(cmd git checkout $branch) to go there.

			If this command doesn't work, try the stronger version:
			  $(cmd git checkout $branch)
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			;;
	esac

 	[[ -n $DEBUG ]] && set +x
}


setup() {
	export _ORIG_PWD="$PWD"
	export _PARENT="$(cd .. && pwd)"
	export _REPO_PATH="$_PARENT/$_REPO_NAME"

	source screen-size.sh 80 30

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh
	_tutr_assert_program_exists git

	source ssh-connection-test.sh
	# _tutr_assert_ssh_connection_is_okay  # UNCOMMENT ME

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
			[[ $tag = minutes ]] && continue
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

	Shell Lesson #1: Git Branching

	In this lesson you will learn how to use Git to

	* See which branches exist locally and remotely
	* Navigate between branches
	* Merge branches

	This lesson takes around $_DURATION minutes.

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
	Hey!

	There used to be a repository called $(path pomodoro) up in the
	parent directory!

	You didn't lose it, did you?  It was kinda important.

	MSG

	_tutr_pressenter

	cat <<-MSG

	Well, you'll just have to go and get it again.

	$(cmd cd) up a directory so you can clone it back down.
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

clone_repository_prologue() {
	cat <<-MSG
	Now that you're here, go ahead and $(cmd git clone $_REPO_URL_SSH)
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




list_branches_pre() {
	must_be_in_repo
}

list_branches_prologue() {
	cat <<-MSG
	$(_Git) is famous for its branches.  That is what its logo represents.

	Now, $(_Git) isn't the only version control system that has branches, nor
	was it the first to have them.  But, it was one of the first to make
	branches effective.

	You will use the $(cmd git branch) command to investigate the branches
	in this repo.  There are $(bld four) branches in this repo.  Run $(cmd git branch) to
	see their names.
	MSG
}

list_branches_test() {
	_tutr_generic_test -c git -a branch -d "$_REPO_PATH"
}

list_branches_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"
}

list_branches_epilogue() {
	cat <<-MSG
	Well, that was underwhelming!

	MSG
	_tutr_pressenter
}




list_all_branches_pre() {
	must_be_in_repo
}

list_all_branches_prologue() {
	cat <<-MSG
	I wasn't lying when I said that there are four branches.  I just kinda
	left out the part about them being $(bld remote) branches.

	By default, $(cmd git branch) only shows $(bld local) branches.

	The distinction between local and remote branches is artificial.  When
	you clone a repository from the server onto this computer, you obtain
	all of the commits in every branch the server is aware of.  Those
	branches stay in the background until you ask for them.

	When a branch is checked out on this computer it becomes "$(bld local)"
	Until then, it is called a "$(bld remote-tracking branch)".

	MSG

	_tutr_pressenter

	cat <<-MSG

	It is still possible to list $(bld all) kinds of branches with $(cmd git branch).
	You just need to give it another option.  Use $(cmd git help branch) to look
	for that option in the manual.  When you find it, use it to to proceed.
	MSG
}

list_all_branches_test() {
	[[ -n $ZSH_NAME ]] && setopt LOCAL_OPTIONS NO_RE_MATCH_PCRE
	_READ_MANUAL=99
	_LIST=98
	_REMOTES=97

	if   _tutr_noop; then return $NOOP
	elif [[ "$PWD" != "$_REPO_PATH" ]]; then return $WRONG_PWD
	elif [[ "${_CMD[@]}" == "git help branch" ]]; then return $_READ_MANUAL
	elif [[ ${_CMD[0]} == git && ${_CMD[1]} == branch ]]; then
		[[ (${_CMD[2]} == -a || ${_CMD[2]} == --all) && (${_CMD[3]} == -l || ${_CMD[3]} == --list) ]] && return 0
		[[ (${_CMD[2]} == -l || ${_CMD[2]} == --list) && (${_CMD[3]} == -a || ${_CMD[3]} == --all) ]] && return 0
		[[ ${_CMD[2]} == -la || ${_CMD[2]} == -al ]] && return 0
		[[ (${_CMD[2]} == -a || ${_CMD[2]} == --all) && (${_CMD[3]} == -r || ${_CMD[3]} == --remotes) ]] && return $_REMOTES
		[[ ${_CMD[2]} == -r  || ${_CMD[2]} == --remotes ]] && return $_REMOTES
		[[ ${_CMD[2]} == -ra || ${_CMD[2]} == -ar ]] && return $_REMOTES
		[[ ${_CMD[2]} == -l  || ${_CMD[2]} == --list ]] && return $_LIST
	fi
	_tutr_generic_test -c git -a branch -a "-a|--all" -d "$_REPO_PATH"
}

list_all_branches_hint() {
	case $1 in
		$_NOOP) ;;
		$_READ_MANUAL)
			cat <<-MSG
			Did you find the option you're looking for?  Try it now!
			MSG
			;;
		$_LIST)
			cat <<-MSG
			The $(cmd --list) (or $(cmd -l)) option is $(bld part) of the solution.

			You must combine it with another option that will show you $(bld all) of
			the branches in this repository.
			MSG
			;;
		$_REMOTES)
			cat <<-MSG
			The $(cmd --remotes) (or $(cmd -r)) option is $(bld close); but it doesn't show quite enough.

			Look for another option that shows $(bld all) branches in this repository.
			MSG
			;;
		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			;;
	esac
}

list_all_branches_epilogue() {
	_tutr_pressenter
	cat <<-MSG

	The current branch, $(_master), is shown in $(grn_ green) and has a $(bld '*') in front of
	its name.  Remote branches have $(red_ red) names beginning with $(red_ remotes/origin).

	You can access these branches with $(cmd git checkout).  When you do, a local
	branch with the same name is created.  When you check them out, do not
	refer to them by their $(bld full name) (i.e. $(red_ remotes/origin/colors)).  The last
	component (e.g. $(red_ colors)) is sufficient (e.g. $(cmd git checkout colors)).

	MSG
	_tutr_pressenter
}



checkout_colors_ff() {
	git checkout --force colors
}

checkout_colors_rw() {
	git checkout --force master
	git branch --delete --force colors
}

checkout_colors_pre() {
	must_be_in_repo
}

checkout_colors_prologue() {
	cat <<-MSG
	Check out the $(_colors) branch
	MSG
}

checkout_colors_test() {
	_checkout_BRANCH_test colors
}

checkout_colors_hint() {
	_checkout_BRANCH_hint $1 colors
}



log_colors0_pre() {
	must_be_in_repo
}

log_colors0_prologue() {
	cat <<-MSG
	Now that you're here, have a look at the $(_Git) log.
	MSG
}

log_colors0_test() {
	_git_log_BRANCH_test colors
}

log_colors0_hint() {
	_git_log_BRANCH_hint $1 colors
}

log_colors0_epilogue() {
	cat <<-MSG
	There is one commit in this branch past the end of the $(_master) branch.

	The commit message gives the impression that this version of the program
	is more colorful.

	MSG
	_tutr_pressenter
}




run_colors_pre() {
	must_be_in_repo
}

run_colors_prologue() {
	cat <<-MSG
	Run $(_py pomodoro.py) to see what a colorful version of this program looks like.
	MSG
}

run_colors_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run_colors_hint() {
	if [[ $1 == $WRONG_CMD ]]; then
		if (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Run the $(_py pomodoro.py) program to see what a colorful version looks like.
			MSG
		else
			cat <<-MSG
			Run $(cmd $_PY pomodoro.py) to proceed.
			MSG
		fi
	else
		_tutr_generic_hint $1 $_PY "$_REPO_PATH"
	fi
}




checkout_bar_ff() {
	git checkout --force bar
}

checkout_bar_rw() {
	git checkout --force colors
	git branch --delete --force bar
}

checkout_bar_pre() {
	must_be_in_repo
}

checkout_bar_prologue() {
	cat <<-MSG
	There was a branch in the listing called $(_bar).  Check it out next.
	MSG
}

checkout_bar_test() {
	_checkout_BRANCH_test bar
}

checkout_bar_hint() {
	_checkout_BRANCH_hint $1 bar
}





log_bar0_pre() {
	must_be_in_repo
}

log_bar0_prologue() {
	cat <<-MSG
	Now see what the log looks like from this branch.
	MSG
}

log_bar0_test() {
	_git_log_BRANCH_test bar
}

log_bar0_hint() {
	_git_log_BRANCH_hint $1 bar
}

log_bar0_epilogue() {
	cat <<-MSG
	Once again, this branch has one commit that is not in the $(_master) branch.

	This version of the timer should have an animated progress bar.

	MSG
	_tutr_pressenter
}



run_bar_pre() {
	must_be_in_repo
}

run_bar_prologue() {
	cat <<-MSG
	There's only one way to find out if the progress bar is all it's
	cracked up to be.
	MSG
}

run_bar_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run_bar_hint() {
	if [[ $1 == $WRONG_CMD ]]; then
		if (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Run $(_py pomodoro.py) to see that progress bar.
			MSG
		else
			cat <<-MSG
			Run $(cmd $_PY pomodoro.py) to proceed.
			MSG
		fi
	else
		_tutr_generic_hint $1 $_PY "$_REPO_PATH"
	fi
}

run_bar_epilogue() {
	cat <<-MSG
	I really like that!  How about you?

	MSG
	_tutr_pressenter
}



checkout_figlet_ff() {
	git checkout --force figlet
}

checkout_figlet_rw() {
	git checkout --force bar
	git branch --delete --force figlet
}

checkout_figlet_pre() {
	must_be_in_repo
}

checkout_figlet_prologue() {
	cat <<-MSG
	Check out the $(bld figlet) branch
	MSG
}

checkout_figlet_test() {
	_checkout_BRANCH_test figlet
}

checkout_figlet_hint() {
	_checkout_BRANCH_hint $1 figlet
}




log_figlet0_pre() {
	must_be_in_repo
}

log_figlet0_prologue() {
	cat <<-MSG
	Now that you're here, have a look at the $(_Git) log.
	MSG
}

log_figlet0_test() {
	_git_log_BRANCH_test figlet
}

log_figlet0_hint() {
	_git_log_BRANCH_hint $1 figlet
}

log_figlet0_epilogue() {
	cat <<-MSG
	This time there are two new commits since the $(_master) branch.

	MSG
	_tutr_pressenter
}




run_figlet_pre() {
	must_be_in_repo
}

run_figlet_prologue() {
	cat <<-MSG
	I wonder what $(bld figlet) means?

	Better run $(_py pomodoro.py) to find out.
	MSG
}

run_figlet_test() {
	_tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
}

run_figlet_hint() {
	if [[ $1 == $WRONG_CMD ]]; then
		if (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Run $(_py pomodoro.py) to see what's up with $(bld figlet).
			MSG
		else
			cat <<-MSG
			Run $(cmd $_PY pomodoro.py) to proceed.
			MSG
		fi
	else
		_tutr_generic_hint $1 $_PY "$_REPO_PATH"
	fi
}

run_figlet_epilogue() {
	cat <<-MSG
	This version of the program uses $(bld BIG) digits made with $(bld FIGlet).

	FIGlet stands for Frank, Ian & Glenn's Letters.  It is a program that
	creates large characters out of ordinary screen characters
	 _ _ _          _   _     _
	| (_) | _____  | |_| |__ (_)___
	| | | |/ / _ \\ | __| '_ \\| / __|
	| | |   <  __/ | |_| | | | \\__ \\_
	|_|_|_|\\_\\___|  \\__|_| |_|_|___(_)

	(If you care, FIGlet has a webpage: $(unl http://www.figlet.org/))

	MSG
	_tutr_pressenter
}



checkout_master_ff() {
	git checkout --force master
}

checkout_master_rw() {
	git checkout --force figlet
}

checkout_master_pre() {
	must_be_in_repo
}

checkout_master_prologue() {
	cat <<-MSG
	You've now seen all of the branches.

	Let's complete the circuit and go back to $(_master).
	MSG
}

checkout_master_test() {
	_checkout_BRANCH_test master
}

checkout_master_hint() {
	_checkout_BRANCH_hint $1 master
}





show_branch0_pre() {
	must_be_in_repo
}

show_branch0_prologue() {
	cat <<-MSG
	From here, $(cmd git log) will not show any of the newer commits that
	belong to the other branches.  There is a command that will show all
	of the branches at once.

	It is called $(cmd git show-branch).  Try it now.
	MSG
}

show_branch0_test() {
	_tutr_generic_test -c git -a show-branch -d "$_REPO_PATH"
}

show_branch0_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd git show-branch) to proceed.
	MSG
}

show_branch0_epilogue() {
	_tutr_pressenter
	cat <<-MSG

	There is a lot of information in this command's output, but it is not
	very intuitive.  Here's what that blob of text means:

	* The top part above the '-----' line names the local branches with a
	  symbol that introduces the color and column commits belonging to that
	  occupy in the diagram below.  Most branches are signified with $(bld '!'),
	  and the $(bld '*') symbol beside $(_master) indicates that this is the
	  currently checked-out branch.
	* The bottom diagram shows which commits belong to which branches.
	  A $(bld '+') or $(bld '*') in a branch's column show that commit is a part of that
	  particular branch.
	* The bottom-most line has a symbol in every branch's column.
	  This commit is the common ancestor of all branches.

	MSG

	_tutr_pressenter

	cat <<-MSG

	There are other commits that could be shown beneath this last line,
	but because they are all common ancestors of the local branches they
	are omitted.

	MSG
	_tutr_pressenter
}



merge_colors_ff() {
	git merge colors
}

merge_colors_rw() {
	git checkout master
	git reset --hard origin/master
}

merge_colors_pre() {
	must_be_in_repo
}

merge_colors_prologue() {
	cat <<-MSG
	You might be wondering what purpose separate branches could possibly
	serve.  There are three alternate versions of the $(Pomodoro) timer, but
	only one of them can be used at a time.  These versions are isolated
	from each other, can only be accessed singly, and only by running a
	special $(_Git) command.  Branches don't seem to be very convenient.

	It is true that branches isolate code; they enable developers to work on
	specific features without interference from other teammates who are
	working on the program at the same time.  They also let developers
	safely take a risky approach to solving a problem.  If it doesn't work
	out, the branch can be discarded, and the code reset to its state before
	the experiment.

	But what really redeems branches as a feature is the capability to join
	them together through an operation known as a $(bld merge).  This is how the
	results of a successful experiment are reintegrated into the main code
	base.

	MSG

	_tutr_pressenter

	cat <<-MSG

	A merge is achieved with the $(cmd git merge BRANCH_NAME) command.
	After running the merge, new commits from $(cmd BRANCH_NAME) become a part of
	the currently checked-out branch.

	Right now you are on the $(_master) branch, and there is one new commit on
	the $(_colors) branch.  Running $(cmd git merge colors) will "merge" that colorful
	change into the $(_master) branch, bringing that experiment to a successful
	conclusion.

	Run $(cmd git merge colors) now.
	MSG
}

merge_colors_test() {
	if   git merge-base --is-ancestor colors master; then return 0
	else _tutr_generic_test -c git -a merge -a colors -d "$_REPO_PATH"
	fi
}

merge_colors_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd git merge colors) to proceed
	MSG
}



log_colors1_pre() {
	must_be_in_repo
}

log_colors1_prologue() {
	_tutr_pressenter
	cat <<-MSG

	Pay attention to the $(bld Fast-forward) message.  The commit that was named
	$(_colors) now belongs to the $(_master) branch, too.  Because $(_colors) was a
	direct descendent of the $(_master) branch, combining these branches into
	one is as simple as moving the branch name $(_master) onto the same commit.

	MSG

	_tutr_pressenter

	cat <<-MSG

	Take a look at the log to see what effect the merge had on this repo.
	You do not need to provide the name of a branch; just see what the log
	for $(bld this) branch looks like.
	MSG
}

log_colors1_test() {
	_WRONG_BRANCH=99
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	elif [[ ${_CMD[@]} == "git log" || ${_CMD[@]} == "git log master" ]]; then return 0
	elif [[ ${_CMD[@]} == "git log"* && ${_CMD[2]} != master ]]; then return $_WRONG_BRANCH
	else _tutr_generic_test -c git -a log -d "$_REPO_PATH"
	fi
}

log_colors1_hint() {
	case $1 in
		$_NOOP) return ;;

		$_WRONG_BRANCH)
			cat <<-MSG
			Don't look at another branch.

			You just need to run $(cmd git log).
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"

			if (( _ATTEMPTS > 3 )); then
				cat <<-MSG

				Take a look at the log to see what effect $(cmd git merge colors) had on this repo.

				You do not need to provide the name of a branch; just use $(cmd git log).
				MSG
			fi
			;;
	esac
}



show_branch1_pre() {
	must_be_in_repo
}

show_branch1_prologue() {
	cat <<-MSG
	As you can see, the names $(_master) and $(_colors) are on the same commit.

	MSG
	_tutr_pressenter
	cat <<-MSG

	Let's look at this situation another way.

	Run $(cmd git show-branch) to visualize the relationship between commits in these
	branches.
	MSG
}

show_branch1_test() {
	_tutr_generic_test -c git -a show-branch -d "$_REPO_PATH"
}

show_branch1_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd git show-branch) to proceed.
	MSG
}

show_branch1_epilogue() {
	cat <<-MSG
	In the bottom part of this display you can clearly see that this commit
	is now the tip of both the $(_colors) and $(_master) branches.  The $(bld '*') reminds
	you that $(_master) is the currently checked-out branch, but at this point
	in the project both $(_colors) and $(_master) contain the same commits.

	MSG
	_tutr_pressenter
}





show_branch_more_pre() {
	must_be_in_repo
}

show_branch_more_prologue() {
	cat <<-MSG
	By default, the output of $(cmd git show-branch) stops on a commit that is
	the common ancestor to every branch.  As you might imagine, the output
	of this command can become overwhelming in repositories with a long
	history and many branches.

	But, taking a step back can help you comprehend the structure of the
	repository.  You can give the $(cmd --more=N) option to extend the reach by
	$(cmd N) commits past the most recent common ancestor.  Don't literally type
	$(cmd --more=N); it stands for any $(bld non-negative integer).

	Try this now.  Run $(cmd git show-branch --more=N) with a large value of $(cmd N).
	MSG
}

show_branch_more_test() {
	_NEGATIVE=99
	_NEED_NUMBER=98
	_EQUIVALENT=97
	_ADD_MORE=96
	_TOO_SMALL=95
	_NEED_EQUAL=94

	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=-[0-9]+" ]]; then return $_NEGATIVE
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=[Nn]" ]]; then return $_NEED_NUMBER
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=$" ]]; then return $_NEED_NUMBER
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=0$" ]]; then return $_EQUIVALENT
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=[12]$" ]]; then return $_TOO_SMALL
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more$" ]]; then return $_TOO_SMALL
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more " ]]; then return $_NEED_EQUAL
	elif [[ ${_CMD[@]} =~ "git +show-branch +--more=[0-9]+$" ]]; then return 0
	elif [[ ${_CMD[@]} =~ "git +show-branch" ]]; then return $_ADD_MORE
	else _tutr_generic_test -c git -a show-branch -a "--more=[0-9]+" -d "$_REPO_PATH"
	fi
}

show_branch_more_hint() {
	case $1 in
		$NOOP)
			return ;;

		$_NEGATIVE)
			cat <<-MSG
			That was clever to try a negative value for $(cmd N).  As you can see, this
			results in less output than before!  Only the top half of the report
			is displayed.  Go ahead and try a bigger number, like this:

			$(cmd git show-branch --more=10)
			MSG
			;;

		$_NEED_NUMBER)
			cat <<-MSG
			$(cmd N) stands for a non-negative integer.
			You must supply a number after the $(cmd =), like this:

			$(cmd git show-branch --more=10)
			MSG
			;;

		$_EQUIVALENT)
			cat <<-MSG
			A value of $(cmd 0) means the same thing as leaving off the $(cmd "--more") option.
			Go ahead and try a bigger number, like this:

			$(cmd git show-branch --more=10)
			MSG
			;;

		$_ADD_MORE)
			cat <<-MSG
			Try again, but with the $(cmd "--more") option:

			$(cmd git show-branch --more=10)
			MSG
			;;

		$_TOO_SMALL)
			cat <<-MSG
			Well, that showed more history than before.  There is no penalty for
			trying a larger number.  Try running this:

			$(cmd git show-branch --more=10)
			MSG
			;;

		$_NEED_EQUAL)
			cat <<-MSG
			The syntax of this command requires that you put an $(bld =) between $(cmd "--more") and
			the number $(cmd N).  There are no spaces around $(bld =).  It will look like this:

			$(cmd git show-branch --more=10)
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			;;
	esac
}

show_branch_more_epilogue() {
	cat <<-MSG
	From this vantage point you can see $(bld everything) that has happened in
	the entire repository.  The wide band of four +'s and *'s represents the
	repo's common ancestry, and it is clear that the branches were made late
	in the project.

	MSG
	_tutr_pressenter
}



run_merged0_pre() {
	must_be_in_repo
}

run_merged0_prologue() {
	cat <<-MSG
	You've studied the commit history in great detail.  It should be obvious
	that $(_py pomodoro.py) will behave exactly the same now as when you
	last visited the $(_colors) branch.  Indeed, you are at the same commit as
	you were then; the only difference is that the $(_master) branch now
	includes this commit, too.

	Run $(_py pomodoro.py) to verify that this is the case.
	MSG
}

run_merged0_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	else _tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
	fi
}

run_merged0_hint() {
	if [[ $1 == $NOOP ]]; then return
	elif [[ $1 == $WRONG_CMD ]]; then
		if (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Run $(_py pomodoro.py) to verify that it still prints in color.
			MSG
		else
			cat <<-MSG
			Run $(cmd $_PY pomodoro.py) to verify that it still prints in color.
			MSG
		fi
	else
		_tutr_generic_hint $1 $_PY "$_REPO_PATH"
	fi
}




merge_bar_ff() {
	git merge bar --no-edit
}

merge_bar_rw() {
	git checkout master
	git reset --hard colors
}

merge_bar_pre() {
	must_be_in_repo
}

merge_bar_prologue() {
	cat <<-MSG
	That looks colorful to me!

	MSG

	_tutr_pressenter

	cat <<-MSG

	Merging is a simple matter when $(_Git) can just fast-forward a branch name
	to a later commit along the same timeline.  One could argue that this is
	hardly a merge at all.

	Now, we're going to ask $(_Git) to do something more intricate by merging a
	branch that is not a direct descendant of $(_colors).  This is a bigger
	deal and will create a new artifact on the commit history timeline that
	you can see in the log and in show-branch's output.

	MSG

	_tutr_pressenter

	cat <<-MSG

	The branch I want you to merge is $(_bar).  The end result will be a
	color-coded countdown with a diminishing status bar.  It might seem like
	magic that $(_Git) can masterfully combine these two codebases into a
	coherent program.  But there is no magic; the only reason this will work
	is because I carefully wrote these versions of the program in such a way
	that they can be automatically merged.

	It is often the case that when $(_Git) merges two or more branches together,
	the result is a conflict that must be manually resolved.  But we'll save
	that for another lesson.

	MSG

	_tutr_pressenter

	cat <<-MSG

	For now, all you need to do is run $(cmd git merge --no-edit bar).

	The new $(cmd --no-edit) option tells $(_Git) to not open an editor for the
	commit message.  Instead of supplying a message with the -m option, $(_Git)
	automatically generates a message for merges.  99% of the time,
	programmers approve of this message and roll with it, so there is no
	need for you to change it.

	Moreover, there is a good chance that the editor $(_Git) will choose is Vim.
	Unless you are used to Vim and know how to get out, there is no good
	reason for you to be subjected to it right now!

	But I'll leave that up to you.

	(If you ever find yourself trapped in Vim, just hit $(kbd Esc) a couple of
	times then type $(kbd :wq) followed by $(kbd Enter).)

	MSG
}

merge_bar_test() {
	# TODO: what if they try to merge branch 'figlet'?
	# .git/MERGE_HEAD = figlet's commit
	_WRONG_BRANCH=99
	_MERGE_IN_PROGRESS=98
	_MERGE_ABORTED=97

	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	elif [[ ${_CMD[@]} =~ "git merge --abort" ]]; then return $_MERGE_ABORTED
	elif [[ -f "$_REPO_PATH/.git/MERGE_HEAD" ]]; then
		if  [[ $(cat "$_REPO_PATH/.git/MERGE_HEAD") == $(git rev-parse figlet) ]]; then
			return $_WRONG_BRANCH
		else return $_MERGE_IN_PROGRESS
		fi
	elif git merge-base --is-ancestor bar master; then return 0
	else _tutr_generic_test -c git -a merge -a --no-edit -a bar -d "$_REPO_PATH"
	fi
}

merge_bar_hint() {
	case $1 in
		$NOOP)
			return
			;;

		$_MERGE_IN_PROGRESS)
			cat <<-MSG
			Well, do what the nice $(_Git) says.  Run $(cmd git commit --no-edit) to conclude
			the merge.  If this lands you in Vim, use $(kbd :wq) followed by $(kbd Enter)
			to save the commit message and quit.

			If you get this message repeatedly, contact $_EMAIL.
			MSG
			;;

		$_WRONG_BRANCH)
			cat <<-MSG
			Oops, I don't think that's what you meant to do.
			That merge failed and there is a conflict now.

			Run $(cmd git merge --abort) to undo this merge.
			Afterward, you can try again.

			If you get this message repeatedly, contact $_EMAIL.
			MSG
			;;

		$_MERGE_ABORTED)
			cat <<-MSG
			Now, run $(cmd git merge --no-edit bar) to proceed.
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			cat <<-MSG

			Run $(cmd git merge --no-edit bar) to proceed.
			MSG
			;;
	esac
}




log_bar1_pre() {
	must_be_in_repo
}

log_bar1_prologue() {
	cat <<-MSG
	I told you that the $(_Git) log will appear different now.  Look at it to
	see what effect $(cmd git merge bar) had on this repo.  You do not need to
	provide the name of a branch; plain old $(cmd git log) is good enough.
	MSG
}

log_bar1_test() {
	_WRONG_BRANCH=99

	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	elif [[ ${_CMD[@]} =~ "git log( +master)?" ]]; then return 0
	elif [[ ${_CMD[@]} =~ "git log +bar" ]]; then return $_WRONG_BRANCH
	else _tutr_generic_test -c git -a log -d "$_REPO_PATH"
	fi
}

log_bar1_hint() {
	case $1 in
		$NOOP)
			return
			;;

		$_WRONG_BRANCH)
			cat <<-MSG
			Don't overcomplicate things.  Just run $(cmd git log).
			MSG
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO_PATH"
			if (( _ATTEMPTS > 3 )); then
				cat <<-MSG

				Take a look at the log to see what effect $(cmd git merge bar) had on this repo.

				You do not need to provide the name of a branch; just use $(cmd git log).
				MSG
			fi
			;;
	esac
}

log_bar1_epilogue() {
	cat <<-MSG
	The merge didn't just move the branch name $(_master), but created a brand
	new "merge" commit.  Unlike most commits, this merge commit has $(bld two)
	parents, thus tying two separate branches together.
	MSG
}



show_branch2_pre() {
	must_be_in_repo
}

show_branch2_prologue() {
	cat <<-MSG
	Run $(cmd git show-branch) to visualize the new commits and the branches they
	affect.
	MSG
}

show_branch2_test() {
	_tutr_generic_test -c git -a show-branch -d "$_REPO_PATH"
}

show_branch2_hint() {
	_tutr_generic_hint $1 git "$_REPO_PATH"

	cat <<-MSG

	Run $(cmd git show-branch) to proceed.
	MSG
}

show_branch2_epilogue() {
	cat <<-MSG
	Trace the $(bld '*')s in the $(_master) column.  See that the commits in both
	$(_bar) and $(_colors) also belong to the $(_master) branch.

	The newly created "merge" commit is represented by a $(bld '-').

	MSG
	_tutr_pressenter
}




log_graph_pre() {
	must_be_in_repo
}

log_graph_prologue() {
	cat <<-MSG
	There is another way to see the relationship between these commits.
	Giving $(cmd git log) the $(cmd --graph) option causes it to draw an ASCII-art
	trace of the relationships between the commits.

	Try this now.
	MSG
}

log_graph_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	else _tutr_generic_test -c git -a log -a --graph -d "$_REPO_PATH"
	fi
}

log_graph_hint() {
	if [[ $1 == $NOOP ]]; then return
	elif (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Give $(cmd git log) the $(cmd --graph) option to see how it draws the relationship
			between these merged commits.
			MSG
	else
		_tutr_generic_hint $1 git "$_REPO_PATH"
		cat <<-MSG

		Run $(cmd git log --graph)
		MSG
	fi
}



run_merged1_pre() {
	must_be_in_repo
}

run_merged1_prologue() {
	cat <<-MSG
	You've been very patient.  This is the moment you have been waiting for.

	Go ahead and run $(_py pomodoro.py) one last time to see if the progress
	bar is really colorful now.
	MSG
}

run_merged1_test() {
	if _tutr_noop || _tutr_is_viewer ${_CMD[0]}; then return $NOOP
	else _tutr_generic_test -c $_PY -a './pomodoro.py|pomodoro.py' -d "$_REPO_PATH" -i
	fi
}

run_merged1_hint() {
	if [[ $1 == $NOOP ]]; then return
	elif [[ $1 == $WRONG_CMD ]]; then
		if (( _ATTEMPTS < 2 )); then
			cat <<-MSG
			Run $(_py pomodoro.py) to see if the progress bar is really colored.
			MSG
		else
			cat <<-MSG
			Run $(cmd $_PY pomodoro.py) to see if the progress bar is really colored.
			MSG
		fi
	else
		_tutr_generic_hint $1 $_PY "$_REPO_PATH"
	fi
}

run_merged1_epilogue() {
	cat <<-MSG
	That seems like magic!  Remember that this is just a demo and that I
	took care to build this program so that it could be smoothly merged.

	In the real world it is common for merges to result in conflicts.   This
	is what would happen if you were to merge the $(_figlet) branch into this
	project right now (but I think you've done enough for one tutorial).

	MSG

	_tutr_pressenter

	cat <<-MSG

	Conflicts must be resolved through the intervention of a human.  They
	are not usually very hard to untangle; just fall back onto your trusty
	workflow:

	  0. Edit the affected file(s)
	  1. Add your changes with $(cmd git add)
	  2. Commit the changes with $(cmd git commit)

	$(cmd git status) has your back at every step by suggesting what command
	to run next.  When a merge conflict happens to you, just refer to the
	lecture notes for detailed instructions.

	MSG
	_tutr_pressenter
}




cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}


epilogue() {
	cat <<-EPILOGUE
	${_C}  _____                        __       __     __  _
	${_C} / ___/__  ___  ___ ________ _/ /___ __/ /__ _/ /_(_)__  ___  ___
	${_C}/ /__/ _ \\/ _ \\/ _ \`/ __/ _ \`/ __/ // / / _ \`/ __/ / _ \\/ _ \\(_-<
	${_C}\\___/\\___/_//_/\\_, /_/  \\_,_/\\__/\\_,_/_/\\_,_/\\__/_/\\___/_//_/___/
	${_C}              /___/
	${_Z}
	You understand the basics of $(_Git) Branches!

	EPILOGUE

	_tutr_pressenter

	cat <<-EPILOGUE

	In this lesson you learned how to use Git to

	* See which branches exist locally and remotely
	* Checkout different branches of development
	* Merge branches

											 $(blk ASCII art credit: Russell Marks)
	EPILOGUE

	_tutr_pressenter
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
	list_branches \
	list_all_branches \
	checkout_colors \
	log_colors0 \
	run_colors \
	checkout_bar \
	log_bar0 \
	run_bar \
	checkout_figlet \
	log_figlet0 \
	run_figlet \
	checkout_master \
	show_branch0 \
	merge_colors \
	log_colors1 \
	show_branch1 \
	show_branch_more \
	run_merged0 \
	merge_bar \
	log_bar1 \
	show_branch2 \
	log_graph \
	run_merged1


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
