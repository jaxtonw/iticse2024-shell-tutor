#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=25

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

# The assignment number of the next assignment
_A=0

# Name of the starter code repo
_REPONAME=cs1440-winder-jaxton-assn$_A

# This function is named `_Git` to avoid clashing with Zsh's `_git`
_Git() { (( $# == 0 )) && echo $(blu Git) || echo $(blu $*); }

source ansi-terminal-ctl.sh
source progress.sh

if [[ -n $_TUTR ]]; then
	source editors+viewers.sh
	source generic-error.sh
	source git.sh
	source noop.sh
	source open.sh
	source platform.sh

	# the number of Git subcommands taught in this lesson
	_SUBCMDS=10
	_subcmd() { rev "Git subcommand $1/$_SUBCMDS:${_Z} $(_Git $2)"; }
	_local() { (( $# == 0 )) && echo $(ylw local) || echo $(ylw $*); }
	_remote() { (( $# == 0 )) && echo $(mgn remote) || echo $(mgn $*); }
	_origin() { (( $# == 0 )) && echo $(red origin) || echo $(red $*); }

	# origin of the starter code repo
	_SSH_REPO_URL=git@github.com:jaxtonw/$_REPONAME

	# Open the current Git repo's origin web page
	browse_repo() {
		_tutr_git_repo_https_url
		if [[ -n $REPLY ]]; then
			_tutr_open $REPLY
			_tutr_warn echo "Opening $REPLY in your web browser..."
		else
			_tutr_warn echo "Failed to find this repo's origin URL!"
		fi
	}
fi


_repo_warning() {
	cat <<-:
	The repository $(path $_REPONAME) already exists in the
	parent directory.  Because this lesson involves cloning this repository,
	it should not already exist.

	If you have not yet submitted Assignment #$_A you may not wish to delete
	your work.  In that case, it's probably best to not re-run this lesson.

	If you want to start over, use $(cmd rm -rf) to delete $(path $_REPONAME)
	and everything in it.  From here you can run this command:
	  $(cmd rm -rf ../$_REPONAME)

	Otherwise, you can rename the directory with $(cmd "mv OLD NEW").
	After moving or removing the repository, this lesson can be restarted.

	If you are just looking for a quick refresher, please refer to the
	$(_Git) instructions in the online lecture notes.
	:
}

_tutr_lesson_statelog_global() {
	_TUTR_STATE_CODE= # We don't have a meaningful and general state code yet...
	_TUTR_STATE_TEXT=$(_tutr_git_default_text_statelog $_REPO_PATH)
}



setup() {
	source screen-size.sh 80 30

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh
	_tutr_assert_program_exists git

	source ssh-connection-test.sh
	_ssh_key_is_missing_msg() {
		cat <<-MSG
		${_Y}    ______
		${_Y}---'    __)     ${_Z}Your SSH key is missing!
		${_Y}         __)    ${_Z}You can fix it yourself by running lesson 5 again.
		${_Y}          __)
		${_Y}       ____)    ${_Z}Run this command:
		${_Y}---.  (         ${_Z}  $(cmd MENU=yes ./tutorial.sh)
		${_Y}    '. \\        ${_Z}Then choose ${_W}5-ssh-key.sh
		${_Y}      \\_)
		${_Y}                ${_Z}Contact $_EMAIL if you need assistance.

		MSG
	}
	_tutr_assert_ssh_connection_is_okay

	export _BASE="$PWD"
	# Because I can't count on GNU Coreutils realpath(1) or readlink(1) on
	# all systems, get parent dir's real name the old fashioned way
	export _PARENT="$(cd .. && pwd)"
	# Handle the case where we're in a repo in a repo; like the case that we're
	# in the dev repo or a packaged shell tutor distribution repo  
	if (cd $_PARENT; git status &>/dev/null); then
		export _PARENT="$(cd ../.. && pwd)"
	fi
	export _REPO=$_PARENT/$_REPONAME

	# Exit if the starter code repo already exists
	if [[ -d "$_REPO/.git" ]]; then
		_tutr_err _repo_warning
		return 1
	fi
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #6: The Git Version Control System

	In this lesson you will learn how to

	* Prepare Git on your computer
	* Ask Git for help about its commands
	* Clone a Git repository onto your computer
	* Check the status of your repository
	* Change a file and commit it to the repository
	* View the Git log
	* Submit your homework to GitLab

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



# 0. Learn about the 'help' command
git_help_prologue() {
	cat <<-:
	$(_Git) is a system of programs that manage a $(_Git repository) of source code.

	Wh-what does that mean?  Patience, and it will all make sense.

	You don't know it yet, but $(_Git) will become one of your best friends as
	you write code.  $(_Git) has a bit of a... reputation... for not being very
	easy to learn.

	We'll take things nice and slow.

	:

	_tutr_pressenter

	cat <<-:

	To keep things simple, everything that you do with $(_Git) happens with the
	$(cmd git) command.

	The first argument to $(cmd git) is the name of a $(bld subcommand).
	After the subcommand you may give other arguments to complete the
	command.  The syntax is:
	  $(cmd "git SUBCOMMAND [arguments...]")

	I will teach you $(rev $_SUBCMDS) subcommands to get started with $(_Git).
	Later on, when you are more comfortable, you will add more subcommands
	to your repertoire.

	The most important subcommand is $(cmd help).  If you forget everything else
	you know about $(_Git), you can figure it out again with this subcommand.

	Run $(cmd git help) now.
	:
}

git_help_test() {
	_tutr_generic_test -c git -a help
}

git_help_hint() {
	_tutr_generic_hint $1 git

	echo "Run $(cmd git help) to proceed"
}

git_help_epilogue() {
	_tutr_pressenter
	cat <<-:
	                                                    ${_Y}     _
	Phew!  That's a lot of help!                        ${_Y}    ( |
	                                                    ${_Y}  ___\\ \\
	It's okay if this seems overwhelming right now.     ${_Y} (__()  \`-|
	Soon, much of it will make complete sense to you.   ${_Y} (___()   |
	                                                    ${_Y} (__()    |
	Trust me!                                           ${_Y} (_()__.--|

	:
	_tutr_pressenter
}



# 1. practice getting help
git_help_help_prologue() {
	cat <<-:
	$(cmd git help) shows a small sampling of possible subcommands that $(_Git) can
	run, but it doesn't tell you $(bld how) to use them.  You can obtain detailed
	help about a specific subcommand by giving $(cmd git help) that subcommand's
	name as an argument.

	:

	if [[ $_PLAT = MINGW ]]; then
		cat <<-:
		Since you are on Windows, $(_Git) may display the subcommand's manual page
		in your browser instead of the console.

		If nothing appears in your console, just wait a bit longer for your
		browser to pop up.

		Otherwise, the information will be presented just like a man page.
		As before, use $(kbd q) to quit the man page viewer.

		:
	else
		cat <<-:
		That subcommand's manual page will appear in the terminal, just the same
		as the other manual pages you've read previously.  As before, use $(kbd q) to
		quit the man page viewer.
		:
	fi

	cat <<-:

	Begin by viewing the manual for the $(cmd help) subcommand:
	  $(cmd git help help)
	:

}

git_help_help_test() {
	_tutr_generic_test -c git -a help -a help
}

git_help_help_hint() {
	_tutr_generic_hint $1 git

	cat <<-:

	Read the help for git's $(cmd help) subcommand:
	  $(cmd git help help)
	:
	if [[ $_PLAT = MINGW ]]; then
		cat <<-:

		This command may open git's $(cmd help) page in your browser instead of
		the console.
		:
	fi
}

git_help_help_epilogue() {
	cat <<-:
	Whenever you are unsure how to use a $(_Git) subcommand, remember to run
	  $(cmd git help SUBCOMMAND)
	to learn how to use it.

	$(_subcmd 1 help)

	Now you can begin in earnest!

	:
	_tutr_pressenter
}



# 2.  Launch a command shell and use the `git config` command to set up your
# 	  user name and email address.
git_config_rw() {
	git config --global --unset user.name
	git config --global --unset user.email
}

git_config_ff() {
	git config --global user.name "The Cheat"
	git config --global user.email Cheatachu72@homestarrunner.com
}

git_config_pre() {
	git config --get user.name >/dev/null
	_HAS_NAME=$?
	git config --get user.email >/dev/null
	_HAS_EMAIL=$?

	if (( _HAS_NAME == 0 && _HAS_EMAIL == 0 )); then
		printf "\x1b[1;32mTutor\x1b[0m: Git knows your name and email address, which means that\n"
		printf "\x1b[1;32mTutor\x1b[0m: you already know about the $(cmd git config) subcommand.\n"
		printf "\x1b[1;32mTutor\x1b[0m:\n"
		printf "\x1b[1;32mTutor\x1b[0m: This isn't your first time at the rodeo, is it?\n"
		printf "\x1b[1;32mTutor\x1b[0m:\n"
		printf "\x1b[1;32mTutor\x1b[0m: Anyhow, I think you've earned this:\n"
		printf "\x1b[1;32mTutor\x1b[0m:\n"
		printf "\x1b[1;32mTutor\x1b[0m: $(_subcmd 2 config)\n"
		printf "\x1b[1;32mTutor\x1b[0m:\n"

		_tutr_pressenter
	fi
}

git_config_prologue() {
	cat <<-:
	Use the $(cmd git config) command to set up your name and email address.
	$(_Git) needs to know who you are so that when you make commits it can
	record who was responsible.

	The command to set your user name is like this:
	  $(cmd 'git config --global user.name "Danny Boy"')

	And the command for your email goes like:
	  $(cmd 'git config --global user.email "danny.boy@houseofpain.com"')

	Of course, use your own name and email address.
	:
}

git_config_test() {
	git config --get user.name >/dev/null
	_HAS_NAME=$?
	git config --get user.email >/dev/null
	_HAS_EMAIL=$?

	if   [[ ${_CMD[0]} = git && ${_CMD[1]} = config && ${_CMD[@]} != *--global* ]]; then return 97
	elif (( $_HAS_NAME == 0 && $_HAS_EMAIL == 0 )); then return 0
	elif (( $_HAS_NAME == 0 )); then return 99
	elif (( $_HAS_EMAIL == 0 )); then return 98
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = config ]]; then return 96
	else _tutr_generic_test -c git -a config -d "$_BASE"
	fi
}

git_config_hint() {
	case $1 in
		99)
			cat <<-:
			Good!  Now set your email address under the $(bld user.email) setting.
			:
			;;

		98)
			cat <<-:
			Almost there!  Now configure your name in the $(bld user.name) setting.
			:
			;;

		97)
			cat <<-:
			The $(cmd "--global") option to the $(cmd git config) command is important
			because it records that setting across your entire computer.

			Without it, you'll need to run $(cmd git config) every time you create
			a new $(_Git) repository.  And that's just a lot of unnecessary work.

			Try that command again, but add $(cmd "--global") right after
			$(cmd git config) and before the name of the setting.
			:
			;;

		96)
			cat <<-:
			The commands you must use look like this:
			  $(cmd 'git config --global user.name  "Danny Boy"')
			  $(cmd 'git config --global user.email "danny.boy@houseofpain.com"')

			Of course, you should use your own name and email address.
			:
			;;

		*)
			_tutr_generic_hint $1 git "$_BASE"
			;;
	esac
}

git_config_epilogue() {
	cat <<-:
	$(_subcmd 2 config)

	Because you gave $(cmd git config) the $(cmd '--global') option you will not need to
	perform this step in the future.  From now on, the $(cmd git) program on
	this computer knows who you are.

	If you made a typo when entering your name or email, or want to change
	them, you may do so at any time.  You'll just use these same commands
	again.

	If you install $(_Git) on another computer, it will remind you to run
	this set up routine when you first run $(cmd git).

	:
	_tutr_pressenter
}



# 3. see if we're presently within a git repo
git_status0_prologue() {
	cat <<-:
	One of the most important aspects of $(_Git) is that it facilitates sharing
	your project with other programmers.  $(_Git) has been called "the social
	network for code".

	There are three key concepts related to sharing projects:

	*   The directory of files which make up a project and is managed by $(_Git)
	    is called a $(bld repository) (or $(bld repo) for short)
	*   $(bld cloning) downloads a $(_Git) repository onto your computer
	*   $(bld pushing) uploads your repository to another computer

	You've already cloned at least one repository; that's how this shell
	tutorial came to be on your computer.  In a moment you are going to
	clone another repository from the internet.

	:
	_tutr_pressenter

	cat <<-:

	Before you clone a repository, it is wise to ensure that your shell's
	CWD is $(bld not) already inside a $(_Git) repository.  Things get confusing really
	fast when one $(_Git) repository is nested in another.

	$(_Git "Git's") $(cmd status) subcommand provides information about repositories:

	  * When this command $(blu succeeds) it means that your shell's CWD
	    $(bld is) in a repository.
	  * When this command $(red fails) it typically means that you are $(bld not)
	    already inside a repository.

	Run $(cmd git status) to see which is the case for you.
	:
}

git_status0_test() {
	_tutr_generic_test -i -c git -a status -d "$_BASE"
}

git_status0_hint() {
	_tutr_generic_hint $1 git "$_BASE"
	cat <<-:

	Run $(cmd git status)
	:
}

git_status0_epilogue() {
	if (( $_RES == 0 )); then
		cat <<-:
		This output indicates that you are presently in a repository.

		:
	else
		cat <<-:
		Huh, it looks like you're not in a repository right now.
		That's unexpected, but not a problem.

		:
	fi

	cat <<-:
	$(_subcmd 3 status)

	:
	_tutr_pressenter
}



cd_dotdot0_rw() {
	cd "$_BASE"
}

cd_dotdot0_ff() {
	cd "$_PARENT"
}

# 4. cd .. to escape this git repository
cd_dotdot0_prologue() {
	cat <<: 
Go up and out of this directory to $(path $_PARENT)

You may use $(path $(_tutr_shortest_path $_PARENT $PWD [echo])) to get there
:
}

cd_dotdot0_test() {
	if   [[ "$PWD" = "$_PARENT" ]]; then return 0
	else _tutr_generic_test -c cd -a .. -d "$_PARENT"
	fi
}

cd_dotdot0_hint() {
	_tutr_generic_hint $1 cd "$_PARENT"

	cat <<-:

	Run $(cmd cd ..) to leave this directory for its parent.
	:
}



# 5.  Ensure that you're not presently within a git repository by running `git status`.
git_status1_prologue() {
	cat <<-:
	You are now in the parent directory of the shell tutorial repository.
	But what if this directory is also a $(_Git) repository?  You had better run
	$(cmd git status) to find out.

	When $(cmd git status) is used outside of a repository it reports a $(red fatal)
	error.  Usually one wishes to avoid $(red fatal) errors, but in this case
	an error message is $(cyn Good News).
	:
}

git_status1_test() {
	_tutr_generic_test -f -c git -a status -d "$_PARENT"
}

git_status1_hint() {
	[[ -n $DEBUG ]] && echo "_test returns '$1'"  # DELETE ME
	case $1 in
		$STATUS_WIN)
			cat <<-:
			This directory really shouldn't be a $(_Git) repository.

			Run $(cmd tutor bug) and email the output to $_EMAIL
			before proceeding.

			:
			;;
		*)
			_tutr_generic_hint $1 git "$_PARENT"
			cat <<-:

			Run $(cmd git status) to find out if you are still inside a repository.
			:
			;;
	esac
}

git_status1_epilogue() {
	_tutr_pressenter
	if (( $_RES == 0 )); then
		cat <<-:

		Hmm, you're still inside a repo here?
		It might cause you trouble if you proceed.

		Please contact $_EMAIL for help.
		:
	else
		cat <<-:

		This is exactly what you want to see when you $(bld "shouldn't") be in a $(_Git)
		repository.
		:
	fi

	cat <<-:

	It never hurts to run $(cmd git status).  You really can't use it too much!

	:
	_tutr_pressenter
}



# 6.  Clone the git repository containing the starter code from GitLab onto
# 	your computer using the `git clone` command.

git_clone_rw() {
	command rm -rf "$_REPO"
}

git_clone_ff() {
	git clone $_SSH_REPO_URL
}

git_clone_pre() {
	# See if the starter code repo already exists
	if [[ -d "$_REPO/.git" ]]; then
		_tutr_err _repo_warning
		return 1
	fi
}

git_clone_prologue() {
	cat <<-:
	Now you will $(bld clone) the starter code for Assignment #1 in CS 1440.
	$(bld Cloning) a repo makes a new directory on your computer into which the
	repo's information is downloaded.

	The syntax of this command is
	  $(cmd "git clone URL [DIRECTORY]")

	$(cmd URL) is the location of another $(_Git) repo known as the $(_remote).  Most
	often the $(_remote) repo is out on the internet, but it can also be another
	directory on your computer.  When a $(_remote) repo is cloned from the web,
	the URL argument begins with $(cmd git@) or $(cmd https://).

	If you leave off the optional $(cmd DIRECTORY) argument, $(_Git) chooses the name
	of the new directory for you.

	Use $(cmd git clone) to clone the $(_remote) repo at the URL
	  $(path $_SSH_REPO_URL)

	Leave off the optional $(cmd DIRECTORY) argument for now; you can rename the
	repo after this tutorial.
	:
}

git_clone_test() {
	_tutr_generic_test -c git -a clone -a "^https://github.com/jaxtonw/cs1440-winder-jaxton-assn$_A$|^git@github.com:jaxtonw/cs1440-winder-jaxton-assn$_A$" -d "$_PARENT"
}

git_clone_hint() {
	case $1 in
		$STATUS_FAIL)
			cat <<-:
			$(cmd git clone) failed unexpectedly.

			If the above error message includes the phrases $(red fatal: unable to access) and
			$(red Connection refused), that indicates an issue with your network
			connection.  Ensure that you are connected to the internet and try again.

			If you are using campus WiFi, make sure you are connected to $(bld Eduroam)
			and $(red not) $(blu USU Guest).

			If the error persists or is different, please contact $_EMAIL
			for help.  Copy the full command and all of its output.

			:
			;;

		*)
			_tutr_generic_hint $1 git "$_PARENT"

			cat <<-:

			To clone this repo run
			  $(cmd git clone git@github.com:jaxtonw/$_REPONAME)
			:
		;;
	esac
}

git_clone_epilogue() {
	if [[ $_RES -eq 0 ]]; then
		cat <<-:
		That is all normal output for the $(cmd clone) subcommand.

		$(_subcmd 4 clone)

		:
		_tutr_pressenter
	else
		cat <<-:
		Hmm... something went wrong while cloning that repository.

		Copy the text in the terminal and prepare a bug report for Jaxton.
		:
	fi
}



# 7.  Enter the newly cloned repository
cd_into_repo_rw() {
	cd "$_PARENT"
}

cd_into_repo_ff() {
	cd "$_REPO"
	_ORIG_URL=$(git remote get-url origin)
}

cd_into_repo_prologue() {
	cat <<-:
	$(cmd git clone) created a new directory called $(path $_REPONAME)
	and populated it with files from the internet.

	This directory is a new $(_Git) repository.
	Why not $(cmd cd) inside and take a look around?
	:

}

cd_into_repo_test() {
	if   [[ $PWD = $_REPO ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a $_REPONAME -d "$_REPO"
	fi
}

cd_into_repo_hint() {
	_tutr_generic_hint $1 cd "$_REPO"

	cat <<-:
	Enter the new repo with the $(cmd cd) command:
	  $(cmd cd $_REPONAME)
	:
}

cd_into_repo_post() {
	if [[ $_RES -ne 0 ]]; then
		_tutr_die printf "'Then send it to $_EMAIL.'"
	fi
	_ORIG_URL=$(git remote get-url origin)
}



# 8. See what a clean, newly cloned repo looks like with 'git status'
git_status2_prologue() {
	cat <<-:
	You can see what files and directories are here with $(cmd ls).  After the
	last lesson the layout of this repository should be familiar.

	Now that you're back inside of a $(_Git) repository you can run $(cmd git status)
	again to see what state the repository is in.  Since you just barely
	cloned it down from the internet, this repo should be in a clean state.

	Run $(cmd git status) to proceed.
	:
}

git_status2_test() {
	if   _tutr_noop; then return $NOOP
	else _tutr_generic_test -c git -a status -d "$_REPO"
	fi
}

git_status2_hint() {
	_tutr_generic_hint $1 git "$_REPO"

	cat <<-:

	Run $(cmd git status) to proceed.
	:
}

git_status2_epilogue() {
	_tutr_pressenter
	cat <<-:

	This is what a clean repository looks like.  By $(bld clean) I mean that
	there is no difference between the files in this $(_local local repo) and the
	files in the $(_remote remote repo).

	Let me explain what this message is telling you.

	$(bld On branch master)
	  This message reminds you that you are working on the 'master' (A.K.A.
	  default) branch.  For the time being all of your work will be on this
	  branch.  You'll learn more about branches later in the semester.

	$(bld "Your branch is up to date with 'origin/master'.")
	  The files in the 'master' branch of this $(_local local repo) are the same
	  as the files on the $(_remote "remote repo's") 'master' branch.  $(_Git) doesn't
	  automatically go out to the internet to check, though; this
	  information was up-to-date as of your $(cmd git clone) command.

	$(bld "nothing to commit, working tree clean")
	  $(bld Working tree) refers to the source code files in this $(_local local repo).
	  Since you have not changed anything, they are exactly as $(_Git) remembers
	  them.

	:
	_tutr_pressenter
}



# Open "README.md" in an editor and change the file in some way.
# Return to your command shell ask git about the status of your repository.
edit_readme0_rw() {
	git restore "$_REPO/README.md"
}

edit_readme0_ff() {
	cat <<-: >>  "$_REPO/README.md"

	                                                        ,,,
	             Kilroy was here                           (o o)
	----------------------------------------------------ooO-(_)-Ooo-------
	:
	sed -i -e 'y/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM/' "$_REPO/README.md"
}

# The next step also wants the user to run 'git status'
edit_readme0_pre() {
	_CMD=()
}

edit_readme0_prologue() {
	cat <<-:
	$(_Git) is much more than just a slick way to download code from the 'net.

	The thing you will do the most with $(_Git) is take snapshots (A.K.A.
	$(bld commits)) of your project while you work.  $(bld Commits) record the state of
	files in your project at various points in time.  When you make a
	mistake or paint yourself into a corner you can turn the project back to
	an earlier commit and try again.  $(_Git) is the ultimate $(bld undo button) that
	transcends all other tools.

	To make a commit you first need to change $(bld something) in the $(_local repository).
	There is a file here called $(path README.md).  Open this file in $(cyn Nano), change
	something, and save it.  $(_Git) will be able to tell that you changed this
	file.  Run $(cmd git status) to see what $(_Git) says about it.

	It really doesn't matter what you do to $(path README.md); you can even
	remove the whole file.  Knock yourself out!
	:
}

edit_readme0_test() {
	_README_UNCHANGED=99
	if   [[ "$PWD" != "$_REPO" ]]; then return $WRONG_PWD
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif _tutr_file_unstaged README.md; then return 0
	elif ! _tutr_file_changed README.md; then return $_README_UNCHANGED
	else _tutr_generic_test -c git -a status
	fi
}

edit_readme0_hint() {
	case $1 in
		$NOOP)
			return
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO"
			;;

		$_README_UNCHANGED)
			cat <<-:
			You won't see anything interesting until you change $(path README.md).

			Go ahead and open it in $(cyn Nano) and make a mess of it.  You can't
			really hurt anything here!
			:
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO"
			cat <<-:

			Open $(path README.md) in $(cyn Nano), change it and save it.
			Or, just delete the file.  Whatever floats your boat.
			:
			;;
	esac
}

edit_readme0_epilogue() {
	[[ ! -f "$_REPO/README.md" ]] && echo "Not messing around, are we?"
}


# Run 'git status' to see what our edited/deleted file looks like
git_status3_prologue() {
	cat <<-:
	See what $(cmd git status) has to say about your handiwork.
	:
}

git_status3_test() {
	_tutr_generic_test -c git -a status -d "$_REPO"
}

git_status3_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Run $(cmd git status) to see what $(_Git) makes of your change to $(path README.md)
	:
}

git_status3_epilogue() {
	_tutr_pressenter

	cat <<-:

	You will see this message a lot, so you had better know what it means.

	$(bld On branch master)
	  You are still on the master branch.

	$(bld Your branch is up to date with $(_remote "'origin/master'"))
	  The $(_local "local repo's") master branch is not different from the master branch
	  on the $(_remote remote repo) named $(_origin).  The $(_origin) repo is the one you
	  cloned from.

	$(bld "Changes not staged for commit")
	  This is where $(_Git) lists what files have changed.  $(_Git) knows when a
	  file is created, modified or deleted.  Right before it displays the
	  changed files, it suggests commands you might run:

	  * $(cmd git add) accepts the changes
	  * $(cmd git restore) discards the changes, A.K.A. the $(bld undo button)

	Whenever you screw up, $(_Git "Git's") ready to fix it!

	The most important thing to remember is that $(cmd git status) suggests one
	or more commands that move your project along.  Whenever you are unsure
	about what to do next, just run $(cmd git status)!

	:

	_tutr_pressenter
}


# Use git restore (or checkout) to discard this change
git_restore_rw() {
	cat <<-: >>  "$_REPO/README.md"

	                                                        ,,,
	             Kilroy was here                           (o o)
	----------------------------------------------------ooO-(_)-Ooo-------
	:
	sed -i -e 'y/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM/' "$_REPO/README.md"
}

git_restore_ff() {
	git restore "$_REPO/README.md"
}

git_restore_prologue() {
	cat <<-:
	Practice fixing a mistake with $(_Git "Git's") $(cmd restore) subcommand.

	The syntax of this subcommand is
	  $(cmd git restore FILE...)

	Use $(cmd git restore) to discard the change to $(path README.md) you made.  This
	will put $(path README.md) back in its original state, no matter what you did
	to it.
	:
}

git_restore_test() {
	# TODO: handle the case where the user runs `git add README.md`
	#       and stages their change instead of reverting it
	if   [[ $PWD != $_REPO ]]; then return $WRONG_PWD
	elif [[ -z $(git status --porcelain=v1) ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c git -a restore -a README.md -d "$_REPO"
	fi
}

git_restore_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Use $(cmd git restore) to undo the change you made to $(path README.md).
	  $(cmd git restore README.md)
	:
}

git_restore_epilogue() {
	cat <<-:
	Excellent!

	:
	_tutr_pressenter
}


# 11. Run 'git status' to prove that 'git restore' really worked
git_status4_prologue() {
	cat <<-:
	All better now!  Run $(cmd git status) to see for yourself.  The state of the
	working tree should be $(bld clean).
	:
}

git_status4_test() {
	if _tutr_noop; then return $NOOP
	else _tutr_generic_test -c git -a status -d "$_REPO"
	fi
}

git_status4_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Run $(cmd git status) to verify that $(path README.md) has been put back to its
	original form.
	:
}

git_status4_epilogue() {
	cat <<-:
	${_Y}    *    \\${_W}* ${_Y}/ ${_W}*
	${_Y}      * --${_W}.:.${_Y} *
	${_Y}     *   ${_W}* :${_y}\\${_Y} -
	${_Y}       .*  | ${_y}\\
	${_Y}      * *     ${_y}\\               ${_z}Abracadabra
	${_Y}    .  ${_R}*       ${_y}\\
	${_R}     .${_Y}.        ${_w},${_y}\\${_w}\\          ${_z}As good as new!
	${_Y}    *          ${_w}|\\${_w})|
	${_Y}  .   ${_R}*         ${_w}\\ ${_w}|    $(_subcmd 5 restore)
	${_Y} . ${_R}. *          ${_w} |${_b}/\\
	${_Y}    .* ${_R}*         ${_b}/  \\
	${_R}  *              ${_b}\\ / \\
	${_R}*  ${_Y}.  ${_R}*           ${_b}\\   \\
	:
	_tutr_pressenter
}



# Run `git add` to add `README.md` to your repository.
git_add0_rw() {
	git restore --staged "$_REPO/README.md"
	git restore "$_REPO/README.md"
}

git_add0_ff() {
	cat <<-: >>  "$_REPO/README.md"

	                                                        ,,,
	             Kilroy was here                           (o o)
	----------------------------------------------------ooO-(_)-Ooo-------
	:
	sed -i -e 'y/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM/' "$_REPO/README.md"
	git add "$_REPO/README.md"
}

git_add0_prologue() {
	cat <<-:
	Now you will change $(path README.md) again, but this time you will permanently
	save it in a $(_Git) $(bld commit).

	Creating a $(bld commit) is a two-step process:

	0.  Add changes to the commit with $(cmd git add)
	1.  Permanently record the commit along with a descriptive message with
	    $(cmd git commit)

	The form of the $(cmd git add) command is
	  $(cmd git add FILE...)

	This means you may add as many or as few files to a commit as you wish.

	Edit $(path README.md) once more, then use $(cmd git add) to prepare it to
	be committed.
	:
}


git_add0_test() {
	_README_UNCHANGED=99
	_README_DELETED=98
	if   [[ "$PWD" != "$_REPO" ]]; then return $WRONG_PWD
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif _tutr_file_staged README.md; then return 0
	elif [[ ! -f "$_REPO/README.md" ]]; then return $_README_DELETED
	elif ! _tutr_file_changed README.md; then return $_README_UNCHANGED
	else _tutr_generic_test -c git -a add -a README.md -d "$_REPO"
	fi
}

git_add0_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO"
			;;

		$_README_DELETED)
			cat <<-:
			I can tell that you mean business.

			Run $(cmd git add README.md) to tell $(_Git) that you have deleted $(path README.md).

			I know it seems weird to say $(bld add) when you have done the opposite.
			Think of it like this: you are $(bld adding) the fact that you have changed
			the repository.
			:
			;;

		$_README_UNCHANGED)
			cat <<-:
			You really must change $(path README.md) to proceed.

			Go ahead and open it in $(cyn Nano) and make a mess of it.
			It's OK - you can't do anything too bad here!
			:
			;;

		*)
			_tutr_generic_hint $1 git "$_REPO"
			cat <<-:

			Now use $(cmd git add README.md).
			:
			;;
	esac
}

git_add0_epilogue() {
	# check for autocrlf warning on MinGW
	if [[ $_PLAT = MINGW && $(git config --get core.autocrlf 2>/dev/null) == true ]] ; then
		cat <<-:
		That command may have also printed a warning message like this:

		$(ylw_ "warning: in the working copy of 'README.md', LF will be replaced by CRLF...")

		This message is harmless, and can be ignored.

		:
		_tutr_pressenter
	fi

	cat <<-:
	$(_subcmd 6 add)

	Creating a commit is a two-step process.

	By $(bld adding) your change to $(path README.md) you are halfway there.

	:
	_tutr_pressenter
}



# 13.  Check the status of your repository again
git_status5_prologue() {
	cat <<-:
	Run $(cmd git status) to see what your repository looks like in this state.
	:
}

git_status5_test() {
	_tutr_generic_test -c git -a status -d "$_REPO"
}

git_status5_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	echo
	git_status5_prologue
}

git_status5_epilogue() {
	_tutr_pressenter
	cat <<-:

	Files listed under the heading $(cyn Changes to be committed) are said to be
	in the $(bld staging area).

	The staging area is a $(_Git) concept; it is not a location or directory on
	your computer.  It is the $(bld state) between two commits.  Your files are
	still right here in this directory, and you can continue to edit and
	use them.

	$(cmd git add)ing files doesn't do anything permanent.  You can take them back
	out of the staging area by running:
	  $(cmd git restore --staged README.md)

	In other words, until you run $(cmd git commit), your changes are $(bld not) part of
	$(_Git "Git's") permanent record.  They can still be undone with $(cmd git restore).

	:
	_tutr_pressenter
}



# 14. Use the `-m` option to add a brief message (between double quotes)
#    about this change.
git_commit0_rw() {
	git reset --hard HEAD~
	date >> "$_REPO/README.md"
	git add "$_REPO/README.md"
}

git_commit0_ff() {
	git commit -m "automatically committed by Tha Cheat"
}

git_commit0_prologue() {
	cat <<-:
	Now you are ready to permanently record your change in a $(bld commit).
	A commit consists of

	  0.  Changes made to files in the project (identified by $(cmd git add))
	  1.  Your name (set with $(cmd git config))
	  2.  Your email address (set with $(cmd git config))
	  3.  The current date & time
	  4.  A brief message describing what you changed and why

	The $(cmd git commit) subcommand puts all of this information together.
	It has the form:
	  $(cmd 'git commit [-m "Commit message goes here"]')

	:
	_tutr_pressenter

	cat <<-:

	The $(cmd -m) argument is optional, but you shouldn't leave it off.  When you
	don't supply it, $(_Git) automatically opens a text editor to let you write
	a long, detailed message.  Unfortunately, the text editor it chooses for
	you isn't very user-friendly.

	For now, just write a short, one-line message on the command line.

	$(cyn IMPORTANT!)
	The message that follows $(cmd -m) $(bld MUST) be surrounded by $(mgn quote marks)!
	Otherwise, $(cmd git) thinks that your message is $(bld only) the first word, and the
	rest of the message is treated as $(bld more) arguments!

	Use $(cmd 'git commit -m "..."') to save a new commit.
	:
}

git_commit0_test() {
	if   [[ $PWD != $_REPO ]]; then return $WRONG_PWD
	elif _tutr_branch_ahead; then return 0
	elif _tutr_is_editor; then return $NOOP
	elif [[ ${_CMD[@]} = 'git status' ]]; then return $NOOP
	else _tutr_generic_test -c git -a commit -d "$_REPO"
	fi
}

git_commit0_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Run this command to make the commit.  Put some thought into your commit
	message.  And $(bld "don't forget") the $(mgn quote marks)!

	  $(cmd 'git commit -m "Commit message goes here"')
	:
}

git_commit0_epilogue() {
	_tutr_pressenter
	cat <<-:

	$(_subcmd 7 commit)

	Good job!

	These three commands are the backbone of your $(_Git) workflow:

	0.  $(cmd git add)
	1.  $(cmd git status)
	2.  $(cmd git commit)

	You will use these commands so much that, before long, they will be as
	natural as breathing.  It just takes practice!

	:
	_tutr_pressenter
}



# Review the commit history of your repository.
git_log0_prologue() {
	cat <<-:
	$(cmd git log) shows the history of the repository.  It shows the most
	recent commit at the top, and lists every commit all the way back to the
	very beginning.

	When there are too many commits to fit on the screen at once, $(cmd git log)
	uses the same text reader as the $(cmd man) command.  This means that you
	can use the same keyboard shortcuts to control the display:

	  * Press $(kbd j) or $(kbd Down Arrow) to scroll down.
	  * Press $(kbd k) or $(kbd Up Arrow) to scroll up.
	  * $(kbd q) exits the text reader.

	Run $(cmd git log) now.
	:
}

git_log0_test() {
	_tutr_generic_test -i -c git -a log -d "$_REPO"
}

git_log0_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Run 'git log' now.
	:
}

git_log0_epilogue() {
	cat <<-:
	There's your commit, right on top!

	$(_subcmd 8 log)

	There are not many commits in this repo yet.  It would not be weird for
	your repos to have dozens of commits by the time you are done with them.
	In fact, out in the real world, it is common for repositories to have
	thousands upon thousands of commits.

	My rule-of-thumb is $(bld many commits are better than a few).

	:
	_tutr_pressenter
}


# Get the status of your repository once more; the directory should be
# 	"clean".
git_status6_prologue() {
	cat <<-:
	Check the status of your repository once more.
	After making a commit it should be $(bld clean).
	:
}

git_status6_test() {
	_tutr_generic_test -c git -a status -d "$_REPO"
}

git_status6_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Get the status of your repository once more.
	  $(cmd git status)
	:
}

# TODO: there is a possibility that the student had deleted the "origin"
#       remote, in which case this message doesn't describe what they see.
git_status6_epilogue() {
	cat <<-:
	Notice $(_Git "Git's") new remark within the familiar $(bld clean) repository message:

	  $(bld Your branch is ahead of $(_remote "'origin/master'") by 1 commit.)
	  $(bld "  (use ")$(cmd '"git push"') $(bld 'to publish your local commits)')

	This is saying that the $(_local local repo) has diverged from the $(_remote remote repo),
	and that $(cmd git push) can put them back into harmony.

	:

	_tutr_pressenter
}





# 17. View configured remotes
git_remote_v_prologue() {
	cat <<-:
	                                        ${_y}           ___
	                                        ${_y}   _______|___|______
	Your $(_local local repository) is a clone of my  ${_C}__${_y}|__________________|
	repo. With this new commit, your local  ${_C}\\  ${_y}]________________[${_C} \`---.
	repo has diverged from $(_remote my original).     ${_C} \`.${_z}     help!        ${_C} ___  L
	The next commands I teach you will let  ${_C}  |${_g}   _  ${_z}/           ${_C}|   L |
	you merge these divergant repositories  ${_C}  |${_g} .'_\`--.___   __  ${_C}|   | |
	back into harmony.  But before I go     ${_C}  |${_g}( 'o\`   - .\`.'_ ) ${_C}|   F F
	there, let's consider the implications  ${_C}  |${_g} \`-._      \`_\`./_ ${_C}|  / /
	of this.                                ${_C}  J${_g}   '/\\\\    ( .'/ )${_C}F.' /
	                                        ${_C}   L${_g} ,__//\`---'\`-'_/${_C}J  .'
	$(_local This repo) knows that it was cloned from ${_C}   J${_g}  /-'        '/ ${_C}F.'
	my GitLab account.  So do all of your   ${_C}    L${_g}            '${_C} J'
	classmates' repos.  What would happen   ${_C}    J ${_Z}\`.\`-. .-'.' ${_C} F
	if everyone in the class $(bld "harmonized")     ${_C}     L  ${_Z}\`.-'.-'   ${_C}J
	their repos with $(_remote my original)?  Unless   ${_C}     |${_Z}__(__(___)__${_C}|${_Z}
	you all carefully coordinated with each ${_y}     F            J
	other, it would quickly devolve into    ${_y}    J              L
	a $(bld confusing mess).                       ${_y}    |______________|

	(To be honest, I don't know why there is a frog in this blender.
	I just wanted you to think of something messy.)

	:

	_tutr_pressenter

	cat <<-:

	In this class assignments are turned in with $(_Git).  Besides checking
	scores and reading messages from your grader, there is $(bld nothing) for you
	to do with assignments on Canvas.

	Instead, you will create a $(_remote remote repository) under your own account on
	my GitLab server and turn in your work there.  Your clone will remain
	isolated from the others and can go on to have an identity of its own.
	No mess, no fuss.  And (this is the most important bit) $(bld no frogs will)
	$(bld be hurt.)

	You will do this $(bld once) for every assignment.  It is accomplished
	entirely on the command line.

	:
	_tutr_pressenter

	cat <<-:

	In the next three steps you will use the $(cmd git remote) subcommand in a few
	different ways.

	First, you will see for yourself that this repository is a true clone of
	mine by running
	  $(cmd git remote -v)

	Try it!  Look for my username ($(cyn jaxtonw)) in the URL that is printed.
	:
}

git_remote_v_test() {
	if   [[ $PWD != $_REPO ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = help ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = log ]]; then return $NOOP
	else _tutr_generic_test -c git -a remote -a -v -d "$_REPO"
	fi
}

git_remote_v_hint() {
	_tutr_generic_hint $1 git "$_REPO"
	cat <<-:

	Run $(cmd git remote -v) to see where this repo came from.
	:
}

# TODO: there is a possibility that the student had deleted the "origin"
#       remote, in which case this message doesn't describe what they see.
git_remote_v_epilogue() {
	_tutr_pressenter

	cat <<-:

	What you see here are the URLs that this repository can $(bld download) updates
	from (fetching) and $(bld upload) updates to (push).

	Both of these URLs are nicknamed $(_origin), and right now they point back
	to $(bld my) account on GitLab.

	There is nothing particularly special about the name $(_origin); it's just
	a $(_Git) tradition.

	:
	_tutr_pressenter
}



# Rename origin -> old-origin
git_remote_rename_rw() {
	git remote rename old-origin origin
}

git_remote_rename_ff() {
	git remote rename origin old-origin
}

git_remote_rename_prologue() {
	cat <<-:
	Now, all of this talk about creating $(bld confusing) messes and blending up
	frogs is completely moot.  You $(bld cannot) possibly upload your work into $(_remote my)
	$(_remote repo) on GitLab because you don't know $(bld my) password.

	Look, I like you and everything, but I barely know you.  I am $(bld not)
	giving you my password.  You'll just have to use your own account
	and make a new repository there.

	:
	_tutr_pressenter

	cat <<-:

	$(_remote Remote repositories) in Git are identified by their URL.  Because URLs
	are long and hard to remember, they also have $(bld nicknames).

	The nicknames can be anything, but they really should be shorter than a
	URL.  It is a custom in $(_Git) to use $(_origin) for the URL that you use
	most often.  Your repo's $(_origin) should point to $(cyn your own) GitLab account.

	Before you make $(_origin) point to your account, first "save" the original
	URL with the nickname $(_remote old-origin).

	This form of $(cmd git remote) renames a $(_remote) repository's nickname:
	  $(cmd git remote rename OLD_NAME NEW_NAME)

	In your case, use $(_origin) as the $(cmd OLD_NAME) and $(bld old-origin) as the
	$(cmd NEW_NAME).
	:
}

## Ensure that a remote called origin no longer exists
git_remote_rename_test() {
	if   [[ $PWD != $_REPO ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	fi

	_WRONG_REMOTE_NAME=99
	local remote="$(git remote)"
	if   echo $remote | command grep -q -E '^old-origin$'; then return 0
	elif [[ -z $remote ]] ; then return 0  # if all remotes are deleted, let them through
	elif [[ $remote != origin ]]; then
		_REMOTE=$remote
		return $_WRONG_REMOTE_NAME
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = help ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = log ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = -v ]]; then return $NOOP
	else _tutr_generic_test -c git -a remote -a rename -a origin -a old-origin -d "$_REPO"
	fi
}

git_remote_rename_hint() {
	case $1 in
		$_WRONG_REMOTE_NAME)
			git remote rename $_REMOTE origin
			cat <<-:

			Whoops!  That wasn't the right thing to rename $(_origin) to!

			I've put it back so you can try again
			:
			;;
		*)
			_tutr_generic_hint $1 git "$_REPO"
			;;
	esac

	if [[ $1 != $WRONG_PWD ]]; then
		cat <<-:

		Use this command to proceed:
		  $(cmd git remote rename origin old-origin)
		:
	fi
}

git_remote_rename_post() {
	if [[ -z "$(git remote)" ]]; then
		_REMOVED_ORIGIN=yep
	else
		_REMOVED_ORIGIN=nope
	fi
}

git_remote_rename_epilogue() {
	if [[ $_REMOVED_ORIGIN = yep ]]; then
		echo Well, that was ONE way to do it.
	else
		echo "Perfect!"
	fi

	cat <<-:

	The reason why I asked you to rename $(_origin) instead of $(bld erasing) it
	is so that your repository will always remember where it came from.

	There is a chance that somebody will find a bug in an assignment, and I
	will need to issue an update.  If your repository remembers that it came
	from $(_origin old-origin), it will be very easy for you to fetch the fixed code.

	I hope this never happens.  But when it does, I will give you complete
	instructions for fetching the fix at that time.

	:

	if [[ $_REMOVED_ORIGIN = yep ]]; then
		cat <<-:
		Since you removed my URL from your $(_local) repository's configuration,
		you would be on your own if I made a change to the assignment's starter
		code or documentation.

		:
	fi
	_tutr_pressenter
}


# Add a new repo URL under the name 'origin'
git_remote_add_rw() {
	git remote remove origin
}

git_remote_add_ff() {
	git remote add origin git@github.com:chad/cs1440-chadwick-chad-assn$_A
}

git_remote_add_prologue() {
	cat <<-:
	Now you will use $(cmd git remote add) to associate the name $(_origin) with a new
	GitLab URL that includes your username.

	The new URL needs a bit of explanation.

	:
	_tutr_pressenter

	# TODO - check for https: in $_ORIG_URL
	cat <<-:

	The URL that you cloned this repo from is
	  $(path $_ORIG_URL)

	Your new URL will look like that, except for these differences:

	  * Replace $(cyn jaxtonw) with your $(bld GitLab username) (case does not matter)
	    * Your $(bld GitLab username) is most likely your $(bld A Number)
	  * Replace $(cyn winder-jaxton) with your $(bld real name) (again, case does not matter)
	    * To make things easy on your grader, use your Canvas $(bld preferred name)

	:

	_tutr_pressenter

	cat <<-:

	Now, it just so happens that my username is $(cyn firstname) $(bld dot) $(cyn lastname).
	Your username is probably your $(bld A Number).  Don't blindly follow my lead
	and use $(cyn firstname) $(bld dot) $(cyn lastname) unless that $(bld really) is your username!

	You can see your username by clicking on your avatar in the upper-right
	corner of GitLab while logged in.

	:

	_tutr_pressenter

	cat <<-:

	When entering the URL, it is very important that you NOT change:

	  * Punctuation, such as slashes $(ylw /) and colons $(ylw :)
	  * $(ylw git@gitlab.cs.usu.edu OR git@github.com)
	  * $(ylw cs1440)
	  * $(ylw assn$_A)

	When students get those wrong, we cannot locate their submission on the
	GitLab server (there are $(bld thousands) of them).

	If this ever happens to you, contact a TA for help ASAP.

	:

	_tutr_pressenter

	cat <<-:

	The syntax of the command you will use is:
	  $(cmd git remote add origin NEW_URL)

	When you've figured out what the $(path NEW_URL) looks like, give it a try!

	:
}

git_remote_add_test() {
	_WRONG_SUBCOMMAND=95
	if   [[ $PWD != $_REPO ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = help ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = log ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = -v ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = remove ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} != remote ]]; then return $_WRONG_SUBCOMMAND
	fi

	_HTTPS_URL=91
	_NOT_SSH_URL=90
	local URL=$(git remote get-url origin 2>/dev/null)
	if   [[ -z $URL ]]; then return 99
	elif [[ $URL =  https:* ]]; then return $_HTTPS_URL
	elif [[ $URL != git@* ]]; then return $_NOT_SSH_URL
	elif [[ $URL =  git@gitlab.cs.usu.edu/* || $URL =  git@github.com/*  ]]; then return 94
	elif ! [[ $URL == *gitlab.cs.usu.edu* || $URL == *github.com* ]]; then return 93
	elif [[ $URL =  *:jaxtonw/* ]]; then return 98
	elif [[ $URL != */cs1440-* ]]; then return 92
	elif [[ $URL != *-assn$_A && $URL != *-assn$_A.git ]]; then return 96
	elif [[ $URL =  */$_REPONAME* ]]; then return 97
	elif [[ $URL =  git@gitlab.cs.usu.edu:*/cs1440-*-assn$_A ||
		    $URL =  git@gitlab.cs.usu.edu:*/cs1440-*-assn$_A.git ||
			$URL =  git@github.com:*/cs1440-*-assn$_A ||
			$URL =  git@github.com:*/cs1440-*-assn$_A.git ]]; then return 0
	else _tutr_generic_test -c git -n -d "$_REPO"
	fi
}

git_remote_add_hint() {
	case $1 in
		99)
			cat <<-:
			There is no $(_remote) called $(_origin).  Create it with
			  $(cmd git remote add origin NEW_URL).

			Replace $(cmd NEW_URL) in the above command with an address as
			described above (run $(cmd tutor hint) to review the instructions).

			:
			;;

		98)
			cat <<-:
			$(_origin) points to the address of MY repo, not YOURS!

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		97)
			cat <<-:
			The name you gave your repo is wrong - it still contains MY name.

			Your repository's name should include YOUR name and look like
			  $(bld cs1440-LASTNAME-FIRSTNAME-assn$_A)

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		96)
			cat <<-:
			This repository's name must end in $(bld "-assn$_A"), signifying that it
			is for Assignment #$_A.

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		94)
			cat <<-:
			This SSH address will not work because there is a slash $(bld "'/'") between the
			hostname $(ylw gitlab.cs.usu.edu OR github.com) and your username.  
			(Use $(cmd git remote -v) to see for yourself).

			Instead of a slash that character should be a colon $(bld "':'")

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		93)
			cat <<-:
			The hostname of the URL should be $(ylw gitlab.cs.usu.edu OR github.com).

			If you push your code to the wrong Git server it will not be submitted.

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		92)
			cat <<-:
			This repository's name must contain the course number $(bld cs1440), followed
			by a hyphen.  This associates this repo with this course.

			If its name includes the wrong course number it won't be graded!

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_HTTPS_URL)
			cat <<-:
			I will not allow you to use an HTTPS URL.  Trust me, they are not worth
			the hassle!

			If you are having promblems with your SSH key, contact the TAs or me
			$_EMAIL

			Use $(cmd git remote remove origin) to erase this and make an
			SSH URL that starts with $(bld git@)
			:
			;;

		$_NOT_SSH_URL)
			cat <<-:
			The URL must start with 'git@'.
			Otherwise, $(_Git) will be unable to talk to the server.

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_WRONG_SUBCOMMAND)
			cat <<-:
			$(cmd ${_CMD[1]}) is not the subcommand you need to use now.
			:
			;;
		*)
			_tutr_generic_hint $1 git "$_REPO"
			;;
	esac
	cat <<-:

	After you figure out what NEW_URL should be, use this command:
	  $(cmd git remote add origin NEW_URL)

	If it helps, run $(cmd git remote -v) to see $(_remote my) URL.
	Use $(cmd tutor hint) to review the instructions about the new URL.
	:
}

git_remote_add_epilogue() {
	cat <<-:
	$(_subcmd 9 remote)

	That was a big one, and you did awesome!

	Just one more subcommand to go!

	:
	_tutr_pressenter
}


# 20. git push & refresh your browser window
# There is no good way to rewind this action
# git_push_all_rw() { }
git_push_all_ff() {
	git push -u origin master
	# don't leave the cheat in the global .gitconfig
	git config --global --unset user.name
	git config --global --unset user.email
}

git_push_all_pre() {
	_NEW_URL=$(git remote get-url origin 2>/dev/null)
	git ls-remote origin &>/dev/null
	_REMOTE_ALREADY_EXISTS=$?
}

git_push_all_prologue() {
	if (( _REMOTE_ALREADY_EXISTS == 0 )); then
		cat <<-:
		Why is there already a repo on GitLab at
		  $(path $_NEW_URL)?

		Have you already done this lesson once before?

		You will need to do something about that repo before this step will
		work.  If you need help, I'm at $_EMAIL.

		-------------------------------------------------------------------

		:
	fi

	cat <<-:
	You are finally ready to push your work to GitLab.  This is how you will
	submit your work throughout the semester.

	$(cmd git push) is the command that does it.  Its syntax is:
	  $(cmd "git push [-u] REPOSITORY [--all]")

	In the place of the $(cmd REPOSITORY) argument you will write $(_origin).

	The first time you push your code up to GitLab you will use all of the
	options listed above, like this:
	  $(cmd "git push -u origin --all")

	Afterward, you can leave off $(cmd "-u origin --all") from the $(cmd push)
	subcommand (because $(bld lazy)).
	:

	local URL=$(git remote get-url origin 2>/dev/null)
	if [[ $URL == *"github.com"* ]]; then
		github_push_prepare_instructions
	fi
}

github_push_prepare_instructions() {
	local URL=$(git remote get-url origin 2>/dev/null)
	REPO_NAME=${URL%.git}
	REPO_NAME=${URL##*/}

	cat <<-:
	
	Because you are using GitHub, you must first create the repository online.

	Go to $(path https://github.com/new) and create a repository with the following:

	* Repository name: $(ylw $REPO_NAME)
	* 'Add a README' is $(bld UNCHECKED)
	* $(bld NO) repository template
	* $(bld .gitignore template: None)
	* $(bld License: None)

	I will open a web browser for you to this page.

	After you have done this, come back to the Shell Tutor, and you may push your work.
	:
	_tutr_open 'https://github.com/new'

}
git_push_all_test() {
	_NO_U=99
	_GH_NOT_CREATED=128
	if   [[ ${_CMD[@]} = 'git help push' ]]; then return $NOOP
	elif [[ ${_CMD[@]} = 'git remote' ]]; then return $NOOP
	elif [[ ${_CMD[@]} = 'git remote -v' ]]; then return $NOOP
	elif (( _RES == 0 )) && [[ ${_CMD[@]} = 'git push'* && ${_CMD[@]} != *'-u'* ]]; then return $_NO_U
	elif (( _RES == 0 )) && [[ ${_CMD[@]} = 'git push -u origin master' ]]; then return 0
	# Pushed to GitHub, repo not created on GitHub
	elif (( _RES == 128 )) && [[ 
		$(git remote get-url origin 2>/dev/null) == *"github.com"* &&
		${_CMD[@]} = 'git push'* &&
		${_CMD[@]} = *'origin'* ]]; then return $_GH_NOT_CREATED 
	else _tutr_generic_test -c git -a push -a -u -a origin -a --all -d "$_REPO"
	fi
}

git_push_all_hint() {
	case $1 in
		$_NO_U)
			cat <<-:
			Well, your code made it up to GitLab.  But without the $(cmd -u) option
			you've just created more work for yourself.  From now on, you'll need
			to repeat that entire command, $(cmd ${_CMD[@]}), $(bld every) time you
			want to push your work.

			A lazy programmer would rather say $(cmd git push) and be done with it.

			Do you have what it takes to be a great programmer?  Are you $(bld lazy) enough
			to hack it?

			I think you are that lazy.  And I'm enough of a stickler to make you go
			back and do it the right way.

			Run this command to proceed
			  $(cmd git push -u origin --all)
			:
			;;

		$STATUS_FAIL)
			cat <<-:
			$(cmd git push) failed unexpectedly.

			If the above error message includes the phrases $(red unable to access) or
			$(red Connection refused), there is an issue with your network connection.
			Ensure that you are connected to the internet and try again.

			If you are using campus WiFi, make sure you are on $(bld Eduroam) and $(red not)
			connected to $(blu USU Guest).

			If you were prompted for a password, this means that your SSH key is not
			on GitLab.  Double-check that your $(path ~/.ssh/id_rsa.pub) is in your profile.
			You may wish to re-run the previous lesson $(bld 5-ssh-key.sh).  Exit this lesson
			then run this command:
			  $(cmd MENU=yes ./tutorial.sh)

			If the error persists or is different, please contact $_EMAIL
			for help.  Copy the full command you ran with all its output.

			Otherwise, try running this command again:
			  $(cmd git push -u origin --all)
			:
			;;

		$_GH_NOT_CREATED)
			github_push_prepare_instructions
			cat <<-:
			Setup your repository on GitHub, then run this command to proceed
			  $(cmd git push -u origin --all)
			:
			;;
		*)
			_tutr_generic_hint $1 git "$_REPO"
			cat <<-:

			Run this command to proceed
			  $(cmd git push -u origin --all)
			:
			;;
	esac
}

git_push_all_epilogue() {
	_tutr_pressenter
	cat <<-:

	And that's how we roll at $(ylw DuckieCorp)!

	$(_subcmd 10 push)

	:

	_tutr_pressenter
	browse_repo
}



epilogue() {
	cat <<-EPILOGUE
	Before I let you go, switch over to your browser and see what your repo
	looks like on GitLab.

	Pretty slick, eh?

	(If your browser didn't open automatically, copy & paste the URL that
	printed above this message)

	EPILOGUE

	_tutr_pressenter

	cat <<-EPILOGUE

	${_G}  _____                        __       __     __  _
	${_G} / ___/__  ___  ___ ________ _/ /___ __/ /__ _/ /_(_)__  ___  ___
	${_G}/ /__/ _ \\/ _ \\/ _ \`/ __/ _ \`/ __/ // / / _ \`/ __/ / _ \\/ _ \\(_-<
	${_G}\\___/\\___/_//_/\\_, /_/  \\_,_/\\__/\\_,_/_/\\_,_/\\__/_/\\___/_//_/___/
	${_G}              /___/

	That was a big lesson!  $(bld "w00t!")

	You have joined the ranks of the $(grn "1337 Unix h4X0rZ!")

	Now don't go do something that makes the NSA pay attention to you.

	EPILOGUE

	_tutr_pressenter

	cat <<-EPILOGUE

	In this lesson you learned how to

	* Prepare Git on your computer
	* Ask Git for help about its commands
	* Clone a Git repository onto your computer
	* Check the status of your repository
	* Change a file and commit it to the repository
	* View the Git log
	* Submit your homework to GitLab

	$(bld "Don't do anything with the repo that you just cloned and pushed;")
	$(bld you need it for the last lesson.)

	      $(blk ASCII art credit: Christopher Johnson, Fog \& Veronica Karlsson)
	EPILOGUE

	_tutr_pressenter
}

cleanup() {
	_tutr_lesson_complete_msg $1
}



source main.sh && _tutr_begin \
	git_help \
	git_help_help \
	git_config \
	git_status0 \
	cd_dotdot0 \
	git_status1 \
	git_clone \
	cd_into_repo \
	git_status2 \
	edit_readme0 \
	git_status3 \
	git_restore \
	git_status4 \
	git_add0 \
	git_status5 \
	git_commit0 \
	git_log0 \
	git_status6 \
	git_remote_v \
	git_remote_rename \
	git_remote_add \
	git_push_all \


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
