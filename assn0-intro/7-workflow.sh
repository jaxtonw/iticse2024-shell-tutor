#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=40

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

# The assignment number of the next assignment
_A=0

# Name of the starter code repo
_REPONAME=cs1440-assn$_A
_REPONAME_L=cs1440-falor-erik-assn$_A

source ansi-terminal-ctl.sh
# This function is named `_Git` to avoid clashing with Zsh's `_git`
_Git() { (( $# == 0 )) && echo $(blu Git) || echo $(blu $*); }
_local() { (( $# == 0 )) && echo $(ylw local) || echo $(ylw $*); }
_remote() { (( $# == 0 )) && echo $(cyn remote) || echo $(cyn $*); }
_GitLab() { (( $# == 0 )) && echo $(cyn GitLab) || echo $(cyn $*); }
_origin() { (( $# == 0 )) && echo $(red origin) || echo $(red $*); }
_md() { (( $# == 0 )) && echo $(blu Markdown) || echo $(blu $*) ; }
_code() { (( $# == 0 )) && echo $(cyn code) || echo $(cyn "$*"); }
_py() { (( $# == 0 )) && echo $(grn Python) || echo $(grn $*) ; }
_duckie() { (( $# == 0 )) && echo $(ylw DuckieCorp) || echo $(ylw $*) ; }
source progress.sh
if [[ -n $_TUTR ]]; then
	source editors+viewers.sh
	source generic-error.sh
	source git.sh
	source noop.sh
	source open.sh
	source platform.sh

	# make sure realpath(1) or an equivalent is available
	which realpath &>/dev/null || source realpath.sh

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


_repo_missing() {
	cat <<-:
	I could not find the starter code repository you cloned in the previous
	lesson $(bld 6-git.sh).  This lesson cannot continue without it.

	It should be in the parent directory and be named either
	$(path $_REPONAME_L) or $(path $_REPONAME).

	If that repository exists but is under a different name, rename it back
	to $(path $_REPONAME_L) or $(path $_REPONAME) with $(cmd "mv [OLD] [NEW]").
	Then restart this lesson.

	If you have gotten this message in error, please contact
	$_EMAIL for help.
	:
}

_repo_bad_origin() {
	(( $# != 1 )) && _tutr_die echo Usage: _repo_missing DIRECTORY
	cat <<-:
	I found a $(_Git) repository at the path
	  $(path $1),
	but its $(_origin) remote is not set up as it should have been at by end of
	the previous lesson $(bld 6-git.sh).

	To fix it, you can delete and re-clone that repository from your account
	on $(_GitLab).

	If you need help, please contact $_EMAIL.
	:

}

_origin_not_eriks() {
	(( $# != 1 )) && _tutr_die echo Usage: _origin_not_eriks DIRECTORY
	( # create a sub shell to not leave the tutorial in the wrong PWD
		cd "$1"
		[[ $(git remote get-url origin) != *erik.falor* ]]
	)
}

_python3_not_found() {
	cat <<-PNF
	I could not find a working Python 3 interpreter on your computer.
	It is required for this lesson.

	Contact $_EMAIL for help
	PNF
}


_tutr_lesson_statelog_global() {
	_TUTR_STATE_CODE= # We don't have a meaningful and general state code yet...
	_TUTR_STATE_TEXT=$(_tutr_git_default_text_statelog $_REPO_PATH)
}


setup() {
	source screen-size.sh 80 35

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh
	_tutr_assert_program_exists git
	_tutr_assert_program_exists nano
	_tutr_assert_program_exists less

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
	local _LONG="$_PARENT/$_REPONAME_L"
	local _SHORT="$_PARENT/$_REPONAME"
	export _REPO="$_SHORT"

	# Bail out unless the last lesson was completed AND the starter code
	# repo exists AND has an 'origin' that DOES NOT point back to my account
	# Otherwise, note where that repo is located
	if [[ ! -d "$_LONG/.git" && ! -d "$_SHORT/.git" ]]; then
		_tutr_die _repo_missing
	elif [[ -d "$_SHORT/.git" ]]; then
		if ! _origin_not_eriks "$_SHORT"; then
			_tutr_die _repo_bad_origin "$_SHORT"
		fi
	elif [[ -d "$_LONG/.git" ]]; then
		if ! _origin_not_eriks "$_LONG"; then
			_tutr_die _repo_bad_origin "$_LONG"
		fi
	fi

	if   which python &>/dev/null && [[ $(python -V 2>&1) = "Python 3"* ]]; then
		export _PY=python
	elif which python3 &>/dev/null && [[ $(python3 -V 2>&1) = "Python 3"* ]]; then
		export _PY=python3
	else
		_tutr_die _python3_not_found
    fi
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #7: The lesson that really tied the room together

	This lesson uses all of the skills you learned throughout the tutorial,
	and takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}


# Rename the starter code repo from cs1440-falor-erik-assn1 to cs1440-assn1
rename_repo_rw() {
	command mv $_REPONAME $_REPONAME_L
	cd "$_BASE"
}

rename_repo_ff() {
	cd "$_PARENT"
	command mv $_REPONAME_L $_REPONAME
}

rename_repo_pre() {
	export _SRC=$_REPONAME_L
}

rename_repo_prologue() {
	cat <<-:
	Go up and out of this directory and rename your starter code repo from
	  $(path $_REPONAME_L)
	to
	  $(path $_REPONAME)
	:
}

# If they name the repo the wrong thing, try to guide them back
rename_repo_test() {
	_TARGET_IS_NOT_GIT_REPO=99
	_INCORRECT_DEST=98
	if   [[ -d "$_REPO/.git" ]]; then return 0
	elif [[ -d "$_REPO" ]]; then return $_TARGET_IS_NOT_GIT_REPO
	elif [[ ${_CMD[0]} == mv && ${_CMD[1]} == *$_SRC && $_RES == 0 ]]; then
		_SRC=${_CMD[2]}
		return $_INCORRECT_DEST
	elif [[ "$PWD" != "$_PARENT" ]]; then return $WRONG_PWD
	elif _tutr_noop cd; then return $NOOP
	else _tutr_generic_test -c mv -a "$_SRC|$_SRC/" -a "$_REPONAME|$_REPONAME/"
	fi
}

rename_repo_hint() {
	case $1 in
		$NOOP) ;;
		$WRONG_PWD) _tutr_minimal_chdir_hint "$_PARENT" ;;
		$_TARGET_IS_NOT_GIT_REPO)
			cat <<-:
			Something has gone wrong and the directory $(path $_REPONAME) is not a
			$(_Git) repository.

			The lesson cannot proceed until this is fixed.  If you need help
			with this, please reach out to $_EMAIL.
			:
			;;

		$_INCORRECT_DEST)
			cat <<-:
			Oops!  It looks like you renamed $(path ${_CMD[1]})
			to
			  $(path ${_CMD[2]})
			instead of
			  $(path $_REPONAME).

			That's okay, you can always try again.  This time, try:
			  $(cmd mv $_SRC $_REPONAME)
			:
			;;

		*)
			_tutr_generic_hint $1 mv "$_PARENT"
			cat <<-:

			Rename the starter code repo $(path $_SRC)
			to
			  $(path $_REPONAME)
			:
			;;
	esac
}



# cd into the repo
cd_repo_rw() {
	cd "$_PARENT"
}

cd_repo_ff() {
	cd "$_REPO"
}

cd_repo_prologue() {
	if [[ $PWD == $_BASE ]]; then
		cat <<-:
		Change into the starter code repository at $(path ../$(basename "$_REPO"))
		:
	else
		cat <<-:
		Now change into directory you just renamed.
		:
	fi
}

cd_repo_test() {
	[[ "$PWD" == "$_REPO" ]] && return 0
	return $WRONG_PWD
}

cd_repo_hint() {
	_tutr_generic_hint $1 cd "$_REPO"
}



ls0_pre() {
	_tutr_git_repo_https_url
	export _REPO_HTTPS=$REPLY
	browse_repo
}

ls0_prologue() {
	cat <<-:
	I'm opening your repository on $(_GitLab) in a browser tab (if it doesn't
	come up, browse directly to $(path $_REPO_HTTPS)).

	Run $(cmd ls) in the terminal and compare the files and folders here with what
	you can see on the $(_GitLab) webpage.
	:

	if [[ -n $ZSH_NAME ]]; then
		cat <<-:

		(You may see some extra output that looks like this:
		  $(cmd 'done \$_OPEN \$1 < /dev/null > /dev/null 2> /dev/null')
		...just ignore it)
		:
	fi
}

ls0_test() {
	_tutr_generic_test -c ls -x -d "$_REPO"
}

ls0_hint() {
	_tutr_generic_hint $1 ls "$_REPO"
}

ls0_epilogue() {
	_tutr_pressenter

	cat <<-:

	You will notice that the same files and directories that $(cmd ls) shows here
	in the terminal are also on $(_GitLab) (with the small exception of
	$(path .gitignore), which is not hidden on the website).  At this moment
	both the $(_local) and $(_remote) repositories are identical to each
	other.  As you work in this repository on your computer, it will become
	different from the remote repository on $(_GitLab).

	In this lesson you will make several commits on this computer and push
	them up to $(_GitLab).

	Get in the habit of $(bld frequently) checking $(_GitLab) to make sure that all of
	your pushes arrive just as you expect.  $(bld We can only grade what you push)
	$(bld to) $(_GitLab), so you should always know what state your $(_remote remote repository)
	is in!

	:

	_tutr_pressenter
}



## Generic test for the VIEW FILE steps
# Usage: view_GENERIC_test absolute_filename
view_GENERIC_test() {
	local dirname=$(dirname "$1")
	local basename=$(basename "$1")
	if [[ -n $DEBUG ]]; then
		cat <<-:
		DEBUG|
		DEBUG| view_GENERIC_test():
		DEBUG|   filename = '$1'
		DEBUG|   basename = '$basename'
		DEBUG|   dirname  = '$dirname'
		DEBUG|
		:
	fi

	if _tutr_is_viewer && (( _RES == 0 )); then
		[[ "$1" == "$(realpath ${_CMD[1]})" ]] && return 0
		_tutr_generic_test -c ${_CMD[0]} -a "$basename" -d "$dirname"
	else
		_tutr_generic_test -c less -a "$basename" -d "$dirname"
	fi
}


# look at instructions/README.md both in browser and terminal
view_instructions_rw() {
	cd "$_REPO"
}

view_instructions_ff() {
	cd "$_REPO/instructions"
}

view_instructions_prologue() {
	cat <<-:
	Take a closer look at the contents of the $(path instructions) directory.
	Specifically, I want you to look at $(_md instructions/README.md)
	both with $(cmd less) in the terminal and in your browser.
	:
}

view_instructions_test() {
	view_GENERIC_test "$_REPO/instructions/README.md"
}

view_instructions_hint() {
	_tutr_generic_hint $1 less "$_REPO/instructions"

	cat <<-:

	Look at the file $(_md README.md) in the $(path instructions) directory.
	:
}

view_instructions_epilogue() {
	cat <<-:
	Don't you think those instructions look better on the web?

	$(_GitLab) renders $(_md) files into easy-to-read webpages.  $(_md)'s
	simplicity in plain-text writing and HTML conversion gives it a big
	advantage over other document languages such as HTML.

	At $(_duckie) you will write all project documentation in $(_md).

	:
	_tutr_pressenter
}



# look at instructions/Markdown.md both in browser and terminal
view_markdown_md_rw() {
	cd "$_REPO/instructions"
}

view_markdown_md_ff() {
	cd "$_REPO/instructions"
}

view_markdown_md_prologue() {
	cat <<-:
	$(_md) is very easy to learn, and I think you will enjoy it.  You only
	need to know a handful of patterns to use it effectively.

	Look for a file under $(path instructions) named $(_md Markdown.md).  Open it in $(cmd less)
	as well as your browser.  This will help you see how each part of the
	document appears on the web.

	You'll notice that this document repeats itself.  This is intentional.
	  * The $(bld first passage) is converted by $(_GitLab) into pretty HTML
	  * and the $(bld second) shows the corresponding source code
	:
}


view_markdown_md_test() {
	view_GENERIC_test "$_REPO/instructions/Markdown.md"
}

view_markdown_md_hint() {
	_tutr_generic_hint $1 less "$_REPO/instructions"

	cat <<-:

	Look at the file $(_md Markdown.md) in the $(path instructions) directory.
	:
}



# navigate to ../doc; view Plan.md
# view Plan.md in both browser and terminal
# Notice how Markdown features are used in DuckieCorp documentation

view_plan_rw() {
	cd "$_REPO/instructions"
}

view_plan_ff() {
	cd "$_REPO/doc"
}

view_plan_prologue() {
	cat <<-:
	Now that you've seen how a few document features are achieved in
	Markdown, go up and over into $(path doc) and look closely at $(_md Plan.md).
	Pay attention to the places where I use:

	  * Headings
	  * Bold text
	  * Italicized text
	  * Bulleted list
	:
}

view_plan_test() {
	view_GENERIC_test "$_REPO/doc/Plan.md"
}

view_plan_hint() {
	_tutr_generic_hint $1 less "$_REPO/doc"

	cat <<-:

	Look at the file $(_md Plan.md) in the $(path doc) directory.
	:
}

view_plan_epilogue() {
	cat <<-:
	Does that make sense?

	Now it's your turn to write some $(_md)!

	:
	_tutr_pressenter
}




edit_readme_rw() {
	git restore "$_REPO/README.md"
	cd "$_REPO/doc"
}

edit_readme_ff() {
	cd "$_REPO"
	cat <<-':' > "$_REPO/README.md"
	# A first level-heading

	## A second level heading

	This paragraph contains **bold** text for your enjoyment.

	*   This is a bulleted list
	*   The Software Development Plan (`Plan.md`) describes the process you followed
	*   The Spring Signature (`Sprint.md`) records how you spent your time
	*   Other documentation you are asked to create for the project is placed in this directory

	```
	Pre-formatted code blocks
	look like this
	```
	:
}

edit_readme_prologue() {
	cat <<-:
	Navigate back to the top directory of the repository (i.e. where the
	directories $(path doc), $(path instructions) and $(path src) are located) and open the file
	$(_md README.md) in $(cyn Nano).

	Add following $(_md) features to this file:

	  * Headings (both $(bld level 1) and $(bld level 2))
	  * $(bld Bold) text
	  * $(bld Bulleted list)
	  * $(bld Inline code) (not a code block)
	  * $(bld Pre-formatted) block (a.k.a. a code block)
	:
}

edit_readme_test() {
	_H1=99
	_H2=98
	_BOLD=97
	_BLIST=96
	_INLINE=95
	_BLOCK=94
	_CHANGE=93
	_README_MISSING=92
	_UNBALANCED_BACKTICKS=91
	_UNBALANCED_TILDES=90

	[[ "$PWD" != "$_REPO" ]] && return $WRONG_PWD
	[[ ! -f "$_REPO/README.md" ]] && _tutr_file_clean README.md && return $_README_MISSING
	_tutr_file_clean README.md && return $_CHANGE

	# what about tabs?
	command grep -qE '^#[ 	]..*$' README.md
	local need_h1=$?
	command grep -qE '^##[ 	]..*$' README.md
	local need_h2=$?
	command grep -qE '\*\*.*\*\*' README.md
	local need_bold=$?
	command grep -qE '^\*[  ]..*$|^\+[  ]..*$|^-[    ]..*$' README.md
	local need_blist=$?
	command grep -qE '`..*`' README.md
	local need_inline=$?

	#count backtick fences separately from tilde fences
	local backtick_fences=$(grep -cE '^```' README.md)
	local tilde_fences=$(grep -cE '^~~~' README.md)

	if   (( need_h1 )); then return $_H1
	elif (( need_h2 )); then return $_H2
	elif (( need_bold )); then return $_BOLD
	elif (( need_blist )); then return $_BLIST
	elif (( need_inline )); then return $_INLINE
	elif (( backtick_fences == 0 && tilde_fences == 0 )); then return $_BLOCK
	elif (( backtick_fences % 2 != 0 )); then return $_UNBALANCED_BACKTICKS
	elif (( tilde_fences % 2 != 0 )); then return $_UNBALANCED_TILDES
	elif (( ( need_h1 & need_h2 & need_bold & need_blist & need_inline ) == 0)); then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c nano -a README.md -d "$_REPO"
	fi
}

edit_readme_hint() {
	case $1 in
		$_H1)
			cat <<-:
			Add a level 1 heading to $(_md README.md), and save the file.

			This is done with a line that begins with a single $(_code "#").
			Make sure there is a space between the $(_code "#") and the text that follows.
			:
			;;

		$_H2)
			cat <<-:
			Add a level 2 heading to $(_md README.md), and save the file.

			This is done with a line that begins with two $(_code "##")s.
			Make sure there is a space between the $(_code "##")s and the text that follows.
			:
			;;

		$_BOLD)
			cat <<-:
			Add some text to $(_md README.md) that will come out in $(bld bold).

			Surround one or more words with $(bld two asterisks) $(_code "**").

			Make sure that there is no blank space between the $(_code "**")s, and that the $(_code "**")s
			touch the words they are making bold.

			Not this:

			  $(_code "** this is wrong **")
			  $(_code "**this is wrong **")
			  $(_code "** this is wrong**")
			  $(_code "* *this is wrong* *")

			But like this:
			  $(_code "**this is right**")

			:
			;;

		$_BLIST)
			cat <<-:
			Add a $(bld bulleted list) to $(_md README.md).

			Begin a line with an asterisk $(_code "*"), followed by a $(bld space) and $(bld some text).
			The first bullet should be on the left margin (i.e., not indented).
			:
			;;

		$_INLINE)
			cat <<-:
			Write some text in $(_md README.md) that will present as inline $(bld code).

			Surround one or more words with $(bld backticks) $(_code '`').  A backtick is the quote
			mark that shares a key with the tilde $(_code '~').
			:
			;;

		$_BLOCK)
			cat <<-:
			Add a pre-formatted block (a.k.a. code block) to $(_md README.md).

			Start two lines with triple backticks $(_code '```') and insert some text in
			between those lines.  It is important that the backticks are all
			together, and all the way at the left margin (i.e., not indented).
			These special lines are called "fences".

			You can add the name of a programming language after the first fence,
			like this:

			$(_code '```python')

			If $(_GitLab) knows about that language, it will apply syntax highlighting
			to your code block.  If $(_GitLab) doesn't recognize that programming
			language, it will just show up as an ordinary pre-formatted block.
			:
			;;

		$_UNBALANCED_BACKTICKS)
			cat <<-:
			There are an odd number of backtick fences $(_code '```') in your file.

			This confuses Markdown because it appears like you have started a pre-
			formatted block but not finished it.  It's the same problem you get in
			Python when you leave parentheses or quote marks unbalanced.

			Go back into the file and make sure that all of your backtick fences are
			three characters long and come in pairs.
			:
			;;

		$_UNBALANCED_TILDES)
			cat <<-:
			There are an odd number of tilde fences $(_code '~~~') in your file.

			This confuses Markdown because it appears like you have started a pre-
			formatted block but not finished it.  It's the same problem you get in
			Python when you leave parentheses or quote marks unbalanced.

			Go back into the file and make sure that all of your tilde fences are
			three characters long and come in pairs.
			:
			;;

		$_CHANGE)
			cat <<-:
			You need to change $(_md README.md) to proceed.
			Did you forget to save it in your editor?

			Add these $(_md) features to the file:
			  * Headings (both $(bld level 1) and $(bld level 2))
			  * $(bld Bold) text
			  * $(bld Bulleted list)
			  * $(bld Inline code) (not a code block)
			  * $(bld Pre-formatted) block (a.k.a. a code block)

			Refer back to $(_md instructions/Markdown.md) for syntax guidance.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO"
			;;

		$_README_MISSING)
			cat <<-:
			The fact that you deleted $(_md README.md) in the last lesson doesn't
			matter to $(cyn Nano).  Just run $(cyn Nano) the same way as if that file
			existed:
			  $(cmd nano README.md)

			$(_md README.md) will be re-created when you save and exit $(cyn Nano).
			:
			;;

		*)
			_tutr_generic_hint $1 nano "$_REPO"

			cat <<-:

			Edit $(path README.md) and add these $(_md) features:
			  * Headings (both $(bld level 1) and $(bld level 2))
			  * $(bld Bold) text
			  * $(bld Bulleted list)
			  * $(bld Inline code) (not a code block)
			  * $(bld Pre-formatted) block (a.k.a. a code block)

			Refer back to $(_md instructions/Markdown.md) for guidance on syntax.
			:
			;;
	esac
}

edit_readme_epilogue() {
	cat <<-:
	Sweet!

	:
	_tutr_pressenter
}




# git add, git commit, git push
push_readme_rw() {
	git reset HEAD~
	git push -f origin master
}

push_readme_ff() {
	git commit -am "automatic commit - README.md now has Markdown"
	git push origin master
}

push_readme_pre() {
	_COMMIT=$(git rev-parse master)
}

push_readme_prologue() {
	cat <<-:
	$(cmd git add), $(cmd git commit), and $(cmd git push) this change to $(_md README.md).
	:
}

push_readme_test() {
	_UNSTAGED=99
	_STAGED=98
	_BRANCH_AHEAD=97
	_ENCOURAGEMENT=96
	_NEW_COMMIT=$(git rev-parse master)

	[[ "$PWD" != "$_REPO" ]] && return $WRONG_PWD
	_tutr_file_unstaged README.md && return $_UNSTAGED
	_tutr_file_staged   README.md && return $_STAGED
	_tutr_branch_ahead            && return $_BRANCH_AHEAD
	if ! _tutr_branch_ahead && [[ $_COMMIT != $_NEW_COMMIT ]]; then
		_COMMIT=$_NEW_COMMIT
		return 0
	fi
	return $_ENCOURAGEMENT
}

push_readme_hint() {
	case $1 in
		$_UNSTAGED)
			cat <<-:
			Prepare your changes for commit by running $(cmd git add README.md).
			:
			;;

		$_STAGED)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save your changes in the
			$(_Git) repository.
			:
			;;

		$_BRANCH_AHEAD)
			cat <<-:
			Now run $(cmd git push) to send your code up to the $(_GitLab) server.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO"
			;;

		*)
			cat <<-:
			The steps of your $(_Git) workflow are
			  0. $(cmd git add FILENAME)
			  1. $(cmd 'git commit -m "Brief commit message"')
			  2. $(cmd git push)

			Why don't you take a small step away from the keyboard and think about
			what you need to do to proceed in the lesson.
			:
			;;

	esac
}

push_readme_epilogue() {
	_tutr_pressenter

	cat <<-':'

	Always watch for the receipt that is printed after you push:

	***********************************************************************
	*           __  ________  __  _____                ____    _          *
	*          / / / / __/ / / / / ___/__  __ _  ___  / __/___(_)         *
	*         / /_/ /\ \/ /_/ / / /__/ _ \/  ' \/ _ \_\ \/ __/ /          *
	*         \____/___/\____/  \___/\___/_/_/_/ .__/___/\__/_/           *
	*                                         /_/                         *
	*  ,/         \,                                                      *
	* ((__,-"""-,__))                                                     *
	*  `--)~   ~(--`                                                      *
	* .-'(       )'-,                                                     *
	* `--`d\   /b`--`  Big Blue says:                                     *
	*     |     |                                                         *
	*     (6___6)  Your submission arrived Sat 16 Jul 2022 18:39:59 MDT   *
	*      `---`                                                          *
	*                                                                     *
	***********************************************************************

	:
	_tutr_pressenter

	cat <<-:

	If you $(bld "don't") see this receipt, there is a possibility that you have
	pushed your code to $(bld another Git server) (students have done this before).
	If I can't find your code on my sever, $(bld "I can't grade it").

	Assignments are due before $(bld midnight) as judged by the clock on $(bld this)
	$(_GitLab) server.  It doesn't matter if it is running faster than the clock
	on your laptop, your microwave, your phone, or the official atomic clock
	at the Naval Observatory.  $(bld This clock) is the $(bld sole arbiter) of lateness at
	$(_duckie).

	:
	_tutr_pressenter
}



git_log0_prologue() {
	cat <<-:
	After you push, it is always a good idea to look at the repository over
	on $(_GitLab) to make sure that everything you expected to send actually
	arrived there.  If you get in this habit you can $(bld avoid a lot of stress)
	in your life, believe me!

	(If you have closed your browser, you can run the $(cmd browse_repo) command
	or paste this URL into your browser:
	  $(path $_REPO_HTTPS))

	Once you're on $(_GitLab), I want you to compare the $(ylw_ commit ID) shown near
	the upper-left corner of the webpage with the $(ylw_ commit ID) shown at the top
	of the $(cmd git log).  (Remember, these are the big, long numbers that look
	like $(ylw_ $(git rev-parse HEAD))).

	:

	_tutr_pressenter

	cat <<-:

	Keep these things in mind when you run $(cmd git log):

	* If you can't see the top line of the log, you have run into a quirk of
	  the $(cmd less) pager.  Press $(kbd G) followed by $(kbd g) to make it come back.

	* All of the files that you have $(cmd git add)ed and $(cmd git commit)ted should look
	  the same on $(_GitLab) as they do here on $(_local your computer).

	* Check that the first 7-8 characters of the top commit ID in the log
	match the latest commit on $(_GitLab).

	Run $(cmd git log) and make sure both repos are the same.
	:
}

git_log0_test() {
	_tutr_generic_test -c git -a log -d "$_REPO"
}

git_log0_hint() {
	_tutr_generic_hint $1 "git log" "$_REPO"
}



# Navigate ../src, view plotter.py in nano and browser and assert `_tutr_file_clean plotter.py`
# Remark about line numbers and syntax highlighting in GitLab for
#   source code files.  GitLab just autodetects this based on filename
view_plotter_py_rw() {
	cd "$_REPO"
}

view_plotter_py_ff() {
	cd "$_REPO/src"
}

view_plotter_py_prologue() {
	cat <<-:
	It's time to get down to business.  There is a $(_py) program called
	$(_py plotter.py) up in the $(path src/) directory.  Go into that directory and look at
	that program with the $(cmd less) file viewer.

	While you're looking at it over here, navigate to the same file on
	$(_GitLab) and have a look at it on the web.

	What differences can you see?
	:
}

view_plotter_py_test() {
	_CHANGED=99
	_STAGED=98

	## [[ "$PWD" != "$_REPO/src" ]] && return $WRONG_PWD
	_tutr_file_unstaged src/plotter.py && return $_CHANGED
	_tutr_file_staged src/plotter.py && return $_STAGED
	view_GENERIC_test "$_REPO/src/plotter.py"
}

view_plotter_py_hint() {
	case $1 in
	   ## $WRONG_PWD)
	   ## 	_tutr_minimal_chdir_hint "$_REPO/src"

	   ## 	cat <<-:

	   ## 	Then, when you get there, look at $(_py plotter.py) in the $(cmd less) viewer.
	   ## 	:
	   ## 	;;

		$_CHANGED)
			cat <<-:
			No, don't edit this file!

			You'd better put it back to the way it was before.  Undo your changes
			  $(cmd git restore plotter.py)
			and look again.  And this time $(bld look), and $(bld "don't touch")!
			:
			;;

		$_STAGED)
			cat <<-:
			Whoa, what are you trying to do?

			Now isn't the time for committing changes!  You are just supposed
			to be $(bld looking) at this file.  You'll change it later.

			Undo this with $(cmd git restore --staged plotter.py) and
			$(cmd git restore plotter.py).
			:
			;;
		*)
			_tutr_generic_hint $1 less "$_REPO/src"
			cat <<-:

			Have a look at the program on $(_GitLab) and with $(cmd less plotter.py).
			:
			;;
	esac
}

view_plotter_py_epilogue() {
	cat <<-:
	Hopefully there are $(bld NO) differences in the source code between here
	and $(_GitLab)!

	Notice that $(_GitLab) displays this $(_py Python) file with syntax highlighting.
	$(_GitLab) does this automatically for the dozens of programming languages
	that it recognizes.  This file got this special treatment because its
	name ends in $(_py .py).

	$(_GitLab) also puts $(bld line numbers) in the left margin.  They make it $(bld much)
	easier for you to direct others to a specific part of a program.  If you
	click on a line number, the browser updates the URL in the address bar
	to include it.  Then, when you share that address (say, with a TA when
	you ask a question), they'll see the relevant part of the file, already
	highlighted for them ($(bld hint, hint)).

	:
	_tutr_pressenter
}



run_plotter_py0_prologue() {
	if [[ "$PWD" != "$_REPO/src" ]]; then
		cat <<-:
		For this step you $(bld really) need to go into the $(path src) directory.

		Once there, run $(_py plotter.py) to see if it even works.
		:
	else
		cat <<-:
		While you're here, you might as well run the program to see if it even
		works.

		  $(cmd $_PY plotter.py)
		:
	fi
}

run_plotter_py0_test() {
	_tutr_generic_test -c $_PY -a plotter.py -d "$_REPO/src"
}

run_plotter_py0_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO/src"
}

run_plotter_py0_epilogue() {
	cat <<-:
	Do you remember the instructions for this program?  These plots don't
	resemble the examples from $(_md instructions/README.md).

	It looks like you've found a $(red bug)!

	Before you get all excited and try to fix it, $(cyn cool your jets).
	You're going to take it slow and do this the $(_duckie) way.

	:
	_tutr_pressenter
}



edit_plan_md0_rw() {
	git reset HEAD~
	git push -f origin master
	_COMMIT=$(git rev-parse master)
}

edit_plan_md0_ff() {
	sed -i -e '/Phase 3: Testing/a\Made an edit for step edit_plan_md0' "$_REPO/doc/Plan.md"
	git commit -am "Automatic commit: phase 3 of doc/Plan.md"
	git push origin master
	_COMMIT=$(git rev-parse master)
}

edit_plan_md0_pre() {
	_COMMIT=$(git rev-parse master)
}

edit_plan_md0_prologue() {
	cat <<-:
	How many times have you "fixed" a $(red bug) in one of your programs, only to
	create a $(bld cascade) of other problems?  And then, several hours later and
	much to your dismay, you realize that you are in an $(bld even worse) place
	than you were at the beginning?

	I've been here, too, more times than I care to admit.

	From my experience, this is how most professional software engineers go
	about their work.  As frustrating an experience this is for all of us,
	it amazes me that more programmers don't quit and start a new career!

	But it doesn't have to be like this for you.  You are still new enough
	to form $(bld better problem-solving) habits.  It will be hard at first, but I
	promise that it is $(bld worth it).

	:

	_tutr_pressenter

	cat <<-:

	Before you start hacking on the code, pause and think $(bld carefully) about
	what you are trying to do.  Ask yourself these questions:

	  0. Do I really know what this code is $(bld supposed to do)?

	  1. Am I sure that this program isn't already doing the $(bld right thing)?

	  2. What does the $(bld right thing) even look like?

	  3. Assuming that I know what the program $(bld should do), can I point to
	     the lines that are wrong?

	  4. If I am able to point to the problem, do I even know what $(bld '"better"')
	     code would look like?

	:

	_tutr_pressenter

	cat <<-:

	Now, I know how obvious and stupid these questions appear.  Especially
	question #1.  But you skip them at your own peril.  I can't tell you $(bld how)
	$(bld many times) I had convinced myself that I found a $(red serious bug), only to
	learn later that the program was correct all along, and that the bug was
	in my assumptions.

	Then I got to go back and $(bld undo) the precious fix I spent days writing.

	I've since learned that good code does not come from instinct.  It takes
	$(cyn careful thought), not a $(ylw feeling in your gut).  You are not going to get it
	right if you don't $(red stop) and $(bld think).  Answering these questions makes you
	do that.

	:

	_tutr_pressenter

	cat <<-:

	Before you attempt to "$(bld fix)" the program, first slow down a little
	bit and write about it in the software development $(_md Plan.md).

	Describe in your own words what the program $(bld actually did), and contrast
	that with what you think it $(bld should have done).  If you struggle to put
	these thoughts into plain English, how do you expect to explain it to
	the computer?

	So, return to $(path ../doc) and edit $(_md Plan.md).

	Write words under the section titled $(bld "Phase 3: Testing & Debugging").

	Finally, $(cmd git add), $(cmd git commit) and $(cmd git push) your remarks.
	:
}

edit_plan_md0_test() {
	_CLEAN=95
	_UNSTAGED=99
	_STAGED=98
	_BRANCH_AHEAD=97
	_ENCOURAGEMENT=96
	_NEW_COMMIT=$(git rev-parse master)

	[[ "$PWD" != "$_REPO/doc" ]] && return $WRONG_PWD
	if ! _tutr_branch_ahead && [[ $_COMMIT != $_NEW_COMMIT ]]; then
		_COMMIT=$_NEW_COMMIT
		return 0
	fi
	! _tutr_branch_ahead && _tutr_file_clean doc/Plan.md && return $_CLEAN
	_tutr_file_unstaged doc/Plan.md && return $_UNSTAGED
	_tutr_file_staged   doc/Plan.md && return $_STAGED
	_tutr_branch_ahead            && return $_BRANCH_AHEAD
	return $_ENCOURAGEMENT
}

edit_plan_md0_hint() {
	case $1 in
		$_CLEAN)
			cat <<-:
			Good, you're here!

			Now edit $(_md Plan.md).  Write your thoughts under the section titled
			$(bld "Phase 3: Testing & Debugging").
			:
			;;

		$_UNSTAGED)
			cat <<-:
			Prepare your changes for commit by running $(cmd git add Plan.md).
			:
			;;

		$_STAGED)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save your changes in the
			$(_Git) repository.
			:
			;;

		$_BRANCH_AHEAD)
			cat <<-:
			Now run $(cmd git push) to send your code up to $(_GitLab).
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/doc"
			;;

		*)
			cat <<-:
			The steps of your $(_Git) workflow are
			  0. $(cmd git add FILENAME)
			  1. $(cmd 'git commit -m "Brief commit message"')
			  2. $(cmd git push)

			Why don't you take a small step away from the keyboard and think about
			what you need to do to proceed in the lesson.
			:
			;;
	esac
}

edit_plan_md0_epilogue() {
	_tutr_pressenter

	cat <<-:

	You probably think I'm asking you to slow to a crawl.
	But you don't yet know what $(ylw fast) really is.

	Once you stop wasting hours upon hours chasing your tail, you will.

	:

	_tutr_pressenter
}



# navigate to ../src;  edit plotter.py & assert `_tutr_file_unstaged plotter.py`
fix_plotter_py_prologue() {
	cat <<-:
	Do you feel clear about what needs to happen?

	Probably not, because you haven't really spent any time with this
	program.  You have only a vague notion about what it does and how it
	might work.  In real life, this is the part of the process where you
	would spend the most time.  You would read and re-read the program,
	while running it and observing where interesting things happen.

	When I began coding, I wasn't aware of how much time I would spend
	reading.  Reading code, reading books, reading websites; it adds up to a
	significant part of your workday.  Programmers are $(bld always) reading.  The
	part where you actually write code... isn't a very big part of your day.

	Anyway, we'll talk about this later.  I'll just give you the answer to
	this problem so you can get a move on.

	:

	_tutr_pressenter

	cat <<-:

	This program only prints asterisks, but never prints spaces!
	Look at the part of the program that begins on line 16:

	  $(_code "if l == line:")
	      $(_code "print('*', end='')")

	Instead of doing $(bld nothing) when $(_code "l != line"), it should print a $(bld space).

	Add these two lines right below that $(_code if) statement in $(_py plotter.py):
	  $(_code "else:")
	      $(_code "print(' ', end='')")

	Be sure to match the $(bld indentation) with its surroundings.  Use $(bld 4) spaces
	per level of indentation, and not tabs ($(_py) just $(red hates) tabs).
	:
}

fix_plotter_py_test() {
	[[ "$PWD" != "$_REPO/src" ]] && return $WRONG_PWD
	_tutr_file_unstaged src/plotter.py && return 0
	_tutr_generic_test -c nano -a plotter.py -d "$_REPO/src"
}

fix_plotter_py_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/src" ;;
		*)
			_tutr_generic_hint $1 nano "$_REPO"
			cat <<-:

			Find this part of $(_py plotter.py), beginning on line 16:
			  $(_code "if l == line:")
			      $(_code "print('*', end='')")

			Add these two lines right below the $(_code if) statement:
			  $(_code "else:")
			      $(_code "print(' ', end='')")

			* Be sure to match the $(bld indentation) with its surroundings
			* Use $(bld 4) spaces per level of indentation
			* $(bld Do not) use tabs
			:
	esac
}

fix_plotter_py_epilogue() {
	cat <<-:
	Do you think that will work?  There is only one way to find out!

	:
	_tutr_pressenter
}



# Inspect ${_CMD[@]}
run_plotter_py1_prologue() {
	cat <<-:
	Run $(_py plotter.py) again to test your fix.
	:
}

run_plotter_py1_test() {
	_tutr_generic_test -c $_PY -a plotter.py -d "$_REPO/src"
}

run_plotter_py1_hint() {
	_tutr_generic_hint $1 $_PY "$_REPO"
	cat <<-:

	Run $(_py plotter.py) again to test your fix.
	:
}

run_plotter_py1_epilogue() {
	cat <<-:
	Are you satisfied with that change?  Then commit it to $(_Git).

	:
	_tutr_pressenter
}



# git add, git commit; assert `_tutr_file_clean` and `_tutr_branch_ahead`
# DON'T push it yet...
commit_plotter_py_ff() {
	cd "$_REPO/src"
	sed -i -e "17a\            else:\n                print(' ', end='')\n" "$_REPO/src/plotter.py"
	git add plotter.py
	git commit -m "Automatic commit: fixed src/plotter.py"
}

commit_plotter_py_rw() {
	git reset HEAD~
}

commit_plotter_py_prologue() {
	cat <<-:
	$(cmd git add) and $(cmd 'git commit -m "..."') to record this fix.

	Don't forget to wrap your commit message in $(kbd quote marks)!

	Hold off on pushing the commit for now.
	:
}

commit_plotter_py_test() {
	_UNSTAGED=99
	_STAGED=98
	_ENCOURAGEMENT=96

	[[ "$PWD" != "$_REPO/src" ]]       && return $WRONG_PWD
	_tutr_file_unstaged src/plotter.py && return $_UNSTAGED
	_tutr_file_staged   src/plotter.py && return $_STAGED
	_tutr_branch_ahead                 && return 0
	return $_ENCOURAGEMENT
}

commit_plotter_py_hint() {
	case $1 in
		$_UNSTAGED)
			cat <<-:
			Prepare your changes for commit by running $(cmd git add plotter.py).
			:
			;;

		$_STAGED)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save your changes in the
			$(_Git) repository.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/src"
			;;

		*)
			cat <<-:
			$(cmd git add) and $(cmd 'git commit -m "..."') to record this fix.

			Don't forget to wrap your commit message in $(kbd quote marks)!

			Hold off on pushing the commit for now.
			:
			;;
	esac
}

commit_plotter_py_epilogue() {
	_tutr_pressenter
}



# navigate to ../doc; edit Plan.md; git add, git commit: assert `_tutr_file_clean` and `_tutr_branch_ahead`
# DON'T push it yet
# Amend comment in phase 3
# Add a note under phase 2 that some bugs were found and fixed during testing.
edit_plan_md1_ff() {
	cd "$_REPO/doc"
	echo "Automatic edit: phase 2 & phase 3, something something, fixed a bug" >> Plan.md
	git add Plan.md
	git commit -m "Automatic commit: Updated doc/Plan.md"
}

edit_plan_md1_rw() {
	cd "$_REPO/doc"
	git reset HEAD~
	git restore Plan.md
}

edit_plan_md1_pre() {
	_COMMIT=$(git rev-parse master)
}

edit_plan_md1_prologue() {
	cat <<-:
	The moment after making a code change is another opportunity for thought
	and reflection.  Return to $(path ../doc) and write a note in $(_md Plan.md) about
	$(bld what) you changed and, more importantly, $(bld why) you changed it.  Use plain
	language to explain why this was a good idea.

	There are two places in $(_md Plan.md) that you should update.

	$(bld "Phase 2: Implementation")
	   Write that in the course of testing, a problem came up which was
	   overlooked when the program was first created.  Briefly describe what
	   the problem was and how it was corrected.

	$(bld "Phase 3: Testing & Debugging")
	   Add a line or two to your previous comment that mentions which
	   specific test cases you ran $(bld before) and $(bld after) the code change that
	   positively prove that the bug was fixed.

	$(cmd git add) and $(cmd git commit) this change, but don't push yet.
	:
}

edit_plan_md1_test() {
	_CLEAN=95
	_UNSTAGED=99
	_STAGED=98
	_ENCOURAGEMENT=96
	_NEW_COMMIT=$(git rev-parse master)

	[[ "$PWD" != "$_REPO/doc" ]] && return $WRONG_PWD
	_tutr_file_clean doc/Plan.md && [[ $_COMMIT == $_NEW_COMMIT ]] && return $_CLEAN
	_tutr_file_unstaged doc/Plan.md && return $_UNSTAGED
	_tutr_file_staged   doc/Plan.md && return $_STAGED
	_tutr_branch_ahead && (( REPLY >= 2 )) && return 0

	return $_ENCOURAGEMENT
}

edit_plan_md1_hint() {
	case $1 in
		$_CLEAN)
			cat <<-:
			Edit $(_md Plan.md) and add a note about $(bld what) you changed and, more
			importantly, $(bld why) you changed it.

			There are two places in $(_md Plan.md) that you should update:

			$(bld "Phase 3: Testing & Debugging")
			$(bld "Phase 2: Implementation")
			:
			;;

		$_UNSTAGED)
			cat <<-:
			Prepare your changes for commit by running $(cmd git add Plan.md).
			:
			;;

		$_STAGED)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save your changes in the
			$(_Git) repository.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/doc"
			;;

		*)
			cat <<-:
			$(cmd git add) and $(cmd 'git commit -m "..."') to record this fix.

			Don't forget to wrap your commit message in $(kbd quote marks)!

			Hold off on pushing the commit for now.
			:
			;;
	esac
}

edit_plan_md1_epilogue() {
	cat <<-:
	There are many reasons why complete, and well-written documentation is
	valued so highly at $(_duckie).  An aphorism I keep going back to is:

	     $(cyn '"The only thing worse than no documentation')
	             $(cyn 'is obsolete documentation."')

	A little time devoted to keeping up documentation does wonders for the
	culture of a company.  Not to mention the sanity of its developers!

	:
	_tutr_pressenter
}



edit_signature_md_ff() {
	cd "$_REPO/doc"
	echo "Automatic edit: Signature.md" >> Signature.md
	git add Signature.md
	git commit -m "Automatic commit: Updated doc/Signature.md"
}

edit_signature_md_rw() {
	cd "$_REPO/doc"
	git reset HEAD~
	git restore Signature.md
}

edit_signature_md_pre() {
	_COMMIT=$(git rev-parse master)
}

edit_signature_md_prologue() {
	cat <<-:
	The program is working and the documentation is up-to-date.
	It's time to call it a day!

	There is one last thing to write before you clock out.  Jot down a
	summary of your day's efforts in the Sprint $(_md Signature.md).

	This file helps you recognize when you are $(bld stuck) on a project.  Being
	busy is $(bld not) the same as being productive.  When you catch yourself
	writing the same summary a few days in a row, that's your sign that you
	are not making progress.  That is a great time to seek help from your
	teammates.

	The little bit of personal accountability and self-reflection that the
	Signature provides will spare you days of frustration.

	Open $(_md Signature.md) in $(_code Nano), clear out the placeholder text, and make an
	entry for today.

	$(cmd git add) and $(cmd 'git commit -m "..."') the file, but don't push yet
	(it's coming soon, I promise)!
	:
}

edit_signature_md_test() {
	_CLEAN=95
	_UNSTAGED=99
	_STAGED=98
	_ENCOURAGEMENT=96
	_NEW_COMMIT=$(git rev-parse master)

	[[ "$PWD" != "$_REPO/doc" ]]    && return $WRONG_PWD
	_tutr_file_clean doc/Signature.md && [[ $_COMMIT == $_NEW_COMMIT ]] && return $_CLEAN
	_tutr_file_unstaged doc/Signature.md && return $_UNSTAGED
	_tutr_file_staged   doc/Signature.md && return $_STAGED
	_tutr_branch_ahead && (( REPLY >= 3 )) && return 0

	return $_ENCOURAGEMENT
}

edit_signature_md_hint() {
	case $1 in
		$_CLEAN)
			cat <<-:
			Edit $(_md Signature.md), clear out the placeholder text, and make an
			entry describing your work today.
			:
			;;
		$_UNSTAGED)
			cat <<-:
			Prepare your changes for commit by running $(cmd git add Signature.md).
			:
			;;

		$_STAGED)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save your changes in the
			$(_Git) repository.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/doc"
			;;

		*)
			cat <<-:
			$(cmd git add) and $(cmd 'git commit -m "..."') to record this fix.

			Don't forget to wrap your commit message in $(kbd quote marks)!

			You'll get to $(cmd git push) this soon, just hold tight!
			:
			;;
	esac
}




git_status_prologue() {
	cat <<-:
	You've amassed a quite a few commits today.  Before you push them to
	$(_GitLab), I want you to see what divergent repositories look like.  Some
	students forget to push their work, and lose points for their incomplete
	submissions.

	Remember, we $(bld "don't grade") the code you have on your computer; we can only
	grade what we find on $(_GitLab). Learn to recognize when your repository
	has commits that aren't yet on $(_GitLab).

	The first thing to look at is $(cmd git status).
	:
}

git_status_test() {
	_tutr_generic_test -c git -a status -d "$_REPO/doc"
}

git_status_hint() {
	_tutr_generic_hint $1 git "$_REPO/doc"
	cat <<-:

	Run $(cmd git status) to continue.
	:
}

git_status_epilogue() {
	_tutr_pressenter
	cat <<-:

	Among $(cmd git status)'s output you will see this message:
	  $(_code "Your branch is ahead of 'origin/master' by 3 commits.")

	This is the first $(red red flag) telling you that you haven't submitted your
	work to $(_GitLab).  Your repository has 3 commits that the $(_origin) does not.

	:
	_tutr_pressenter
}




# Inspect ${_CMD[@]}
# note that HEAD -> master is many commits ahead of (origin/master)
# Compare the local log with GitLab's
git_log1_prologue() {
	cat <<-:
	Now take a look at the log.  This will show you exactly which commits
	are missing from $(_GitLab).  Notice that $(cyn "HEAD ->") $(grn master) is not on the
	same commit as $(red origin/master).  That is the clue that you're looking for.

	At the same time, hop on to the browser and look at your repo on $(_GitLab).
	Compare the $(ylw_ Commit ID) in the upper-left corner with the one you
	see in $(cmd git log).

	(If you closed that tab, get it back with $(cmd browse_repo))
	:
}

git_log1_test() {
	_tutr_generic_test -c git -a log -d "$_REPO/doc"
}

git_log1_hint() {
	_tutr_generic_hint $1 git "$_REPO/doc"
}

git_log1_epilogue() {
	cat <<-:
	You have three ways to check that your project is submitted correctly:
	  0. $(cmd git status)
	  1. $(cmd git log)
	  2. Look at the repository on $(_GitLab)

	Now, this only works if you $(bld "don't procrastinate")!  If you are working
	right up to midnight, you don't leave yourself enough time to $(bld double) and
	$(ylw triple-check) that all of your code is on $(_GitLab).  And, if you find that
	something is missing at 11:59 pm (say, you forgot to $(cmd git add) a new
	file), you will not have enough time to fix it!

	:
	_tutr_pressenter
}




# ! _tutr_branch_ahead, ${_CMD[@]} = 'git log'*
# Compare the local log with GitLab's again
big_push_ff() {
	git push
}

big_push_prologue() {
	cat <<-:
	Finally, the moment you've been waiting for!  $(cmd git push) your commits up
	to $(_GitLab) so your work can be graded.
	:
}

big_push_test() {
	_tutr_generic_test -c git -a push -d "$_REPO/doc"
}

big_push_hint() {
	_tutr_generic_hint $1 git "$_REPO/doc"
	cat <<-:

	Run $(cmd git push) to proceed
	:
}

big_push_epilogue() {
	_tutr_pressenter
	cat <<-:

	Whenever you push to my $(_GitLab) server, $(bld always) check for the push receipt
	that shows $(blu Big Blue) and the arrival time.

	This is also a good opportunity to refresh your browser and make sure
	that your latest commit arrived, as expected.

	(If you closed that tab, get it back with $(cmd browse_repo))

	:
	_tutr_pressenter

	cat <<-:

	You might want to know why I don't suggest that you just $(bld always push)
	immediately after $(bld every) commit.  For now, while you are still a
	beginner, $(bld always) pushing after $(bld every) commit isn't a bad thing to do.

	However, there are situations where advanced $(_Git) users prefer to work in
	a repository that is isolated from the remote.  The great thing about $(_Git)
	is that you can choose your own workflow!

	:
	_tutr_pressenter
}



cd_to_tutorial_ff() {
	cd "$_BASE"
}

cd_to_tutorial_rw() {
	cd "$_REPO"
}

cd_to_tutorial_prologue() {
	cat <<-:
	You've made it to the end of the Shell Tutorial.  The last thing to do
	is create a $(ylw Certificate of Completion) and push it to $(_GitLab).

	Go back into the Shell Tutor directory that you started from and run
	$(cmd ./make-certificate.sh).  This will create a file that you will
	put into this repository's $(path doc) directory.

	Don't worry, I'll walk you through the whole process  ;)
	:

	_tutr_shortest_path "$_BASE" "$PWD"
	if [[ -n "$REPLY" ]]; then
		cat <<-:

		You can start by $(cmd cd)'ing to $(path $REPLY)
		:
	else
		cat <<-:

		Use the $(cmd cd) to return to the tutorial directory.
		:
	fi
}

cd_to_tutorial_test() {
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	return 0
}

cd_to_tutorial_hint() {
	_tutr_shortest_path "$_BASE" "$PWD"
	if [[ -n "$REPLY" ]]; then
		echo Try running $(cmd cd $REPLY)
	else
		cat <<-:
		You need to be in the directory "$_BASE"

		If you are already here but are seeing this message, please run
		$(cmd tutor bug) and send the bug report to $_EMAIL.
		:
	fi
}



make_certificate_ff() {
	./make-certificate.sh
}

make_certificate_rw() {
	rm -f certificate.txt shell-logs.tgz shell-logs.zip
}

make_certificate_prologue() {
	cat <<-:
	Now that you are here, you can create your $(ylw Certificate of Completion) by
	running
	  $(cmd ./make-certificate.sh)
	:
}

make_certificate_test() {
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	_tutr_file_ignored certificate.txt && return 0
	_tutr_generic_test -c ./make-certificate.sh -d "$_BASE"
}

make_certificate_hint() {
	case $1 in
		$WRONG_PWD) _tutr_minimal_chdir_hint "$_BASE" ;;
		*) _tutr_generic_hint $1 ./make-certificate.sh "$_BASE" ;;
	esac
}

make_certificate_epilogue() {
	cat <<-:
	It isn't much to look at, but I suppose you can print it out
	and hang it on your fridge.

	:
	_tutr_pressenter
}

make_certificate_post() {
	# record the name of the shell-logs bundle, if it exists, before the
	# user has a chance to misplace it
	if [[ -n $BASH ]]; then
		local RESTORE_FAILGLOB=$(shopt -p failglob)
		local RESTORE_NULLGLOB=$(shopt -p nullglob)
		shopt -u failglob
		shopt -s nullglob
	elif [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt null_glob local_options
	fi
	_ARCHIVE=(*.zip *.tgz)
	[[ -n $BASH ]] && eval $RESTORE_FAILGLOB && eval $RESTORE_FAILGLOB
}



# PWD in _BASE && _tutr_file_untracked "$_REPO/doc/certificate.txt"
# ${PWD}* = _BASE
mv_cert_ff() {
	mv certificate.txt shell-logs.* "$_REPO/doc"
}

mv_cert_rw() {
	mv "$_REPO/doc/certificate.txt" "$_REPO"/doc/shell-logs.* "$_BASE"
}

mv_cert_prologue() {
	_tutr_shortest_path "$_REPO/doc" "$PWD"
	if [[ -n ${_ARCHIVE[@]} ]]; then
		cat <<-:
		The certificate comes in two parts
		  - A text file named $(path certificate.txt)
		  - An archive called $(path ${_ARCHIVE[0]})

		To receive credit for the tutorial, you must $(bld move) both files into
		the $(path doc/) directory of the Assignment #0 repository
		(i.e. $(path $REPLY)).
		:
	else
		cat <<-:
		To receive credit for the tutorial, you must $(bld move) the certificate,
		named $(path certificate.txt), into the $(path doc/) directory of the
		Assignment #0 repository (i.e. $(path $REPLY)).
		:
	fi
}

mv_cert_test() {
	_CERT_NOT_MOVED=99
	_CERT_MISSING=98
	_LOGS_NOT_MOVED=97
	_LOGS_MISSING=96
	[[ -n ${_ARCHIVE[@]}
		&& -f "$_REPO/doc/${_ARCHIVE[0]}"
		&& -f "$_REPO/doc/certificate.txt" ]] && return 0
	[[ -z ${_ARCHIVE[@]}
	   && -f "$_REPO/doc/certificate.txt" ]] && return 0
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	[[ ! -f "$_REPO/doc/certificate.txt"
		&& ! -f "$_BASE/certificate.txt" ]] && return $_CERT_MISSING
	[[ -n ${_ARCHIVE[@]}
		&& ! -f "$_REPO/doc/${_ARCHIVE[0]}"
		&& ! -f "$_BASE/${_ARCHIVE[0]}" ]] && return $_LOGS_MISSING
	_tutr_file_ignored certificate.txt && return $_CERT_NOT_MOVED
	_tutr_file_ignored ${_ARCHIVE[0]} && return $_LOGS_NOT_MOVED

	if   [[ -z ${_ARCHIVE[@]} ]]; then
		_tutr_generic_test -c mv -a certificate.txt -a ../$_REPONAME/doc -d "$_BASE"
	else
		_tutr_generic_test -c mv -a certificate.txt -a ${_ARCHIVE[0]} -a ../$_REPONAME/doc -d "$_BASE"
	fi
}

mv_cert_hint() {
	case $1 in
		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_BASE"
			;;

		$_CERT_MISSING)
			cat <<-:
			Uh-oh!  Where did $(path certificate.txt) go?  Re-create it with this command:
			  $(cmd ./make-certificate.sh)

			then move it into $(path ../$_REPONAME/doc).
			:
			;;

		$_LOGS_MISSING)
			cat <<-:
			Uh-oh!  Where did $(path ${_ARCHIVE[0]}) go?  Re-create it with this command:
			  $(cmd ./make-certificate.sh)

			then move it into $(path ../$_REPONAME/doc).
			:
			;;

		$_CERT_NOT_MOVED)
			cat <<-:
			What are you waiting for?

			Move it with $(cmd mv certificate.txt ../$_REPONAME/doc).
			:
			;;

		$_LOGS_NOT_MOVED)
			cat <<-:
			Move that archive over to the assignment repository like this:
			  $(cmd mv ${_ARCHIVE[0]} ../$_REPONAME/doc).
			:
			;;

		*)
			_tutr_generic_hint $1 mv "$_BASE"
			;;
	esac
}


cd_to_assn_ff() {
	cd "$_REPO/doc"
}

cd_to_assn_rw() {
	cd "$_BASE"
}

cd_to_assn_prologue() {
	_tutr_shortest_path "$_REPO/doc" "$PWD"
	if [[ -n "$REPLY" ]]; then
		cat <<-:
		Now, return one last time to the Assignment #0 repository by $(cmd cd)'ing to
		$(path $REPLY)
		:
	else
		cat <<-:
		Now, return to the Assignment #0 repository one last time.
		:
	fi
}

cd_to_assn_test() {
	[[ "$PWD" != "$_REPO/doc" ]] && return $WRONG_PWD
	return 0
}

cd_to_assn_hint() {
	_tutr_shortest_path "$_REPO/doc" "$PWD"
	if [[ -n "$REPLY" ]]; then
		echo Try running $(cmd cd $REPLY)
	else
		cat <<-:
		You need to be in the directory "$_REPO/doc"

		If you are already here but are seeing this message, please run
		$(cmd tutor bug) and send the bug report to $_EMAIL.
		:
	fi
}



push_certificate_ff() {
	git add certificate.txt shell-logs*
	git commit -m "committing certificate and log archive"
}

push_certificate_prologue() {
	if [[ -n ${_ARCHIVE[@]} ]]; then
		cat <<-:
		Now you can $(cmd git add), $(cmd git commit), and $(cmd git push) the certificate and
		the archive file.
		:
	else
		cat <<-:
		Now you can $(cmd git add), $(cmd git commit), and $(cmd git push) the certificate.
		:
	fi
}

push_certificate_test() {
	_UNTRACKED_CERT=99
	_STAGED_CERT=98
	_BRANCH_AHEAD=97
	_MISSING_CERT=96
	_MISSING_ARCHIVE=95
	_UNTRACKED_ARCHIVE=94
	_STAGED_ARCHIVE=93

	[[ "$PWD" != "$_REPO/doc" ]] && return $WRONG_PWD
	[[ ! -f "$_REPO/doc/certificate.txt" ]] && return $_MISSING_CERT
	_tutr_file_untracked doc/certificate.txt && return $_UNTRACKED_CERT
	if [[ -n ${_ARCHIVE[@]} ]]; then
		[[ ! -f "$_REPO/doc/${_ARCHIVE[0]}" ]] && return $_MISSING_ARCHIVE
		_tutr_file_untracked doc/${_ARCHIVE[0]} && return $_UNTRACKED_ARCHIVE
		_tutr_file_staged doc/${_ARCHIVE[0]} && return $_STAGED_ARCHIVE
	fi
	_tutr_file_staged doc/certificate.txt && return $_STAGED_CERT
	_tutr_branch_ahead && return $_BRANCH_AHEAD
	return 0
}

push_certificate_hint() {
	case $1 in
		$_MISSING_CERT)
			cat <<-:
			Uh-oh!  Where did $(path certificate.txt) go?  You'll have to track it
			down and place it in the $(path doc/) directory before you can finish.

			If all else fails, go back to the shell tutor directory and
			re-create it by running
			  $(cmd ./make-certificate.sh)
			:
			;;

		$_UNTRACKED_CERT)
			cat <<-:
			Add $(path certificate.txt) to the next commit with $(cmd git add certificate.txt).
			:
			;;

		$_MISSING_ARCHIVE)
			cat <<-:
			Uh-oh!  Where did $(path ${_ARCHIVE[@]}) go?  You'll have to track it
			down and place it in the $(path doc/) directory before you can finish.

			If all else fails, go back to the shell tutor directory and
			re-create it by running
			  $(cmd ./make-certificate.sh)
			:
			;;

		$_UNTRACKED_ARCHIVE)
			cat <<-:
			Add $(path ${_ARCHIVE[0]}) to the next commit with $(cmd git add ${_ARCHIVE[0]}).
			:
			;;

		$_STAGED_ARCHIVE)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the archive and
			certificate in the $(_Git) repository.
			:
			;;

		$_STAGED_CERT)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the certificate to the
			$(_Git) repository.
			:
			;;

		$_BRANCH_AHEAD)
			cat <<-:
			Now run $(cmd git push) to submit your work to $(_GitLab).
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_REPO/doc"
			;;

		*)
			if [[ -n ${_ARCHIVE[@]} ]]; then
				cat <<-:
				As a reminder, the steps of your $(_Git) workflow are
				  0. $(cmd git add certificate.txt ${_ARCHIVE[0]})
				  1. $(cmd 'git commit -m "Brief commit message"')
				  2. $(cmd git push)

				If this is what you are doing, but it isn't working, contact
				$_EMAIL for assistance.
				:
			else
				cat <<-:
				As a reminder, the steps of your $(_Git) workflow are
				  0. $(cmd git add certificate.txt)
				  1. $(cmd 'git commit -m "Brief commit message"')
				  2. $(cmd git push)

				If this is what you are doing, but it isn't working, contact
				$_EMAIL for assistance.
				:
			fi
			;;
	esac
}

push_certificate_epilogue() {
	if [[ -n ${_ARCHIVE[@]} ]]; then
		cat <<-:
		You weren't going to forget to check that those files made it to
		$(_GitLab), were you?

		Refresh your browser and ensure that both $(path certificate.txt) and
		$(path ${_ARCHIVE[0]}) are in the $(path doc/) directory on the server.

		:
	else
		cat <<-:
		You weren't going to forget to check that file made it to $(_GitLab),
		were you?

		Refresh your browser and ensure $(path certificate.txt) is in the $(path doc/)
		directory on the server.

		:
	fi
	_tutr_pressenter
}



epilogue() {
	cat <<-EPILOGUE
	                                                              ${_Y}     _
	                                                              ${_Y}    ( |
	${_C} _____ _         _   _           _ _      __     _ _       _  ${_Y}  ___\\ \\
	${_C}|_   _| |_  __ _| |_( )___  __ _| | |    / _|___| | |__ __| | ${_Y} (__()  \`-|
	${_C}  | | | ' \\/ _\` |  _|/(_-< / _\` | | |_  |  _/ _ \\ | / /(_-<_| ${_Y} (___()   |
	${_C}  |_| |_||_\\__,_|\\__| /__/ \\__,_|_|_( ) |_| \\___/_|_\\_\\/__(_) ${_Y} (__()    |
	${_C}                                    |/                        ${_Y} (_()__.--|

	You've been fantastic!

	Now you are ready to have a successful internship at $(_duckie).
	EPILOGUE
}


cleanup() {
	cat <<-:

	$(_tutr_progress)

	You worked on this lesson for $(_tutr_pretty_time)

	:

	if (( $1 == $_COMPLETE )); then
		echo You are all done!
		echo Run $(cmd ./tutorial.sh) to retry any lesson
	else
		echo Run $(cmd ./tutorial.sh) to retry this lesson
	fi
}


_STEPS=(
	rename_repo
	cd_repo
	ls0
	view_instructions
	view_markdown_md
	view_plan
	edit_readme
	push_readme
	git_log0
	view_plotter_py
	run_plotter_py0
	edit_plan_md0
	fix_plotter_py
	run_plotter_py1
	commit_plotter_py
	edit_plan_md1
	edit_signature_md
	git_status
	git_log1
	big_push
	cd_to_tutorial
	make_certificate
	mv_cert
	cd_to_assn
	push_certificate
	)


source main.sh  && _tutr_begin ${_STEPS[@]}

# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76 formatoptions=qron:
