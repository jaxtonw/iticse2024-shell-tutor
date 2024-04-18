#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=20

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

source ansi-terminal-ctl.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source damlev.sh
	source generic-error.sh
	source noop.sh
	source platform.sh
	_Google() { echo ${_B}G${_R}o${_Y}o${_B}g${_G}l${_R}e${_z}; }
	_code() { (( $# == 0 )) && echo $(cyn code) || echo $(cyn "$*"); }
	_err() { (( $# == 0 )) && echo $(red _err) || echo $(red "$*"); }
	_py() { (( $# == 0 )) && echo $(grn Python) || echo $(grn $*) ; }
fi

_make_files() {
	cat <<-TEXT > "$_BASE/textfile.txt"
	 _   _      _ _         __        __         _     _ _
	| | | | ___| | | ___    \\ \\      / /__  _ __| | __| | |
	| |_| |/ _ \\ | |/ _ \\    \\ \\ /\\ / / _ \\| '__| |/ _\` | |
	|  _  |  __/ | | (_) |    \\ V  V / (_) | |  | | (_| |_|
	|_| |_|\\___|_|_|\\___( )    \\_/\\_/ \\___/|_|  |_|\\__,_(_)
	                    |/

	Welcome to the CS 1440 command shell tutorial!

	It is my hope that this tutorial series helps you to quickly become
	comfortable in the Unix command line environment.
	TEXT

	cat <<-TEXT > "$_BASE/markdown.md"
	# This is a Markdown file

	This is a text file written in the **Markdown** format.

	Markdown is a text-to-HTML conversion tool for web writers. Markdown allows
	you to write using an easy-to-read, easy-to-write plain text format, then
	convert it to structurally valid XHTML (or HTML).

	Markdown was created by John Gruber and is documented on his website
	[Daring Fireball](https://daringfireball.net/projects/markdown/).

	TEXT

	cat <<-'TEXT' > "$_BASE/.hidden"
	YOU FOUND THE IMPOSTER!
	   ____
	 _| ___\!!
	| |(____)                /`-.__
	|_|    \                |   |__|
	 |__/\__|                \.-`\|
	              ____        REPORT
	      __     /___ |_      _____
	     _||_ _ (____)| |    \     /
	    |  _ |_| |  _ |_|     \USE/
	   |__|__|  |__|__|        \ /


	File names starting with a dot '.' are hidden by commands like 'ls' by
	default.  This was due to a bug in 'ls' from the early days of Unix.

	Unix users now use this bug to clean up their home directories.  Instead
	of showing dozens of config files, 'ls' keeps them out of sight.  Today,
	these hidden config files are called 'dotfiles'.

	This is an example of a "bug" becoming a feature.  So, don't worry about
	making mistakes; they're just unexpected features!

	https://linux-audit.com/linux-history-how-dot-files-became-hidden-files/

	TEXT

	cat <<-TEXT > "$_BASE/top.secret"
	You should not be able to read this message because you lack permission
	to this file.  If you can see this, please report it as a bug.

	TEXT

	case $(uname -s) in
		*MINGW*)
			icacls "$_BASE/top.secret" //deny "$USERNAME:(d)"
			;;
		*)
			chmod -r "$_BASE/top.secret"
			;;
	esac
	return 0
}

_make_corrupt_terminal() {
	local esc=$'\x1b'
	cat <<-TEXT > "$_BASE/corrupt_terminal"
	Using 'cat' on this file will garble your screen.  Use with caution.
	Set reverse video mode ${esc}[?5h
	DEC screen alignment test - fills screen with E's ${esc}#8

	Pretty wild, huh?

	You can still run commands when the terminal is in this state.
	You just can't read the output.

	Try running 'ls', 'echo hello world', and 'cat textfile.txt'.

	Use 'reset' to restore your terminal when you're done. ${esc}(0

	TEXT
}

setup() {
	source screen-size.sh 80 30
	export _BASE="$PWD/lesson0"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"

	_make_files
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #0: Unix Shell Basics

	In this lesson you will learn about

	* Using the Unix command line interface (CLI)
	* Commands and arguments
	* Hidden files
	* The difference between the 'shell' and the 'terminal'
	* How to clear and reset the terminal
	* Cancelling a runaway command
	* Understanding messages and recovering from errors

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



# Introduce the 'tutor' command
tutor_hint_prologue() {
	local PLUS=$'\x1b[1;32m+\x1b[0m'
	cat <<-:
	Before we begin, you need to know how this thing works.

	I'll give you things to do, and you'll do your best to do them.  As you
	work, the progress bar above your prompt turns from $(red red) to $(grn green).

	There are ${#_STEPS[@]} things to do in this lesson (it only looks like $((${#_STEPS[@]} - 1)) because
	I count from zero).  After you have done enough things you'll win, which
	improves your self-esteem.

	You do things in the shell by running commands.  When I show you a
	command I highlight it in green, like this:
	  $(cmd tutor hint)

	Now, if you ever find yourself in a situation where you don't know what
	thing to do, use the $(cmd tutor hint) command.

	Why don't you try it right now?  Run $(cmd tutor hint) to earn your first $PLUS.
	:
}

tutor_hint_test() {
	_tutr_generic_test -c tutor -a hint
}

tutor_hint_hint() {
	_tutr_generic_hint $1 tutor

	echo
	echo "The command will look like this"
	echo "  $(cmd tutor hint)"
}

tutor_hint_epilogue() {
	cat <<-:
	Deja vu always creeps me out OwO

	:

	_tutr_pressenter
	cat <<-:

	The $(cmd tutor hint) command redisplays your marching orders.
	This command will come in handy, so $(bld "remember it!")

	When I (the tutor) say something to you, it will start with "$(grn Tutor):".
	This lets you distinguish my messages from output produced by the other
	commands you will run.

	                               ${_W} .0000.    .0000. ${_z}
	                               ${_W},000000,  ,000000,${_z}
	$(cyn "Do not skim; read everything!")  ${_W}00  0000  00  0000${_z}
	                               ${_W}'000000'  '000000'${_z}
	                               ${_W} '0000'    '0000' ${_z}

	Otherwise, you $(bld will) get lost.

	:
	_tutr_pressenter

	cat <<-:

	Speaking of important instructions, this is how you can make sure to get
	credit for finishing this lesson:

	After your progress bar is filled up, I will make some concluding
	remarks and then record your completion.  If you close the tutorial
	$(bld before) it quits on its own (say, by clicking the $(red close) button up in the
	corner of this window), this record is not made and you will need to do
	the lesson $(bld all over again).

	This is a map of the tutorial:

	   +-- You are here
	   |
	$(_tutr_progress)

	The $(red red) boxes are lessons that are not complete.
	They turn $(blu blue) when you finish them.

	You can safely close this window the next time you see this map.

	:
	_tutr_pressenter

	cat <<-:

	If these words are too hard to read, try changing the font size.
	The exact method depends on your software, but these instructions
	may do the trick.

	:

	if [[ "$TERM_PROGRAM" == Apple_Terminal || $_PLAT == Apple ]]; then
		cat <<-:
		* $(kbd "Command+=") (Command equal sign) makes text $(bld bigger) (it is listed as
		  $(kbd Command plus), but you do not need to hold $(kbd Shift) for it to work)
		* $(kbd "Command+-") (Command minus) makes text $(bld smaller)
		* Find the settings labeled $(bld Bigger) and $(bld Smaller) in the $(bld View) menu
		:

	elif [[ $_PLAT == MINGW && "$TERM_PROGRAM" == mintty ]]; then
		cat <<-:
		* $(kbd "Ctrl+=") (Control equal sign) makes text $(bld bigger) (it is listed as
		  $(kbd Control plus), but you do not need to hold $(kbd Shift) for it to work)
		* $(kbd "Ctrl+-") (Control minus) makes text $(bld smaller)
		* Right click the window's title bar, choose $(bld Options), select $(bld Text) in the
		  tree on the left, then pick a larger font.  Click $(bld Save) to make your
		  choice permanent.
		:

	elif [[ $_PLAT == MINGW && -n "$_WT_SESSION" ]]; then
		cat <<-:
		* $(kbd "Ctrl+=") (Control equal sign) makes text $(bld bigger) (it is listed as
		  $(kbd Control plus), but you do not need to hold $(kbd Shift) for it to work)
		* $(kbd "Ctrl+-") (Control minus) makes text $(bld smaller)
		* Open the Settings page by pressing $(kbd "Ctrl+,") (Control comma), or by clicking
		  the chevron symbol in the tab bar (it looks like a "$(bld V)"), then
		  go to $(bld Defaults) under the $(bld Profiles) section in the left menu bar, then
		  open $(bld Appearance) under the $(bld Additional) Settings section.
		  Under $(bld Text) adjust the $(bld Font size), then click $(bld Save) to make your choice permanent.
		:

	else
		cat <<-:
		* $(kbd "Ctrl+=") (Control equal sign) makes text $(bld bigger) (it is listed as
		  $(kbd Control plus), but you do not need to hold $(kbd Shift) for it to work)
		* $(kbd "Ctrl+-") (Control minus) makes text $(bld smaller)
		* Find the font settings in the $(bld Edit) or $(bld View) menu
		:
	fi

	cat <<-:

	If all else fails, you can $(_Google) it.

	:
	_tutr_pressenter
}


tutor_bug_prologue() {
	cat <<-:
	One of the things that you will learn this semester is that it is very
	difficult to write good, correct code.  This tutorial is no exception.

	I don't want to alarm you, but it is quite likely that you will uncover
	a bug in this tutorial.  It might be a crash, a glitch, or even a
	"mis-speled" word.

	When that happens to you, $(mgn "DON'T PANIC!")  Keep a level head and help me
	fix it.  Just remember to run this command:
	  $(cmd tutor bug)

	I want you to try this now.  The message you are about to see will
	apologize for a bug and ask you to send me an email.  $(bld IT IS NOT A BUG!)
	Please don't send me an email now!  This is just a dry-run.
	:
}

tutor_bug_test() {
	_tutr_generic_test -c tutor -a bug
}

tutor_bug_hint() {
	if [[ $1 == $MISSPELD_CMD ]]; then
		_tutr_generic_hint $1 tutor
	fi

	cat <<-:
	Let's try that again.
	The command to run looks like this:
	  $(cmd tutor bug)
	:
}

tutor_bug_epilogue() {
	_tutr_pressenter

	cat <<-:

	When a $(bld real) problem occurs I want you to run $(cmd tutor bug), scroll up in the
	window and copy the text leading up to your problem all the way down
	through $(cmd tutor bug)'s output.  And by "$(cyn copy the text)" I don't mean "take a
	screenshot".  Use your mouse to highlight the words, then open the Edit
	menu and click "Copy".

	By the way, you can quit this tutorial at any time by running $(cmd exit) or
	$(cmd tutor quit).  But the only way to win is to stick with it to the end.

	Now you're $(bld really) ready to begin!

	:
	_tutr_pressenter
}



hello_world_prologue() {
	cat <<-:
	${_W}oooooooooooooooooooooooooooooo${_Z}
	${_W}8                          888${_Z}
	${_W}8  ${_g}ooooooooooooooooooooooo ${_W}888${_Z}   The Unix Command Line Interface (CLI)
	${_W}8  ${_g}88888888888888888888888 ${_W}888${_Z}   lets you talk to your computer with a
	${_W}8  ${_g}8888888888888888888888P ${_W}888${_Z}   simple programming language.  This
	${_W}8  ${_g}8888888888888888888P"   ${_W}888${_Z}   environment is called the $(bld Shell)
	${_W}8  ${_g}8888888888888888P"      ${_W}888${_Z}
	${_W}8  ${_g}8888888888888P"         ${_W}888${_Z}   In contrast to other languages you have
	${_W}8  ${_g}8888888888P"            ${_W}888${_Z}   used, the Unix shell prioritizes
	${_W}8  ${_g}8888888P"               ${_W}888${_Z}   $(bld interactivity) above all else.
	${_W}8  ${_g}8888P"                  ${_W}888${_Z}
	${_W}8  ${_g}8P"                     ${_W}888${_Z}   Thus, it was intentionally designed
	${_W}8 .od888888888888888888${_R}c${_G}g${_B}mm${_W}888${_Z}   to be easy to type:
	${_W}888888888888888888888888888888${_Z}
	${_W}                              ${_Z}   * Commands have $(cyn short names)
	${_W}    oooooooooooooooooooooo    ${_Z}   * $(cyn Minimal) punctuation is required
	${_W}   d${_w}               ..oood8${_W}b   ${_Z}   * Only $(cyn one type) of data (string)
	${_W}  d${_w}         ..oood888888888${_W}b  ${_Z}
	${_W} d${_w}   ..oood88888888888888888${_W}b ${_Z}
	${_W}dood8888888888888888888888888b${_Z}


	:

	_tutr_pressenter

	cat <<-:

	Begin by saying "Hello World" the command-line way.
	In $(_py) you would write:
	  $(_code 'print("Hello, World")')

	But here in the shell it looks like this:
	  $(cmd echo Hello, World)

	Notice that the arguments $(cmd Hello,) and $(cmd World) are not quoted.

	Run this command now.
	:
}

hello_world_test() {
	_PREV1=${_CMD[1]}
	_PREV2=${_CMD[2]}
	[[ $( echo "${_CMD[@]}" | tr A-Z a-z | tr -d ,) == "echo hello world" ]] && return 0
	_tutr_damlev "${_CMD[0]}" "echo" 2 && return $MISSPELD_CMD
	[[ $_SH = Zsh && ${_CMD[0]} = print ]] && return 99
	[[ ${_CMD[0]} != echo ]] && return $WRONG_CMD
	[[ ${#_CMD[@]} -lt 3 ]] && return $TOO_FEW_ARGS
	[[ ${#_CMD[@]} -gt 3 ]] && return $TOO_MANY_ARGS
	return $WRONG_ARGS
}

hello_world_hint() {
	case $1 in
		99)
			cat <<-:
			Because you're using the $(bld Zsh) shell, you actually have a
			command called $(cmd print) that is equivalent to $(cmd echo).

			Because most students use the $(bld Bash) shell, I encourage $(cmd echo)
			for consistency's sake.
			:
			;;
		*)
			_tutr_generic_hint $1 echo "$_BASE"
			;;
	esac

	cat <<-:

	Run $(cmd echo Hello, World)
	:
}

hello_world_epilogue() {
	_tutr_pressenter
	echo
	if [[ "echo Hello, World" != ${_CMD[@]} ]]; then
		cat <<-:
		Eh, "$(cmd ${_CMD[@]})" is close enough for now...

		In the shell, as with $(_py), details like CASE and "punctuation"
		matter.  Be diligent and follow instructions $(bld exactly)!

		:
		_tutr_pressenter
		echo
	fi

	cat <<-:
	Shell commands can take arguments, just like functions in $(_py).
	The strings $(cyn "'$_PREV1'") and $(cyn "'$_PREV2'") were arguments to $(cmd echo).

	Shell commands follow this syntax:
	  $(cmd 'command [argument ...]')

	The square brackets surrounding $(cmd 'argument...') in the example indicate
	an optional portion.  The ellipsis ($(cmd ...)) means that there may be more
	arguments beyond the first one.  All together, this example means
	"$(cyn \'command\' takes zero or more arguments)".

	Unlike $(_py) and Java, parentheses do not surround the argument list of
	shell commands.  Spaces separate arguments from each other instead of
	commas.  It $(bld does not) matter how many spaces are present.  One, two or
	twenty - it's all the same.

	:

	_tutr_pressenter

	cat <<-:

	In the shell $(bld everything) is regarded as a string - even numbers.  This is
	why you don't need quote marks around the words $(cyn "'$_PREV1'") and $(cyn "'$_PREV2'").

	The comma following $(cyn "'Hello,'") in the command
	  $(cmd echo Hello, World)
	isn't special; it is just part of the string $(cyn "'Hello,'").

	Now, there are cases where quote marks are mandatory; this just isn't
	one of them.  Of course, you could use quote marks if you really wanted
	to, like this:
	  $(cmd echo \"Hello, World\")

	:

	_tutr_pressenter

}



echo_no_args_prologue() {
	cat <<-:
	Part of studying $(_py) is learning which $(_code functions) can be used and
	how to call them.

	The Unix shell is similar.  Here you learn what $(cmd commands) exist and how
	to run them.

	$(cmd echo) is the shell's equivalent to $(_py "Python's") $(_code 'print()') function.  Just
	like $(_code 'print()'), $(cmd echo) takes any number of arguments.  Zero, one, two,
	or twenty; it's all good.

	The $(cmd echo) command has this syntax:
	  $(cmd 'echo [WORD...]')

	This means that $(cmd echo) can take zero or more $(cmd WORDs) as arguments.

	Run $(cmd echo) again, but without any arguments.
	:
}

echo_no_args_test() {
	_tutr_generic_test -c echo
}


echo_no_args_hint() {
	_tutr_generic_hint $1 echo "$_BASE"

	cat <<-:

	Simply run $(cmd echo) with no arguments to see what happens.
	:
}

echo_no_args_epilogue() {
	_tutr_pressenter
	cat <<-:

	Just like $(_code 'print()'), running $(cmd echo) with no arguments outputs a blank line.

	Arguments are passed into commands as a $(bld list of strings).  It is up to
	each command to decide how many arguments to take, what order they
	should appear, and what each should mean.

	Some commands, like $(cmd echo), are happy with $(bld any) number of arguments.
	Other commands are picky about their arguments.  Often, they will
	display a helpful error message when given invalid input.

	In the next lesson you will learn how to read the instruction manual for
	each command.  This will help you learn what commands exist and how to
	use them.

	:
	_tutr_pressenter

	cat <<-:

	You will encounter nearly two dozen commands
	throughout the course of this tutorial.         ${_W}(\\
	It is a lot to absorb!                          ${_W}\\${_y}'${_W}\   ${_z} __________
	                                                ${_W} \\${_y}'${_W}\  ${_z}()_________)
	Students have reported learning these commands  ${_W} / ${_y}'${_W}| ${_z} \  ${_B}Make a${_z}  \\
	more quickly by keeping notes as they work      ${_W} \ ${_y}'${_W}/ ${_z}   \ ${_B}  Note!${_z}  \\
	through the tutorial.                           ${_y}   \  ${_z}     \__________\\
	                                                ${_B}   ==). ${_z}   ()__________)
	Be sure to record the command's $(red name),           ${_B}  (__)${_z}
	its $(blu purpose), and what $(grn arguments) it takes.

	After a few weeks you will not need these notes to use the shell.
	But until then, they are invaluable!

	:
	_tutr_pressenter
}


ls_prologue() {
	cat <<-:
	The $(cmd ls) command lists files.

	Run $(cmd ls) to see what files are here.
	:
}

ls_test() {
	[[ $PWD != "$_BASE" ]] && return $WRONG_PWD
	[[ ( ${_CMD[0]} == ls || ${_CMD[0]} == dir ) && ${#_CMD[@]} -ne 1 ]] && return $TOO_MANY_ARGS
	[[ ${_CMD[@]} == ls ||  ${_CMD[@]} == dir ]] && return 0
	_tutr_damlev "${_CMD[0]}" ls 1 && return $MISSPELD_CMD
	[[ ( ${_CMD[0]} != ls && ${_CMD[0]} != dir ) ]] && return $WRONG_CMD
}

ls_hint() {
	_tutr_generic_hint $1 ls "$_BASE"

	cat <<-:

	Run $(cmd ls) with no arguments to list the files that are here
	:
}

ls_epilogue() {
	if [[ ${_CMD[@]} == dir ]]; then
		_tutr_pressenter
		cat <<-:

		A Windows user, eh?

		Unix also has a command called $(cmd dir), but it is not commonly used.
		One extra letter is too much for lazy Unix-folk to type.

		This tutorial will use $(cmd ls) from now on.
		:
	fi

	_tutr_pressenter

	cat <<-:

	Remember, lines without $(grn Tutor): come from the commands you run.

	$(cmd ls) revealed that there are $(bld three) files here.  You will take a closer look
	at each of these files throughout this tutorial.

	:
	_tutr_pressenter
}


## Generic test for the cat steps
# Usage: cat_GENERIC_test filename
cat_GENERIC_test() {
	_CORRUPTED=99
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	if [[ ${_CMD[0]} == cat ]]; then
		[[ ${#_CMD[@]} -eq 1 ]] && return $TOO_FEW_ARGS
		[[ ${#_CMD[@]} -gt 2 ]] && return $TOO_MANY_ARGS
		[[ ${_CMD[1]} == $1 ]] && return 0
		[[ ${_CMD[1]} == corrupt_terminal ]] && return $_CORRUPTED
		return $WRONG_ARGS
	fi
	_tutr_noop && return $NOOP
	_tutr_generic_test -c cat -a $1
}



## Generic guidance for the cat steps
# Usage: cat_GENERIC_hint status_code filename
cat_GENERIC_hint() {
	case $1 in
		$NOOP)
			return
			;;

		$_CORRUPTED)
			reset
			echo "It is not time for that file yet."
			;;

		$TOO_FEW_ARGS)
			cat <<-:
			$(bld "What just happened?")

			Because you didn't tell $(cmd cat) which file to read, it started reading
			you!  If you typed any words and hit $(kbd Enter), they were duplicated on the
			screen.

			Remember that $(kbd Ctrl-C) (a.k.a. $(kbd ^C)) is your general purpose "get me out
			of this program" tool.  Try it any time a command gets stuck or freezes.

			It usually works.
			:
			;;

		$TOO_MANY_ARGS)
			cat <<-:
			You've figured out how to concatenate many files.  Cool!
			This will actually come in handy later on in the course.

			But for now, I need you to only $(cmd cat) the one file I asked for.
			Precision counts!
			:
			;;

		*)
			_tutr_generic_hint $1 cat "$_BASE"
			;;
	esac

	if [[ -n "$2" ]]; then
		cat <<-:

		Use $(cmd cat) to print the contents of $(path $2) to the screen.
		:
	fi

	cat <<-:
	If it freezes, press $(kbd Ctrl-C) to return to the shell prompt.
	:
}



cat_textfile_prologue() {
	cat <<-:
	You can read files in the shell with the $(cmd cat) command.  Its name is short
	for "$(bld Concatenate)".  This program is meant to join several files into
	one.  It takes as arguments names of files and prints their contents,
	one by one, onto the screen.
	  $(cmd 'cat [filename ...]')

	Because it works fine with only one file, it has become the standard text
	viewer in Unix.

	One of the files here is called $(path textfile.txt).  Print its contents
	to the screen by running $(cmd cat) with the single argument $(path textfile.txt).

	If $(cmd cat) gets stuck, press $(kbd Ctrl-C) to $(red cancel) it and try again.
	:
}

cat_textfile_test() {
	cat_GENERIC_test textfile.txt
}

cat_textfile_hint() {
	cat_GENERIC_hint $1 textfile.txt
}

cat_textfile_epilogue() {
	_tutr_pressenter
}


echo_textfile_prologue() {
	cat <<-:
	So what's the difference between $(cmd cat) and $(cmd echo)?

	*  $(cmd cat) shows what's on the $(bld inside) of a file named as its argument
	*  $(cmd echo) just repeats its arguments $(bld verbatim)

	Now that you've seen what $(cmd cat) does with the argument $(path textfile.txt), run
	  $(cmd echo textfile.txt)
	to see this difference firsthand.
	:
}

echo_textfile_test() {
	_tutr_generic_test -c echo -a textfile.txt -d "$_BASE"
}

echo_textfile_hint() {
	if [[ ${_CMD[@]} == "cat textfile.txt" ]]; then
		cat <<-:
		That's what I asked you to run last time!

		:
	fi

	_tutr_generic_hint $1 echo "$_BASE"
	cat <<-:

	This time you need to $(cmd echo) the filename $(path textfile.txt)
	:
}

echo_textfile_epilogue() {
	_tutr_pressenter

	cat <<-:

	To recap:
	  * $(cmd echo) just repeats what it is told to say
	  * $(cmd cat) lets you see what is inside a file
	  * $(cmd ls) shows you which files are present

	:
	_tutr_pressenter
}


cat_markdown_prologue() {
	cat <<-:
	Unix doesn't put as much importance on file names as other operating
	systems do.  A name ending in $(path .txt) is not what makes a text file.
	It's what's on the inside that counts.

	One kind of file that you will use this semester is the Markdown file.
	Markdown files are just text files with names ending in $(path .md).
	$(cmd cat) is a great tool for reading these files.

	Give the name of the Markdown file as an argument to $(cmd cat).

	You can use $(cmd ls) to remind yourself of its name.
	:
}

cat_markdown_test() {
	cat_GENERIC_test markdown.md
}

cat_markdown_hint() {
	cat_GENERIC_hint $1 markdown.md
}

cat_markdown_epilogue() {
	_tutr_pressenter
}


clear_prologue() {
	cat <<-:
	By now you've filled up your screen with lots of text.
	It's nice to get back to a fresh, blank slate.

	You can clear the screen with the cleverly-named $(cmd clear) command.

	Its syntax is very simple:
	  $(cmd clear)

	Try it now.
	:
}

clear_test() {
	_tutr_generic_test -c clear
}

clear_hint() {
	_tutr_generic_hint $1 clear
}

clear_epilogue() {
	_tutr_pressenter
}


ls_a_prologue() {
	cat <<-:
	I wasn't being completely honest with you when I said that there were
	four files.  There is a stowaway among us.

	$(cmd ls) can take an option $(cmd -a) that makes it show $(bld all) files, even hidden ones.

	Run $(cmd ls) with the $(cmd -a) option now.
	:
}

NEED_SPACES=99
NOT_WINDOWS=98
ls_a_test() {
	[[ ${_CMD[0]} =~ ^ls- ]] && return $NEED_SPACES
	[[ ${_CMD[0]} = dir ]] && return $NOT_WINDOWS
	if [[ $_PLAT = Apple ]]; then
		# `ls --all` doesn't work on MacOS
		_tutr_generic_test -c ls -a -a -d "$_BASE"
	else
		_tutr_generic_test -c ls -a '^-a$|^--all$' -d "$_BASE"
	fi
}

ls_a_hint() {
	case $1 in
		$NEED_SPACES)
			cat <<-:
			Try adding a space between $(cmd ls) and $(cmd -a).

			:
			;;
		$NOT_WINDOWS)
			cat <<-:
			This isn't Windows.  Use $(cmd ls) here.

			:
			;;
		*)
			_tutr_generic_hint $1 ls "$_BASE"
			;;
	esac

	cat <<-:
	Give the $(cmd ls) command the $(cmd -a) option.

	:
}

ls_a_epilogue() {
	_tutr_pressenter
}


cat_hidden_prologue()  {
	cat <<-:
	Do you see the three files with names beginning with '$(bld .)'?

	They may look funny, but those are valid file names in Unix.

	Use $(cmd cat) to see what's in the file named $(path .hidden).
	:
}

cat_hidden_test() {
	cat_GENERIC_test .hidden
}

cat_hidden_hint() {
	cat_GENERIC_hint $1 .hidden
}

cat_hidden_epilogue() {
	_tutr_pressenter
}


reset_prologue() {
	cat <<-:
	So far you have learned a few ways to put text on the screen,
	and you can clear it off again:

	  * $(cmd echo) prints its arguments
	  * $(cmd ls) prints a listing of files
	  * $(cmd cat) prints the contents of files
	  * $(cmd clear) erases everything on the screen

	For the rest of this lesson you will leave the happy path and learn
	how to cope $(_err when things go wrong).

	:
	_tutr_pressenter

	cat <<-:

	Although $(cmd cat) is intended for text files, there is nothing keeping you
	from $(cmd cat)-ing non-text files like $(cyn MP3s), $(cyn PDFs), $(cyn JPEGs) or $(cyn ZIPs) to the
	screen.  You just might learn something from what you see.

	However, there is a possibility that this will make your terminal go
	$(mgn haywire).  The effect is not permanent, and nothing is ruined.
	But it can happen when you're working with data, so you need to be
	prepared for it.  In a moment I will make you do it on purpose.

	First, I need to show you how to fix a $(mgn corrupted) terminal with the
	$(cmd reset) command.

	:

	_tutr_pressenter

	cat <<-:

	Don't worry, this won't reboot your computer!  $(cmd reset) just tells the
	terminal to re-initialize itself so you can read it again.  You'll see
	what I mean in a moment.

	Let's do a dry-run of $(cmd reset).
	:
}

reset_test() {
	_tutr_generic_test -c reset
}

reset_hint() {
	_tutr_generic_hint $1 reset
}

reset_epilogue() {
	cat <<-:
	$(cmd reset) seems like a slower version of $(cmd clear).  What good is it?

	:
	_tutr_pressenter
}


cat_corrupt_pre() {
	_make_corrupt_terminal
}

cat_corrupt_prologue() {
	cat <<-:
	I just created a new file called $(path corrupt_terminal).  When you display it
	with $(cmd cat), raw data is sent to the terminal where it is misinterpreted,
	resulting in an unreadable, garbled display.

	You can still run commands when the terminal is in this state.  However,
	results will look like gibberish.  This is because the $(bld Shell) and the
	$(bld Terminal) are two separate programs.

	:

	 _tutr_pressenter

	if [[ $_SH = Zsh ]]; then
		local shel=$(blu " Zsh")
	else
		local shel=$(blu Bash)
	fi

	cat <<-:
	                                                       ${_W}+--------------+
	                                                       ${_W}|.------------.|
	$(bld Terminal): Depending on your system, this is a $(rev black)    ${_W}||${_G}$ _${_W}         ||
	window with a grid of $(bld white) text, or a $(bld white) window    ${_W}||            ||
	with $(rev black) text.  It reads the keyboard and displays   ${_W}||            ||
	text generated by programs.                            ${_W}||            ||
	                                                       ${_W}|+------------+|
	                                                       ${_W}+-${_b}==${_W}-----------+${_z}

	${_Y}       _.-''|''-._        ${_z}           $(bld Shell): On your computer this is a
	${_Y}    .-'     |     \`-.    ${_z}  program called $shel.  Its job is to talk to
	${_Y}  .'\       |       /\`.  ${_z}         the Operating System on your behalf.
	${_Y}.'   \      |      /   \`.${_z}    It reads your commands from the keyboard,
	${_Y}\     \     |     /     / ${_z}  checks whether they are valid and that you
	${_Y} \`\    \    |    /    /' ${_z}   have permission.  Then it carries them out
	${_Y}   \`\   \   |   /   /'   ${_z}        and tells you if anything went wrong.
	${_Y}     \`\  \  |  /  /'     ${_z}
	${_Y}    _.-\`\ \ | / /'-._    ${_z} In this way $shel protects the delicate, soft
	${_Y}   {_____\`\\|//'_____}   ${_z} Operating System from your carelessness, just
	${_Y}           \`-'           ${_z}     as a clam is safe inside its hard shell.

	:

	_tutr_pressenter

	cat <<-:


	When the terminal is $(mgn corrupted), $shel is unfazed and can still execute
	your commands.  After this happens, try running $(cmd echo), $(cmd ls) and $(cmd clear).
	When you're done, use $(cmd reset) to restore the terminal to working order.

	Are you ready to $(cmd cat corrupt_terminal)?
	:
}


cat_corrupt_test() {
	cat_GENERIC_test corrupt_terminal
}

cat_corrupt_hint() {
	case $1 in
		$WRONG_CMD)
			cat <<-:
			Oh, don't be scared!
			Trust me, you'll be fine!

			:
			;;
		*)
			cat_GENERIC_hint $1 corrupt_terminal
			;;
	esac
}


reset_again_test() {
	[[ ${_CMD[@]} == reset ]] && return 0
}

reset_again_epilogue() {
	cat <<-:
	Most Unix newcomers think they must close and restart the terminal when
	that happens.  That's a lot of hassle when relief is just six keystrokes
	away!

	$(cmd reset) causes the terminal to re-initialize itself.
	It does not need any arguments.

	:
	_tutr_pressenter
}


plain_cat_prologue() {
	cat <<-:
	It's important to feel in control of the computer and know that you can
	handle any situation thrown your way.  Programs often freeze and need to
	be forcibly stopped.  While you $(bld could) close the window on a frozen
	program, it is a drastic response to a simple problem.

	Here is a better way: press $(kbd Ctrl-C) to $(red cancel) the frozen program and
	regain control of the shell.

	Did you know that you can get $(cmd cat) stuck just by running it with zero
	arguments?

	Run $(cmd cat) this way and stop it with $(kbd Ctrl-C).
	:

}

plain_cat_test() {
	[[ ${_CMD[@]} == cat ]] && return 0
	[[ ${_CMD[0]} == cat && ${#_CMD[@]} -gt 1 ]] && return $TOO_MANY_ARGS
	_tutr_damlev "${_CMD[0]}" cat 2 && return $MISSPELD_CMD
	return $WRONG_CMD
}

plain_cat_hint() {

	_tutr_generic_hint $1 cat
	cat <<-:

	Run $(cmd cat) with no arguments, then stop it with $(kbd Ctrl-C).
	:
}

plain_cat_epilogue() {
	if (( $_RES == 0 )); then
		cat <<-:
		If I'm not mistaken, you pressed $(kbd Ctrl-D) instead of $(kbd Ctrl-C).  That is
		understandable as those keys are so close to each other.

		While $(kbd Ctrl-D) does work in certain situations, $(kbd Ctrl-C) is more general and
		works across most programs in the shell.

		Just be careful with $(kbd Ctrl-D), as it can kill the shell, too.  It would
		be a shame if you had to re-do a lesson because you pressed it at the
		wrong moment.
		:
	elif (( $_RES != 130 )); then
		cat <<-:
		Isn't there a saying "$(cyn There is more than one way to kill a cat)"?
		Well, it's something like that.  Anyhow, you just found a new way.

		I want you to remember $(kbd Ctrl-C) because it is likely to work in
		more programs than whatever you just did.
		:
	else
		echo "Thats the way!"
	fi

	cat <<-:

	You might be wondering why $(kbd Ctrl-C) doesn't mean $(cyn Copy) in the shell.

	$(kbd Ctrl-C) as $(red cancel) predates the familiar $(cyn Undo), $(cyn Cut), $(cyn Copy), and $(cyn Paste)
	shortcuts by a good decade or so.  None of the shortcuts that you have
	used in other applications do what you expect in the shell.
	You'll just have to retrain your fingers.

	:
	_tutr_pressenter
}


cat_nofile_prologue() {
	cat <<-:
	Another common mistake new programmers make is to not pay attention to
	what the computer is telling them.  The command line interface is a
	conversation with your computer.  Conversations go both ways.

	Get in the habit of carefully reading $(bld all) messages presented to you.
	You'll save countless hours of frustration when the answer is right in
	front of your nose.

	One of the most common errors that your computer gives is "$(_err No such file)
	$(_err or directory)".  You'll be seeing this one a lot, so let's get it over
	with.

	Run $(cmd cat) with an argument that is NOT the name of any file here.
	Use $(cmd ls) to remind yourself which files $(bld are) here so you can pick
	one that isn't.
	:
}

cat_nofile_test() {
	_CORRUPTED=99
	_FOUND_FILE=98
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	if [[ ${_CMD[0]} == cat ]]; then
		[[ ${#_CMD[@]} -eq 1 ]] && return $TOO_FEW_ARGS
		[[ ${_CMD[1]:0:1} == - ]] && return $WRONG_ARGS
		[[ ! -f ${_CMD[1]} ]] && return 0
		[[ ${_CMD[1]} == corrupt_terminal ]] && return $_CORRUPTED
		return $_FOUND_FILE
	fi
	_tutr_damlev "${_CMD[0]}" cat 2 && return $MISSPELD_CMD
	_tutr_noop && return $NOOP
	return $WRONG_CMD
}

cat_nofile_hint() {
	case $1 in
		$NOOP)
			return
			;;
		$_FOUND_FILE)
			rm -f missing
			cat <<-:
			For this one you need to try to $(cmd cat) a file that $(bld "DOESN'T") exist here.
			$(path missing) is the name of a file that doesn't exist here.

			Try $(cmd cat)-ing $(path missing).
			:
			;;
		$WRONG_ARGS)
			cat <<-:
			While ${_CMD[1]} technically isn't the name of a file here, many
			shell commands regard arguments beginning with one or more '-' as
			OPTIONS instead of FILES.

			They're treated as a class of their own.
			:
			;;
		*)
			cat_GENERIC_hint $1
			;;
	esac

	cat <<-:

	Run $(cmd cat) with an argument that is NOT the name of a file.
	:
}

cat_nofile_epilogue() {
	_tutr_pressenter
	echo
	echo "See, that wasn't so bad, was it?"
	echo
	_tutr_pressenter
}


cat_permission_denied_prologue() {
	cat <<-:
	Another common error is "$(_err Permission denied)".  I have prepared a file
	named $(path top.secret) that will cause that error when you try to $(cmd cat) it.

	Why don't you give it a try?
	:
}

cat_permission_denied_test() {
	cat_GENERIC_test top.secret
}

cat_permission_denied_hint() {
	cat_GENERIC_hint $1 top.secret
}

cat_permission_denied_epilogue() {
	_tutr_pressenter
	echo

	if [[ $_RES -eq 0 ]]; then
		cat <<-:
		Huh, that actually worked on your computer?

		Rest assured that I'm just as disappointed about this as you are.

		:
	else
		cat <<-:
		Don't worry, you aren't missing anything.
		That file isn't as interesting as the others.

		:
	fi

	_tutr_pressenter
}


command_not_found_prologue() {
	cat <<-:
	The last common error you will encounter is "$(_err command not found)".
	Sometimes this occurs because you don't have a program installed.
	At other times the program $(bld is) installed, but the shell cannot find it.

	If you're like me you make $(bld lots) of typing mistakes.  This is the source
	of 99% of my own "$(_err command not found)" errors.  You'll see me misspell
	$(cmd python) as $(blu pyhton) in nearly every lecture.

	Better start getting used to it.  Try running $(cmd pyhton) (or some other
	misspelled command of your own creation) and see what the shell has to
	say about it.
	:
}

command_not_found_test() {
	if   _tutr_noop; then return $NOOP
	elif (( _RES == 0 )); then return $WRONG_CMD
	elif (( _RES == 127 )); then return 0
	else return 99
	fi
}

command_not_found_hint() {
	case $1 in
		$WRONG_CMD)
			cat <<-:
			$(cmd ${_CMD[0]}) was a valid command.

			C'mon, you can screw up better than that!
			:
			;;
		*)
			_tutr_generic_hint $1 pyhton
			;;
	esac

	cat <<-:

	Try running $(cmd pyhton) (or some other misspelled command of your own
	creation) to see how the shell responds.
	:
}

command_not_found_epilogue() {
	_tutr_pressenter
	cat <<-:

	See, nothing terrible happened.  You're gonna be okay.

	:
	_tutr_pressenter
}


epilogue() {
	cat <<-EPILOGUE
	Here we are at the end of your zeroth lesson.  I'm very proud of you!

	         $(red DO NOT CLOSE THE TERMINAL WINDOW YET!)

	The tutorial must shut down so you can get credit for this lesson.
	If you close the window too soon, you'll have to re-do $(bld the whole thing).

	Just keep pressing $(kbd ENTER) until you see the tutorial map.

	EPILOGUE

	_tutr_pressenter

	cat <<-EPILOGUE

	In this lesson you learned about:

	* Using the Unix command line interface (CLI)
	* Commands and arguments
	* Hidden files
	* The difference between the 'shell' and the 'terminal'
	* How to clear and reset the terminal
	* Cancelling a runaway command
	* Understanding messages and recovering from errors

					 $(blk ASCII art credit: Al Tinsley, Graeme Porter, Joan Stark)
	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}



source main.sh && _tutr_begin \
	tutor_hint \
	tutor_bug \
	hello_world \
	echo_no_args \
	ls \
	cat_textfile \
	echo_textfile \
	cat_markdown \
	clear \
	ls_a \
	cat_hidden \
	reset \
	cat_corrupt \
	reset_again \
	plain_cat \
	cat_nofile \
	cat_permission_denied \
	command_not_found

# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
