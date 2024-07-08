#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=15

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

source ansi-terminal-ctl.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source noop.sh
	source open.sh
	source platform.sh
	_err() { (( $# == 0 )) && echo $(red _err) || echo $(red "$*"); }
fi

ask_to_open_explorer_msg() {
	cat <<-:
	In this lesson you will create, delete, and navigate through folders in
	the shell.  You can follow along in a graphical file explorer window.
	:
}

ask_to_open_explorer() {
	# Only ask to open a file explorer the very 1st time this step is encountered
	if [[ ${_EXPLORER-unset} = unset ]]; then
		_tutr_info ask_to_open_explorer_msg
		if _tutr_yesno "Would you like to open a file explorer?"; then
			_tutr_open "$_BASE"
			_EXPLORER=yes
		else
			_tutr_open_init  # set value $_OPEN for a later message
			_EXPLORER=
		fi
	fi
}

_make_files() {
	mkdir -p "$_BASE"/music/genre{0,1,2}/artist{0,1,2}/album{0,1,2}
	touch "$_BASE"/music/genre{0,1,2}/artist{0,1,2}/album{0,1,2}/track_0{1,2,3,4,5,6,7,8,9}.mp3
	touch "$_BASE/a_file"
}

setup() {
	source screen-size.sh 80 30
	export _BASE="$PWD/lesson3"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"

	_make_files
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #3: Directories

	In this lesson you will learn how to

	* Navigate directories
	* Create new directories
	* Remove empty directories
	* Forcibly remove directories without regard for their contents

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



cd_music_rw() {
	cd "$_BASE"
}

cd_music_ff() {
	cd "$_BASE/music"
}

cd_music_pre() {
	# Determine whether their prompt actually displays the CWD
	# * Can't run this in `setup()` because that runs in the context
	#   of the shell in the shebang line, /bin/sh, and is non-interactive
	#   (i.e. no PS1)
	# * Can't run this in `prologue()` because that runs in a subshell & will
	#   discard _PS1_CWD before I can see it
	# * Hence, we run it here
	# Zshmisc: CWD prompt escape sequences: %d, %/, %~
	# Bash: CWD prompt escape sequences: \w, \W
	if [[ -n $ZSH_NAME ]]; then
		if   [[ $PS1 =~ %[0-9]*[~c.] ]]; then _PS1_CWD=tilde
		elif [[ $PS1 =~ %[0-9]*[d/C] ]]; then _PS1_CWD=full
		fi
	else
		[[ $PS1 =~ \\[wW] ]] && _PS1_CWD=tilde
	fi

	ask_to_open_explorer
}

cd_music_prologue() {
	if [[ -n $ZSH_NAME && $_EXPLORER = yes ]]; then
		cat <<-:
		You will see some lines of output that look like this:

		$(bld "[12] $$")
		$(bld "[12]  + $$ done       $_OPEN $_BASE")

		Just ignore this.

		:
		_tutr_pressenter
		echo
	fi

	if [[ $_EXPLORER = yes ]]; then
		cat <<-:
		Resize the file explorer window so you can comfortably watch it and
		this terminal at the same time.

		As you move through the folders in the shell, follow along in the file
		explorer by clicking the corresponding folders.  Use the $(kbd Back) or $(kbd Up)
		buttons to go out of a folder.

		If you accidentally close the file explorer window and want
		it back, just run $(cmd $_OPEN .) ($(bld "note the dot at the end!")).

		Of course, you can also see folders in the shell with $(cmd ls).

		:
	else
		cat <<-:
		As usual, you will be able to see the folders with $(cmd ls).

		If you change your mind later, this command brings up the file explorer:
		  $(cmd $_OPEN .)
		($(bld "note the dot at the end!"))

		:
	fi
	_tutr_pressenter

	cat <<-:

	A directory is a collection of files and other directories.  You may be
	familiar with the concept of a $(bld folder) in a graphical file explorer;
	$(cyn folders are exactly the same things as directories).

	Directories are locations that your programs can be $(bld in.)  When a program
	is $(bld in) a directory, it can access the files and directories there.

	The shell you are running right now is in a directory.  This directory
	holds another directory named $(path music) and a file named $(path a_file).  Use $(cmd ls) to
	see for yourself.

	:
	_tutr_pressenter

	cat <<-:

	You can change into a different directory with the $(cmd cd) command.
	Its syntax is
	  $(cmd 'cd [DIRECTORY|-]')

	The '$(bld '|')' means $(bld "or").  The syntax above means
	"$(cmd cd) $(cyn may be) $(cyn run with no arguments,)
	  $(bld OR) $(cyn it can be given a DIRECTORY)
	  $(bld OR) $(cyn it can take a dash) $(bld -) $(cyn as its argument)"

	Use $(cmd cd) to enter the $(path music) directory.
	:
}

cd_music_test() {
	if   [[ "$PWD" = "$_BASE/music" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a music -d "$_BASE"
	fi
}

cd_music_hint() {
	_tutr_generic_hint $1 cd "$_BASE/music"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Use the $(cmd cd) command to enter the $(path music) directory.
	:
}

cd_music_post() {
	_PREV=${_CMD[0]}
}



# cd into genre1
cd_genre1_rw() {
	cd "$_BASE/music"
}

cd_genre1_ff() {
	cd "$_BASE/music/genre1"
}

cd_genre1_prologue() {
	if [[ -n ${_PS1_CWD:-} ]]; then
		cat <<-:
		You are now in the directory $(path music).  Notice that your shell's prompt
		looks different now than before you ran $(cmd $_PREV).
		:
	else
		cat <<-:
		You are now in the directory $(path music).
		:
	fi

	if [[ $_EXPLORER = yes ]]; then
		cat <<-:

		Double-click the $(path music) folder icon in the file explorer to follow along.
		:
	fi

	cat <<-:

	This directory happens to contain my illicit MP3 collection.  Don't
	worry about getting in trouble - I've cleverly disguised the files so
	the copyright holders cannot identify their intellectual property.

	A directory contained inside another directory is called a
	$(bld subdirectory).  There is only one directory in a Unix system that is
	technically not a $(bld subdirectory) (more on that in a moment), so most
	of the time these two terms are used interchangeably.

	If you run $(cmd ls) again you will see more subdirectories.

	Use the $(cmd cd) command to enter the $(path genre1) subdirectory.
	By the way, you can use $(kbd '<TAB>') autocompletion on subdirectories.
	:
}

cd_genre1_test() {
	if   [[ "$PWD" = "$_BASE/music/genre1" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a genre1 -d "$_BASE/music"
	fi
}

cd_genre1_hint() {
	_tutr_generic_hint $1 cd "$_BASE/music/genre1"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Use the $(cmd cd) command to enter the $(path genre1) subdirectory.
	:
}



# cd into artist0/album2
cd_artist0_album2_rw() {
	cd "$_BASE/music/genre1"
}

cd_artist0_album2_ff() {
	cd "$_BASE/music/genre1/artist0/album2"
}

cd_artist0_album2_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		cat <<-:
		Now open the $(path genre1) folder icon in the file explorer.

		:
	fi

	cat <<-:
	You were able to enter this directory because the shell was $(bld in) the
	directory named $(path music) and $(path genre1) was one of its subdirectories.
	$(path genre1) itself contains some subdirectories, each of which contain
	more subdirectories, and so on.

	Considering subdirectories to be $(bld children) makes the directory that
	contains them the $(bld parent).  The directory $(path music) is the $(bld parent)
	directory of $(path genre1).

	You can navigate the directory structure by traversing one directory at
	a time from parent to child.

	:
	_tutr_pressenter

	cat <<-:

	If you already know how deep you want to go, you can give $(cmd cd) multiple
	subdirectories at once by giving the names of related directories
	separated by $(bld front slashes) $(path /).  $(bld Front slash) is the symbol that shares a
	key with question mark $(kbd '?') (the other slash is called $(bld back slash)).

	$(bld Example:) $(path artist0/album2) is a $(bld grandchild) directory of $(path genre1).

	:

	if [[ $_EXPLORER = yes ]]; then
		cat <<-:
		In a graphical file explorer, this same operation is accomplished
		with $(bld extra clicking).

		:
	fi

	cat <<-:
	Use a single $(cmd cd) command to directly enter the $(path artist0/album2)
	subdirectory.  Let $(kbd '<TAB>') completion save you from tedious typing.
	:
}

cd_artist0_album2_test() {
	if   [[ "$PWD" = "$_BASE/music/genre1/artist0/album2" ]]; then return 0
	elif [[ "$PWD" = "$_BASE/music/genre1/artist0" ]]; then return 99
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a artist0/album2 -d "$_BASE/music/genre1"
	fi
}

cd_artist0_album2_hint() {
	case $1 in
		99)
			cat <<-:
			You're halfway there.
			Now go into the directory $(path album2).
			:
			;;
		*)
			_tutr_generic_hint $1 cd "$_BASE/music/genre1/artist0/album2"

			[[ $1 = $WRONG_PWD ]] && return
			cat <<-:

			Use the $(cmd cd) command to enter the $(path artist0/album2) subdirectory.
			  $(cmd cd artist0/album2)

			Let $(kbd '<TAB>') completion save you from tedious typing.
			:
			;;
	esac
}


cd_artist0_album2_epilogue() {
	if [[ ${_PS1_CWD:-} ]]; then
		cat <<-:
		You will have noticed that your shell's prompt has been changing as you
		move between directories.  This is to remind you of the shell's current
		location.

		:
	fi

	cat <<-:
	The location that a program runs in is called its "$(bld Current Working)
	$(bld Directory)" ($(bld CWD) for short).  $(bld CWD) is not just for shells; every program
	runnning on your computer has its own $(bld CWD).

	:
	_tutr_pressenter
}



cd_dot_dot0_rw() {
	cd "$_BASE/music/genre1/artist0/album2"
}

cd_dot_dot0_ff() {
	cd "$_BASE/music/genre1/artist0"
}

cd_dot_dot0_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		cat <<-:
		In the graphical file explorer, double-click through $(path artist0) then $(path album2)
		to arrive here.

		:
	fi

	cat <<-:
	You've reached the end of the line; there are no more subdirectories to
	follow.  Now that you are here, you can use $(cmd ls) to see the $(cyn MP3s).

	When you've gone into a subdirectory, how do you go back out of it?

	No matter what your $(bld CWD) is, its parent directory is always called '$(path ..)'.
	In other words, you can $(bld always) return to the parent directory with
	  $(cmd cd ..)

	Run that to return to the parent directory.
	:
}

cd_dot_dot0_test() {
	if   _tutr_noop; then return $NOOP
	elif [[ "$PWD" = "$_BASE/music/genre1/artist0" ]]; then return 0
	else _tutr_generic_test -c cd -a .. -d "$_BASE/music/genre1/artist0/album2"
	fi
}

cd_dot_dot0_hint() {
	_tutr_generic_hint $1 cd "$_BASE/music/genre1/artist0"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Run $(path cd ..) to return to the parent directory.
	You want to end up in the directory named $(path artist0)
	:
}

cd_dot_dot0_post() {
	_PREV_CMD="${_CMD[@]}"
}


# cd .. to go up to genre1
cd_dot_dot1_rw() {
	cd "$_BASE/music/genre1/artist0"
}

cd_dot_dot1_ff() {
	cd "$_BASE/music/genre1"
}

cd_dot_dot1_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		case $_OS in
			MacOSX)
				cat <<-:
				Press $(kbd Command-Up Arrow) in the graphical file explorer
				to get out of a subdirectory.

				:
				;;
			*)
				cat <<-:
				Look for an $(kbd Up) button in the graphical file explorer to get out of here.
				You may also click the name of the parent directory in the address bar.

				:
				;;
		esac
	fi

	if [[ "$_PREV_CMD" == "cd .." ]]; then
		cat <<-:
		Run $(cmd cd ..) again to return to $(path genre1).
		:
	else
		cat <<-:
		In the shell, go up by one more level to land in $(path genre1).
		:
	fi
}

cd_dot_dot1_test() {
	if   [[ "$PWD" = "$_BASE/music/genre1" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a .. -d "$_BASE/music/genre1/artist0"
	fi
}

cd_dot_dot1_hint() {
	_tutr_generic_hint $1 cd "$_BASE/music/genre1"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Use $(cmd cd ..) to return to this directory's parent named $(path genre1).
	:
}


# cd ../.. to go up two, back to $_BASE
cd_dot_dot2_rw() {
	cd "$_BASE/music/genre1"
}

cd_dot_dot2_ff() {
	cd "$_BASE"
}

cd_dot_dot2_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		case $_OS in
			MacOSX)
				cat <<-:
				Press $(kbd Command-Up Arrow) in the graphical file explorer
				to get out of a subdirectory.

				:
				;;
			*)
				cat <<-:
				Look for an $(kbd Up) button in the graphical file explorer to get out of here.
				You may also click the name of the parent directory in the address bar.

				:
				;;
		esac
	fi

	cat <<-:
	Moving one directory at a time is tedious.

	As before, you can give $(cmd cd) multiple directories in one command by
	separating them with $(path /); the directory name $(path ..) is no exception.

	Leave $(path music) entirely and return to the $(path lesson3) directory.  You can
	do this in a single $(path cd) command by joining two $(path ..) with $(path /):
	  $(cmd cd ../..)
	:
}

cd_dot_dot2_test() {
	_IN_MUSIC=99
	if   [[ "$PWD" = "$_BASE" ]]; then return 0
	elif [[ "$PWD" = "$_BASE/music" ]]; then return $_IN_MUSIC
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a ../.. -d "$_BASE/music/genre1"
	fi
}

cd_dot_dot2_hint() {
	case $1 in
		$_IN_MUSIC)
			cat <<-:
			Just about there.
			Go up by one more parent directory:
			  $(cmd cd ..)
			:
			;;
		*)
			_tutr_generic_hint $1 cd "$_BASE"
			[[ $1 = $WRONG_PWD ]] && return
			cat <<-:

			Use a single $(cmd cd) command to leave the $(path music) directory and go back to
			$(path lesson3).  Join two $(path ..) together with a front slash $(path /), like this:
			  $(cmd cd ../..)
			:
			;;
	esac
}


# cd to go home
cd_home_rw() {
	cd "$_BASE"
}

cd_home_ff() {
	cd
}

cd_home_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		case $_OS in
			MacOSX)
				cat <<-:
				Press $(kbd Command-Up Arrow) twice to return to the $(path lesson3) directory in the
				graphical file explorer.

				:
				;;
			*)
				cat <<-:
				Return to the $(path lesson3) directory in the graphical file explorer.

				:
				;;
		esac
	fi

	cat <<-:
	There are two special directories that you should be acquainted with.

	The first is your $(bld HOME) directory.  Every user on a Unix system has their
	own $(bld HOME) directory.  Your $(bld HOME) directory is typically named for your
	username, and is a subdirectory of $(path /home).  When you open a new shell
	it usually starts in your $(bld HOME) directory.

	When run with no arguments, $(cmd cd) instantly takes you $(bld HOME).

	Take this shortcut and go to your $(bld HOME) directory.
	:
}

cd_home_test() {
	if   [[ "$PWD" = "$HOME" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c 'cd|pushd' -d "$_BASE"
	fi
}

cd_home_hint() {
	_tutr_generic_hint $1 cd "$HOME"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Run $(cmd cd) with no arguments to directly go $(bld HOME).
	:
}

cd_home_epilogue() {
	cat <<-:
	${_M}           __,---.__        ${_z}
	${_M}        ,-'         \`-.__   ${_z} This little piggy went
	${_M}      &/           \`._\ _\  ${_W}
	${_M}      /               ''._  ${_z} Wee, wee, wee,${_z}
	${_M}      |   ,             (") ${_z}
	${_K} jrei${_M} |__,'\`-..--|__|---''  ${_z} all the way $(bld HOME)!

	:
	_tutr_pressenter

	if [[ ${_PS1_CWD:-} ]]; then
		cat <<-:

		${_B}    ~~~~~~~~~    ~~~~~~${_z}   In a moment when you return to the shell's
		${_B}  ~~:::::::::~  ~:::::~${_z}   prompt, see how the $(bld CWD) is abbreviated as $(cmd '~').
		${_B} ~:::::~~:::::~~:::::~ ${_z}   This symbol is called $(bld tilde) (TIL-duh), and is
		${_B}~:::::~  ~::::::::::~  ${_z}   used as shorthand for your $(bld HOME) directory's
		${_B}~~~~~~    ~~~~~~~~~~   ${_z}   path both in the shell and in other programs.

		:
	else
		cat <<-:

		${_B}    ~~~~~~~~~    ~~~~~~${_z}   I want to take this opportunity to introduce
		${_B}  ~~:::::::::~  ~:::::~${_z}   you to a bit of Unix culture.  The symbol $(cmd '~')
		${_B} ~:::::~~:::::~~:::::~ ${_z}   is called $(bld tilde) (TIL-duh), and is used as
		${_B}~:::::~  ~::::::::::~  ${_z}   shorthand for your $(bld HOME) directory's path
		${_B}~~~~~~    ~~~~~~~~~~   ${_z}   both in the shell and in other programs.

		:
	fi

	if [[ -d ~/Desktop ]]; then
		cat <<-:
		For example, your $(path HOME) contains a subdirectory named $(path Desktop).
		You can go directly there by running:
		:
	else
		cat <<-:
		For example, suppose your $(path HOME) contained a subdirectory named $(path Desktop).
		You could go directly there by running:
		:
	fi

	cat <<-:
	  $(cmd "cd ~/Desktop")

	instead of typing out all of this:
	  $(cmd cd $HOME/Desktop)

	:
	_tutr_pressenter

	cat <<-:

	While you don't need to use this fact right now, hang on to it because
	it will come up again in a later lesson.

	:
	_tutr_pressenter
}



# cd - to go back to previous dir
cd_minus0_rw() {
	cd
}

cd_minus0_ff() {
	cd "$_BASE"
}

cd_minus0_prologue() {
	local pattern='^cd$|^pushd$'
	if [[ "${_CMD[@]}" =~ $pattern ]]; then
		cat <<-:
		Less typing is fun, right?

		:
	fi

	if [[ ${_PS1_CWD:-} ]]; then
		cat <<-:
		What if you want to return to where you came from?  You $(bld could) type
		out the entire set of directory names separated by slashes.  They're
		right there in your old prompt.  It is easy enough to copy & paste
		them into a new command.
		:
	else
		cat <<-:
		Now, what if you want to go back where you came from?  You $(bld could) type
		out the entire set of directory names separated by slashes.  But that
		takes a lot of typing, not to mention a pretty sharp memory.
		:
	fi

	cat <<-:

	Easier still is to run $(cmd cd) with the $(cmd -) (minus) argument.  $(cmd cd -) takes
	you $(bld BACK) to your previous directory, no matter how long its name.
	It's like the "$(bld '<- Back')" button in your web browser.

	Try it now.  Use $(cmd cd -) to return to this lesson's base directory.
	:
}

cd_minus0_test() {
	if   [[ "$PWD" = "$_BASE" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a - -d "$_BASE"
	fi
}

cd_minus0_hint() {
	_tutr_generic_hint $1 cd "$_BASE"
}


# cd / to goto root
cd_root_rw() {
	cd "$_BASE"
}

cd_root_ff() {
	cd /
}

cd_root_prologue() {
	cat <<-:
	The last special directory you should know about is the "$(bld root)"
	directory.  The name of the root directory is a single slash $(path /).

	$(path /) is the ultimate parent of every directory on a Unix system.  The root
	directory is the only directory on a Unix system that has no parent.
	(Technically, $(path /) is $(bld its own) parent!  Good luck figuring that out...)

	If you run $(cmd cd ..) from $(path /), you don't actually go anywhere.

	Go to the root directory $(path /).
	:
}

cd_root_test() {
	if   [[ "$PWD" = / ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a / -d "/"
	fi
}

cd_root_hint() {
	_tutr_generic_hint $1 cd "/"

	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	The name of the root directory is a single front slash $(path /).
	This command will take you to the root directory:
	  $(cmd cd /)
	:
}

cd_root_epilogue() {
	cat <<-:
	The root directory gets its name by analogy.  If you consider the
	hierarchy of subdirectories to be a tree, then the root directory is at
	the bottom.
	:

	if [[ -d /root ]]; then
		cat <<-:

		If you run $(cmd ls) from here you will see a directory down here named
		$(path root).  This directory is $(bld NOT) the same thing as $(bld the root)
		directory $(path /).  "$(path root)" is actually the home directory of the user
		account named "$(bld root)".

		For historical reasons, $(bld root) is the name of the administrator account on
		Unix.  $(bld root) is all-powerful and able to do $(bld anything) on that system.

		$(bld Root) user, $(bld root) directory... yeah, it is kinda confusing.
		:
	fi

	cat <<-:

	Feel free to use $(cmd ls) to look around while you are down here.

	:
	_tutr_pressenter
}


# cd - get back to lesson
cd_minus1_rw() {
	cd /
}

cd_minus1_ff() {
	cd "$_BASE"
}

cd_minus1_prologue() {
	if [[ $_BASE != $OLDPWD ]]; then
		cat <<-:
		Since you've used $(cmd cd) to go into another directory, using $(cmd cd -) to
		return to the previous directory won't take you back to where you
		need to go.  In this case, run
		  $(cmd 'cd $_BASE')
		to return to the lesson.
		:
	else
		cat <<-:
		When you are ready, use $(cmd cd -) to continue the lesson.
		:
	fi
}

cd_minus1_test() {
	if   [[ "$PWD" = "$_BASE" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a - -d "$_BASE"
	fi
}

cd_minus1_hint() {
	_tutr_generic_hint $1 cd "$_BASE"
}


cd_a_file_pre() {
	[[ -d $_BASE/a_file ]] && rm -rf $_BASE/a_file
	! [[ -f $_BASE/a_file ]] && touch $_BASE/a_file
}

cd_a_file_prologue() {
	cat <<-:
	Now it's time for some $(_err error messages).  Yay!!!

	What happens if you give $(cmd cd) an argument that is not a directory?

	There is a file here called $(path a_file).  Try to $(cmd cd) into this file to see
	what happens.
	:
}

cd_a_file_test() {
	if ! [[ -f "$_BASE/a_file" ]]; then
		touch "$_BASE/a_file"
		return 99
	elif [[ -d "$BASE/a_file" ]]; then
		rm -rf "$BASE/a_file"
		touch "$BASE/a_file"
		return 98
	elif [[ ( ${_CMD[0]} = cd || ${_CMD[0]} = pushd || ${_CMD[0]} = popd ) \
		&& ${_CMD[1]} = a_file \
		&& "$PWD" = "$_BASE" \
		&& $_RES == 1 ]]; then return 0
	elif _tutr_noop; then return $NOOP
	elif [[ -n $ZSH_NAME ]]; then _tutr_generic_test -f -c cd -a a_file -d "$_BASE"
	# cd'ing into a file returns success in Bash
	else _tutr_generic_test -c cd -a a_file -d "$_BASE"
	fi
}

cd_a_file_hint() {
	case $1 in
		99)
			cat <<-:
			Whoops!  Somehow that file disappeared.

			I just replaced it for you so you can try again.

			Now run
			  $(cmd cd a_file)
			:
			;;
		98)
			cat <<-:
			That was weird; somehow the file $(path a_file) was actually a directory.

			I just replaced it for you so you can try again.

			Now run
			  $(cmd cd a_file)
			:
			;;
		*)
			_tutr_generic_hint $1 cd "$_BASE"
			cat <<-:

			Then run
			  $(cmd cd a_file)
			to see what happens.
			:
			;;
	esac

}

cd_a_file_epilogue() {
	_tutr_pressenter
	cat <<-:

	That wasn't so bad, was it?

	:
	_tutr_pressenter
}

cd_a_file_post() {
	_RES=0
}


# cd not_a_dir # fails
cd_not_a_dir_pre() {
	[[ -d $_BASE/not-a-dir ]] && rm -rf $_BASE/not-a-dir
	_AGAIN=
	_TIMES=0
}

cd_not_a_dir_prologue() {
	cat <<-:
	There is one last thing to try with the $(cmd cd) command: what if you try to
	$(cmd cd) into a directory that does not exist?

	There is no directory here called $(path not-a-dir) (I made sure).

	Try to use $(cmd cd) to enter a directory by that name to see what happens.
	:
}

cd_not_a_dir_test() {
	_NOT_A_DIR_EXISTS=99
	if [[ -a $_BASE/not-a-dir ]]; then
		rm -rf $_BASE/not-a-dir
		(( _TIMES++ > 0 )) && _AGAIN=" (again)"
		return $_NOT_A_DIR_EXISTS
	elif [[ ( ${_CMD[0]} = cd || ${_CMD[0]} = pushd || ${_CMD[0]} = popd ) \
		&& ${_CMD[1]} = not-a-dir \
		&& "$PWD" = "$_BASE" \
		&& $_RES == 1 ]]; then return 0
	elif _tutr_noop; then return $NOOP
	elif [[ -n $ZSH_NAME ]]; then _tutr_generic_test -f -c cd -a not-a-dir -d "$_BASE"
	# cd'ing into a non-existent file returns success in Bash
	else _tutr_generic_test -c cd -a not-a-dir -d "$_BASE"
	fi
}

cd_not_a_dir_hint() {
	case $1 in
		$_NOT_A_DIR_EXISTS)
			cat <<-:
			Are you trolling me?  $(path not-a-dir) is not supposed to exist.
			That's the whole gimmick of this step.

			$(red Sigh) I removed it$_AGAIN so you can do this the right way.

			Please run
			  $(cmd cd not-a-dir)
			so we can get on with things.
			:
			;;
		*)
			_tutr_generic_hint $1 cd "$_BASE"

			[[ $1 = $WRONG_PWD ]] && return
			cat <<-:

			Try to to enter this non-existent directory to see what happens:
			  $(cmd cd not-a-dir)
			:
			;;
	esac
}

cd_not_a_dir_epilogue() {
	_tutr_pressenter
	cat <<-:

	Now that you've seen all of these errors you're a real $(cmd cd) expert!

	:
	_tutr_pressenter
}


# mkdir alpha
mkdir_alpha_rw() {
	rm -rf "$_BASE/alpha"
}

mkdir_alpha_ff() {
	mkdir -p "$_BASE/alpha"
}

mkdir_alpha_prologue() {
	cat <<-:
	You can make new directories with the $(cmd mkdir) command.
	  $(cmd 'mkdir [-p] DIRECTORY...')

	The ellipsis ($(cmd ...)) means that you can create more than one directory in
	a single command.  Each directory is created in the shell's CWD (current
	working directory).

	$(bld EXAMPLE:) create a subdirectory of your current directory named $(path alpha)
	  $(cmd mkdir alpha)

	$(bld EXAMPLE:) create three subdirectories $(path beta), $(path gamma) and $(path delta)
	  $(cmd mkdir beta gamma delta)

	Use $(cmd mkdir) to create a directory called $(path alpha).
	:
}

mkdir_alpha_test() {
	if   [[ -d $_BASE/alpha ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c mkdir -a alpha -d "$_BASE"
	fi
}

mkdir_alpha_hint() {
	_tutr_generic_hint $1 mkdir "$_BASE"
	cat <<-:

	Use $(cmd mkdir) to create a directory called $(path alpha).
	:
}


# cd alpha
cd_alpha_rw() {
	cd "$_BASE"
}

cd_alpha_ff() {
	cd "$_BASE/alpha"
}

cd_alpha_pre() {
	if [[ -a "$_BASE/alpha" && ! -d "$_BASE/alpha" ]]; then
		rm -f "$_BASE/alpha"
		mkdir -p "$_BASE/alpha"
	elif ! [[ -d "$_BASE/alpha" ]]; then
		mkdir -p "$_BASE/alpha"
	fi
}

cd_alpha_prologue() {
	if [[ $_EXPLORER = yes ]]; then
		cat <<-:
		Go into the new $(path alpha) folder in the file explorer.

		Then, use $(cmd cd) to go there in the shell.
		:
	else
		cat <<-:
		Now $(cmd cd) into the new directory $(path alpha).
		:
	fi
}

cd_alpha_test() {
	if   [[ "$PWD" = "$_BASE/alpha" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a alpha -d "$_BASE"
	fi
}

cd_alpha_hint() {
	_tutr_generic_hint $1 cd "$_BASE/alpha"
	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	$(cmd cd) into your new directory $(path alpha)
	:
}


# mkdir beta/gamma #fails
mkdir_beta_gamma_rw() {
	rm -rf "$_BASE/alpha/beta"
}

mkdir_beta_gamma_ff() {
	mkdir -p "$_BASE/alpha/beta/gamma"
}

mkdir_beta_gamma_prologue() {
	cat <<-:
	When building a $(bld nested) directory structure, creating directories
	one-at-a-time is tedious and slow.  Just as you can give $(cmd cd)
	multiple nested directories in one command with $(path /), so too can
	you do this with $(cmd mkdir).

	The only catch is that you need to use $(cmd mkdir)'s $(cmd -p) option.  It stands for
	"$(cyn create parent directories as needed)".

	Use $(cmd mkdir -p) to create the nested directories $(path beta/gamma) in one command.
	:
}


mkdir_beta_gamma_test() {
	_FORGOT_P=99
	if   [[ -d $_BASE/alpha/beta/gamma ]]; then return 0
	elif _tutr_noop; then return $NOOP
	elif [[ ${_CMD[@]} == "mkdir beta/gamma" && $_RES != 0 ]]; then return $_FORGOT_P
	else _tutr_generic_test -c mkdir -a -p -a beta/gamma -d "$_BASE/alpha"
	fi
}

mkdir_beta_gamma_hint() {
	case $1 in
		$_FORGOT_P)
			cat <<-:
			It looks like you forgot the $(cmd -p) option!
			:
			;;
		*)
			_tutr_generic_hint $1 mkdir "$_BASE/alpha"
			;;
	esac

	cat <<-:

	Use $(cmd mkdir) to create the directories $(path beta/gamma).
	Remember to use the $(cmd -p) option.
	:
}



# cd beta
cd_beta_rw() {
	cd "$_BASE/alpha"
}

cd_beta_ff() {
	cd "$_BASE/alpha/beta"
}

cd_beta_prologue() {
	cat <<-:
	Enter the $(path beta) directory.
	:
}

cd_beta_test() {
	if   [[ "$PWD" = "$_BASE/alpha/beta" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a beta -d "$_BASE/alpha"
	fi
}

cd_beta_hint() {
	_tutr_generic_hint $1 cd "$_BASE/alpha/beta"
	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	Enter the $(path beta) directory
	:
}


# rmdir gamma
rmdir_gamma_rw() {
	mkdir -p "$_BASE/alpha/beta/gamma"
}

rmdir_gamma_ff() {
	rmdir "$_BASE/alpha/beta/gamma"
}

rmdir_gamma_prologue() {
	cat <<-:
	$(cmd rmdir) removes directories.
	  $(cmd 'rmdir DIRECTORY...')

	A directory $(bld must) be empty before it can be removed with $(cmd rmdir.)  You may
	need to use $(cmd rm) to clear it out before $(cmd rmdir) works on it.

	The directory $(path gamma) that you just barely created is empty.
	Remove it with $(cmd rmdir)
	:
}

rmdir_gamma_test() {
	if   [[ ! -d $_BASE/alpha/beta/gamma ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c rmdir -a gamma -d "$_BASE/alpha/beta"
	fi
}

rmdir_gamma_hint() {
	_tutr_generic_hint $1 rmdir "$_BASE/alpha/beta"
	cat <<-:

	Remove the directory $(path gamma) with the $(cmd rmdir) command:
	  $(cmd rmdir gamma)
	:
}


# cd ../..
cd_dot_dot3_rw() {
	cd "$_BASE/alpha/beta"
}

cd_dot_dot3_ff() {
	cd "$_BASE"
}

cd_dot_dot3_prologue() {
	cat <<-:
	Return to the $(path "$(basename "$_BASE")") directory by going up two directories.
	:
}

cd_dot_dot3_test() {
	_ALMOST_THERE=99
	if   [[ "$PWD" = "$_BASE" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	elif [[ "$PWD" = "$_BASE/alpha" ]]; then return $_ALMOST_THERE
	else _tutr_generic_test -c cd -a ../.. -d "$_BASE"
	fi
}

cd_dot_dot3_hint() {
	case $1 in
		$_ALMOST_THERE)
			cat <<-:
			Almost there!  Go up one more directory.
			:
			;;
		*)
			_tutr_generic_hint $1 cd "$_BASE"
			[[ $1 = $WRONG_PWD ]] && return
			cat <<-:

			Return to the $(path "$(basename "$_BASE")") directory by going up two directories.
			Recall that '$(bld ..)' refers to the parent directory, and that multiple '$(bld ..)'
			can be separated with '$(bld /)'.
			:
			;;
	esac
}


# rmdir alpha fails
rmdir_alpha_rw() {
	mkdir -p "$_BASE/alpha/beta"
}

rmdir_alpha_pre() {
	if [[ ! -d  "$_BASE/alpha/beta" ]]; then
		mkdir -p "$_BASE/alpha/beta"
	fi
}

rmdir_alpha_prologue() {
	cat <<-:
	$(path alpha) contains a subdirectory $(path beta), and is therefore not empty.
	What do you think will happen if you try to $(cmd rmdir alpha)?

	Try it to see what happens.
	:
}

rmdir_alpha_test() {
	_tutr_noop && return $NOOP
	_tutr_generic_test -c rmdir -a "alpha/?" -d "$_BASE" -f
}

rmdir_alpha_hint() {
	case $1 in
		$STATUS_WIN)
			cat <<-:
			I can't believe that worked!
			Contact $_EMAIL and report this strange occurrence.
			:
			;;
		*)
			_tutr_generic_hint $1 rmdir "$_BASE"
			;;
	esac
	cat <<-:

	Use $(cmd rmdir) on the non-empty directory $(path alpha).
	It won't work, but that's okay.
	:
}

rmdir_alpha_epilogue() {
	_tutr_pressenter
	cat <<-:

	Are you carefully reading each $(_err error message) that you see?

	Believe it or not, error messages are there to help you.

	I am making you run into errors now so that you aren't surprised when
	you encounter them later.  I want you to feel $(ylw confident) no matter what
	your computer tells you.

	:
	_tutr_pressenter
}



rm_alpha_pre() {
	if [[ ! -d  "$_BASE/alpha/beta" ]]; then
		mkdir -p "$_BASE/alpha/beta"
	fi
}

rm_alpha_prologue() {
	cat <<-:
	If you are really determined to get rid of $(path alpha), you would need to
	enter each of its subdirectories, one-by-one, and remove every file you
	see.  Just repeat this for each subdirectory's subdirectories and delete
	all files you come across.

	Once you finally reach the end of the files and subdirectories, you
	need to $(cmd cd ..) then $(cmd rmdir) each newly-empty subdirectory.  Repeat this
	until all unwanted directories are gone.

	That sounds like a $(bld lot of tedious work).  Avoiding tedious work is the
	whole point of having computers.

	:
	_tutr_pressenter

	cat <<-:

	If $(cmd rmdir) isn't up to the task, you must find a command that is.

	It turns out that $(cmd rm) is just the thing you're looking for.

	Ordinarily, $(cmd rm) does not work on directories.

	Try it for yourself:
	  $(cmd rm alpha)
	:
}

rm_alpha_test() {
	_tutr_generic_test -c rm -a alpha -d "$_BASE" -f
}

rm_alpha_hint() {
	_tutr_generic_hint $1 rm "$_BASE"
}

rm_alpha_epilogue() {
	cat <<-:
	${_y}  """          """  ${_z}
	${_y}    """"    """"    ${_z}
	${_W}  .::::.${_y}"  "${_W}.::::.  ${_z}
	${_W} ,::::::,  ,::::::, ${_z}
	${_W} :::  :::  :::  ::: ${_z}
	${_W} '::::::'${_y} \\${_W}'::::::' ${_z}  So disappointing...
	${_W}  '::::' ${_y}  \\${_W}'::::'  ${_z}
	${_y}            \       ${_z}
	${_y}          ___\      ${_z}
	${_r}        _____       ${_z}
	${_r}       /     \      ${_z}
	${_r}      /       \     ${_z}

	:
	_tutr_pressenter
}



# rm -r alpha # asks loads of questions
rm_r_alpha_ff() {
	rm -rf "$_BASE/alpha"
}

rm_r_alpha_rw() {
	mkdir -p "$_BASE/alpha/beta"
}

rm_r_alpha_prologue() {
	cat <<-:
	However, you $(bld can) tell $(cmd rm) to $(bld automatically) enter every subdirectory and
	delete every file it sees.  When it encounters subdirectories, it will
	enter them and delete every file it sees along the way until the job is
	done.

	This pattern of "$(cyn "do something again and again until it's done")"
	is called $(bld recursion).

	Read the $(cmd man)ual page for $(cmd rm) and look for an option that makes it
	operate $(bld recursively).  When you find it, run it!
	:
}

rm_r_alpha_test() {
	_READ_MANUAL=99
	_MAN_NO_PAGE=98
	_MAN_WRONG_PAGE=97

	[[ ! -d $_BASE/alpha ]] && return 0
	[[ "${_CMD[@]}" == man ]] && return $_MAN_NO_PAGE
	[[ "${_CMD[@]}" == "man rm" || "${_CMD[@]}" == "man 1 rm" ]] && return $_READ_MANUAL
	[[ "${_CMD[0]}" == man ]] && return $_MAN_WRONG_PAGE
	_tutr_noop && return $NOOP
	_tutr_generic_test -c rm -a '^-[rR]$|^--recursive$' -a alpha -d "$_BASE"
}

rm_r_alpha_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you were looking for in the manual for $(cmd rm)?

			If you think you got it, try it now.  Your goal is to remove the
			directory $(path alpha) along with $(bld ALL) of its contents.
			:
			;;

		$_MAN_NO_PAGE)
			cat <<-:
			The $(cmd man) command needs an argument!

			Try running $(cmd man rm).

			Look for an option that makes $(cmd rm) operate $(bld recursively).
			When you find it, run it!
			:
			;;

		$_MAN_WRONG_PAGE)
			cat <<-:
			$(cmd "${_CMD[@]}")? That's an odd choice.

			I don't think you'll find what you're looking for in there.
			Try reading $(cmd man rm).

			Look for an option that makes $(cmd rm) operate $(bld recursively).
			When you find it, run it!
			:
			;;

		*)
			_tutr_generic_hint $1 rm "$_BASE"

			cat <<-:

			Read the $(cmd man)ual page for $(cmd rm) and look for an option that tells it to
			operate $(bld recursively.) When you find that option, run it!
			:
			;;
	esac
}

rm_r_alpha_post() {
	_PREV="${_CMD[@]}"
}

rm_r_alpha_epilogue() {
	_tutr_pressenter

	if [[ "${_CMD[@]}" == *f* ]]; then
		cat <<-:

		Well, well, well, looks like somebody already knows about the
		$(bld force) option!

		Don't let it go to your head, becuase it could also be called the
		$(bld footgun) option.

		:
	else
		cat <<-:

		The only trouble with $(cmd $_PREV) is that it can ask
		$(bld a lot) of questions!

		It's not entirely a bad thing to get confirmation before permanently
		deleting files, but you can have too much of a good thing.

		:
	fi
	_tutr_pressenter
}


# rm -rf music a_file  # one shot, one kill
rm_rf_music_rw() {
	_make_files
}

rm_rf_music_ff() {
	rm -rf "$_BASE/music"  "$_BASE/a_file"
}

rm_rf_music_prologue() {
	cat <<-:
	There are 39 directories and 243 (fake) $(cmd MP3s) under the directory $(path music).
	I'm going to ask you to delete all of them, but I am NOT going to ask
	you to press $(kbd Y) 283 times.  That would be a lot of tedious work!

	I want you to learn the awesome destructive power of automation.  Be
	careful with this next command!  With a snap of your fingers, all files
	standing in your way will cease to exist.  Always remember that "$(cyn with)
	$(cyn great power comes great responsibility)", "$(cyn I love you 3000)", etc.

	:
	_tutr_pressenter

	cat <<-:

	When $(cmd rm)'s $(cmd -f) $(bld force) option is combined with $(cmd -r) $(bld NO) prompts are given.
	All files encountered are removed, no questions asked.
	Do $(bld NOT) use $(cmd rm) $(cmd -rf) lightly!

	The syntax is
	  $(cmd 'rm [-r] [-f] FILE_OR_DIRECTORY...')

	The order that the $(cmd -r) and $(cmd -f) options appear doesn't matter;
	$(cmd rm -f -r) and $(cmd rm -r -f) are equal.  These short options can even be
	squished together: $(cmd rm -fr) and $(cmd rm -rf) do the same thing.

	Don't you think it's time to remove the evidence of my piracy from
	your computer?  Use $(cmd rm -rf) on the $(path music) directory and cover my
	tracks.
	:
}

rm_rf_music_test() {
	if   ! [[ -d $_BASE/music ]]; then return 0
	elif _tutr_noop; then return $NOOP
	elif [[ $PWD != $_BASE ]]; then return $WRONG_PWD
	elif [[ ${#_CMD[@]} < 3 ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -rf' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -fr' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -r -f' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -f -r' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -r' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = 'rm -f' ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[@]} = rm ]]; then return $TOO_FEW_ARGS
	elif [[ ${_CMD[0]} = rmdir ]]; then return 96
	elif [[ ${_CMD[0]} != rm ]]; then return $WRONG_CMD
	elif [[ ${_CMD[-1]} = '.' ]]; then return 99
	elif [[ ${_CMD[-1]} = 'a_file' ]]; then return 98
	elif [[ ${_CMD[-1]} != 'music' ]]; then return 97
	else return $STATUS_FAIL
	fi
}

rm_rf_music_hint() {
	case $1 in
		99)
			cat <<-:
			I don't think that command does what you think it does.
			:
			;;

		98)
			cat <<-:
			Hey!  What did $(path a_file) ever do to you?
			:
			;;
		97)
			cat <<-:
			Careful!  People have lost important files that way.

			That's not the directory I asked you to remove.
			:
			;;
		96)
			cat <<-:
			$(cmd rmdir) is close, but not quite the command you need to use.
			:
			;;
		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Recursively remove the $(path music) directory to erase every trace of my
	pirated files:
	  $(cmd rm -rf music)
	:
}

rm_rf_music_epilogue() {
	if   [[ ${_CMD[${#_CMD[@]}]} = '*' ]]; then
		cat <<-:
		You are playing with fire!

		Be VERY careful when mixing $(cmd rm) with '$(bld '*')'!

		:
		_tutr_pressenter
	fi

	cat <<-:
	$(bld 'SNAP!')

	And just like that, they're all gone.  Not even a puff of dust remains.

	I don't think Bruce Banner and Tony Stark are going to be able to bring
	that directory back... unless they planned ahead and used $(cmd git), which
	you will see in a future lesson ;)

	:
	_tutr_pressenter
}


epilogue() {
	cat <<-EPILOGUE
	Phew, that was a lot, but you did great!  If you ever need a
	refresher on this stuff you can run this tutorial again.

	If you opened a file explorer window, you may now $(red close) it.

	In this lesson you have learned how to

	* Navigate directories
	* Create new directories
	* Remove empty directories
	* Forcibly remove directories without regard for their contents

	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}



source main.sh && _tutr_begin \
	cd_music \
	cd_genre1 \
	cd_artist0_album2 \
	cd_dot_dot0 \
	cd_dot_dot1 \
	cd_dot_dot2 \
	cd_home \
	cd_minus0 \
	cd_root \
	cd_minus1 \
	cd_a_file \
	cd_not_a_dir \
	mkdir_alpha \
	cd_alpha \
	mkdir_beta_gamma \
	cd_beta \
	rmdir_gamma \
	cd_dot_dot3 \
	rmdir_alpha \
	rm_alpha \
	rm_r_alpha \
	rm_rf_music



# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
