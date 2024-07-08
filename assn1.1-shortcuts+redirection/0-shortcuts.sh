#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=20

# Put tutorial library files into $PATH
PATH="$PWD/.lib:$PATH"

source ansi-terminal-ctl.sh
source platform.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source noop.sh
fi


_create_files() {
	cat <<-TEXT > "$_BASE/.solution.txt"
	${_w}   ${_M} __                          _     ___       _     _
	${_w} . ${_M}/ _\\_ __   __ _  ___ ___  __| |   /___\\_   _| |_  / \\
	${_w}   ${_M}\\ \\| '_ \\ / _\` |/ __/ _ \\/ _\` |  //  // | | | __|/  /
	${_w}.  ${_M}_\\ \\ |_) | (_| | (_|  __/ (_| | / \\_//| |_| | |_/\\_/
	${_w}   ${_M}\\__/ .__/ \\__,_|\\___\\___|\\__,_| \\___/  \\__,_|\\__\\/
	${_w}   ${_M}   |_|${_w}                        .                   .
	${_w}        .        .                        ${_y}     _.._
	${_w}  ,          .             ,        .     ${_y}  .' .-'\`
	${_w} -o-               .      -o-             ${_y} /  /       ${_w}.
	${_w}  '                        '              ${_y}(   (
	${_w}        .  ${_W}    .-""\`""-.          ${_w},   .  ${_y}  \\  \\
	${_w}           ${_W} _/\`${_g}oOoOoOoOo${_W}\`\\_${_w}      -o-   ${_y}     '._'-._    ${_w}.
	${_w}           ${_W}'.-=-=-=-=-=-=-.' ${_w}     '       . ${_y}   \`\`\`
	${_w} .     ${_K}jgs ${_W}  \`-=.=-.-=.=-'${_w}                      .
	${_w}                ${_W}^  ^  ^${_w}      .             .
	${_w}                  ${_C}| \\${_w}
	${_w}          .       ${_C}|  \\${_w}   .         .      ,             .
	${_w}                 .${_C}|   \\${_w}    .    ,        -o-    .
	${_w}         ,        ${_C}|    \\${_w}       -o-        '
	${_w}   .    -o-   .   ${_C}|     \\${_w}       '      .
	${_w}         '        ${_C}|      \\${_w}                    .
	${_w}                . ${_C}|       \\${_w} .                      .
	${_w}      .           ${_C}|        \\${_w}            .       ,         .
	${_w}         .   .    ${_C}|         \\${_w}    .             -o-
	${_w}  .               ${_C}|${_W}       _  ${_C}\\${_w}                  '     .
	${_w}                  ${_C}|${_W}      / \\  ${_C}\\${_W}       ______________________
	${_w}                  ${_C}|${_W}     (${_G}0 0${_W})  ${_C}\\ ${_W}    ( Don't probe me, Bro! )
	${_w}        .         ${_C}|${_W}      \\=/    ${_C}\\ ${_w}.  ${_W}\`----------------------'
	${_w}            .     ${_C}|${_W}     .-"-.    ${_C}\\    ${_W}O
	${_w}                  ${_C}|${_W}    //\\ /\\\\    ${_C}\\    ${_W}o          .
	${_w} .            .   ${_C}|${_W}  _// | | \\\\_   ${_C}\\    ${_W}o.${_Y}(${_y}__${_Y})${_y}          /
	${_w}        .         ${_C}|${_W} (./ {,-.} \\.)   ${_C}\\     ${_y}(${_W}OO${_y})\\_______ /
	${_R}      , ${_w}     .    ${_C}|${_W}     || ||    ${_K}hjw ${_C}\\    ${_y}(__)\\       )
	${_R}     -@-          ${_C}|${_W}     || ||    ${_K}\`97  ${_C}\\    ${_R}U  ${_y}||-----${_y}||
	${_G}     \\|/          ${_C}|${_W}   __|| ||__        ${_C}\\      ${_y}||     ||
	${_G}\\.//\\.|.~\\/.\\\\/.\\/\\.\\${_W}\`---" "---'${_G}\\/\\.\\/.\\/~.\\.\\////.\\/\\./\\.\\/
	TEXT

	<"$_BASE/.solution.txt" sed -n 1,4p   >"$_BASE/painstakingly.txt"
	<"$_BASE/.solution.txt" sed -n 5,9p   >"$_BASE/nonsequential.txt"
	<"$_BASE/.solution.txt" sed -n 10,14p >"$_BASE/fragmentary.txt"
	<"$_BASE/.solution.txt" sed -n 15,19p >"$_BASE/reorganization.txt"
	<"$_BASE/.solution.txt" sed -n 20,23p >"$_BASE/disorganized.txt"
	<"$_BASE/.solution.txt" sed -n 24,27p >"$_BASE/combinatorially.txt"
	<"$_BASE/.solution.txt" sed -n 28,31p >"$_BASE/sequentializing.txt"
	<"$_BASE/.solution.txt" sed -n 32,36p >"$_BASE/obfuscatory.txt"
}


solution() {
	cat "$_BASE/.solution.txt"
	_tutr_pressenter
}

setup() {
	source screen-size.sh 80 42

	export _HERE="$PWD"
	export _BASE="$PWD/shortcuts"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"
	_create_files

	case $_OS in
		MacOSX)
			export _BACKSPACE="  $(kbd Delete) | Erase the character to the LEFT of the cursor"
			;;
		*)
			export _BACKSPACE="$(kbd Backspace)| Erase the character to the LEFT of the cursor"$'\n'"  $(kbd Delete) | Erase the character to the RIGHT of the cursor"
			;;
	esac
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #0: Shortcuts

	In this lesson you will learn how to

	* Utilize the shell's History feature to recycle previous commands
	* Employ Line Editor shortcuts to easily navigate and change command lines
	* Unleash the power of Tab completion

	This lesson takes around $_DURATION minutes.

	PROLOGUE
	_tutr_pressenter
}

_tutr_check_shortcuts() {
	if [[ $_SH = Zsh ]]; then
		if [[ ! -f "$HOME/.zshrc" ]]; then
			_tutr_install_shortcuts "$HOME/.zshrc"
		elif ! grep -q "# DO NOT MODIFY. SHORTCUTS COMMAND ADDED BY SHELL TUTOR" "$HOME/.zshrc"; then
			_tutr_install_shortcuts "$HOME/.zshrc"
		fi
	elif [[ $_SH = Bash ]]; then
		if [[ ! -f "$HOME/.bashrc" ]]; then
			_tutr_install_shortcuts "$HOME/.bashrc"
		elif ! grep -q "# DO NOT MODIFY. SHORTCUTS COMMAND ADDED BY SHELL TUTOR" "$HOME/.bashrc"; then
			_tutr_install_shortcuts "$HOME/.bashrc"
		fi
	else
		_tutr_die printf "'Unknown shell $SHELL: Unable to install the shortcuts command in this shell'"
	fi
}

_tutr_install_shortcuts() {
	if [[ -z $1 ]]; then
		_tutr_die "'Usage: $0 SHELL_RC_FILE_NAME'"
	fi

	cat <<-ASK | sed -e $'s/.*/\x1b[1;33mTutor\x1b[0m| &/'
	$(blu INSTALL A CHEATSHEET COMMAND)

	You learned many new keyboard shortcuts in this lesson.  To help you
	recall them later I can add a command called $(cmd shortcuts) to your shell.
	$(cmd shortcuts) will display the table of shortcuts shown in this lesson
	any time you need a quick refresher.

	To install this new command I must add a bit of code to your shell's
	startup script $(path $1).

	You can then run $(cmd shortcuts) after starting a new shell instance.
	ASK

	if _tutr_yesno "May I make this one-time change to $1?"; then
		_tutr_info echo "Installing the 'shortcuts' command into $1..."
		cat <<-SHIM >> "$1"

		shortcuts() { # DO NOT MODIFY. SHORTCUTS COMMAND ADDED BY SHELL TUTOR
			cat <<-:
			$(cyn Shortcut) | $(cyn Action)
			---------|----------------------------------------------
			  $(kbd Up)     | Bring up older commands from history
			  $(kbd Down)   | Bring up newer commands from history
			  $(kbd Left)   | Move cursor BACKWARD one character
			  $(kbd Right)  | Move cursor FORWARD one character
			$_BACKSPACE
			  $(kbd "^A")     | Move cursor to START of line
			  $(kbd "^E")     | Move cursor to END of line
			  $(kbd M-B)    | Move cursor BACKWARD one whole word
			  $(kbd M-F)    | Move cursor FORWARD one whole word
			  $(kbd "^C")     | Cancel (terminate) the currently running process
			  $(kbd Tab)    | Complete the command or filename at cursor
			  $(kbd "^W")     | Kill (cut) BACKWARD from cursor to beginning of word
			  $(kbd "^K")     | Kill FORWARD from cursor to end of line (kill)
			  $(kbd "^Y")     | Yank (paste) text to the RIGHT of the cursor
			  $(kbd "^L")     | Clear the screen while preserving command line
			  $(kbd "^U")     | Kill the entire command line
			:
		}
		SHIM

		if (( $? != 0 )); then
			cat <<-: | sed -e $'s/.*/\x1b[1;31mTutor\x1b[0m| &/'
			I was unable to modify '$1'.
			Please contact jaxton.winder@gmail.com for support.
			:
		else
			_tutr_info echo "Now you can launch a new shell window and try running \'shortcuts\'."
		fi
	else
		_tutr_err echo "Leaving your shell\'s startup file unchanged."
	fi

	return 0
}


# Mac keyboard setup instructions
mac_keyboard_prologue() {
	cat <<-:
	Correct me if I'm wrong, but it looks like you are on a Mac.
	You need to do an extra bit of setup before you can begin this tutorial.

	(If you have already done this once before, you can safely skip over
	this step).

	By default, the Mac OS Terminal App does not recognize your $(kbd Option) key.
	Do this to set it up:

	*   Open the $(cyn Terminal) menu and select $(cyn Settings...)
	*   Select the $(cyn Profiles) page
	*   Select the $(cyn Keyboard) tab
	*   Check the option labeled $(cyn Use Option as Meta Key)

	Once you have done this, run $(cmd true) to start the lesson.
	:
}

mac_keyboard_test() {
	_tutr_noop && return $NOOP
	_tutr_generic_test -c true
}

mac_keyboard_hint() {
	cat <<-:

	Use $(cmd tutor hint) to review the instructions about this setting.

	Run $(cmd true) to acknowledge that you are ready to start.
	:
}



ls_prologue() {
	cat <<-:
	In this directory are text files with long, silly names.
	Show them with $(cmd ls).
	:
}


ls_test() {
	_tutr_generic_test -c ls -x
}


ls_hint() {
	case $1 in
		$WRONG_CMD)
			echo Run $(cmd ls) to see what crazy names these files have
			;;
		$WRONG_PWD)
			_tutr_generic_hint $1 ls "$_BASE"
			;;
		*)
			_tutr_generic_hint $1 ls "$_BASE"

			cat <<-:

			Run $(cmd ls) to see what crazy names these files have
			:
			;;
	esac
}

ls_epilogue() {
	_tutr_pressenter
}



cat_star_prologue() {
	cat <<-:
	Together, these files form an ASCII art picture.

	You can use $(cmd 'cat *') to display them all at once.

	It isn't clear from their names if this is the right order to print
	them.  But it doesn't hurt to try!
	:
}

cat_star_test() {
	_tutr_noop && return $NOOP
	_tutr_generic_test -d "$_BASE" -c cat -a "\\*"
}

cat_star_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:

	Run $(cmd 'cat *') to display all of the files at once.
	:
}

cat_star_epilogue() {
	cat <<-:
	Well... that doesn't look right.

	By the end of this lesson you will find the right order to view them.

	:
	_tutr_pressenter
}



# echo disorganized.txt
echo_1_prologue() {
	cat <<-:
	The thought of typing all of their names over and over again until you
	see the picture sounds like a $(bld long), $(bld tedious), and $(bld boring) task.
	As it turns out, this actually is a $(blu long), $(blu tedious), and $(blu boring) task.

	I want to teach you some cool tricks to let you put a big command line
	together quickly with a minimum of typing.

	We begin by simply printing the name of one of the files with $(cmd echo).
	Run
	  $(cmd echo disorganized.txt)
	:
}

echo_1_test() {
	_tutr_noop && return $NOOP
	_tutr_generic_test -c echo -d "$_BASE" -a disorganized.txt
}

echo_1_hint() {
	_tutr_generic_hint $1 echo "$_BASE"

	cat <<-:

	Run
	  $(cmd echo disorganized.txt)
	:
}


# echo disorganized.txt combinatorially.txt
echo_2_ff() {
	_PREV="echo disorganized.txt combinatorially.txt"
}

echo_2_prologue() {
	cat <<-:
	Do that again, but with one more file name this time:
	  $(cmd echo disorganized.txt combinatorially.txt)
	:
}

echo_2_test() {
	_tutr_noop && return $NOOP
	_tutr_generic_test -c echo -d "$_BASE" -a disorganized.txt -a combinatorially.txt
}

echo_2_post() {
	_PREV=${_CMD[@]}
}

echo_2_hint() {
	_tutr_generic_hint $1 echo "$_BASE"
	cat <<-:

	Run
	  $(cmd echo disorganized.txt combinatorially.txt)
	:
}

echo_2_epilogue() {
	cat <<-:
	Phew!  That was a lot of typing!  And there are still $(bld six more files) to
	get through.  If this is what using the shell is like, you must be
	wondering why anybody puts up with it!

	Never fear, things are about to get $(bld much) easier.

	:
	_tutr_pressenter
}




history_echo_cat_ff() {
	_PREV="cat disorganized.txt combinatorially.txt"
}

history_echo_cat_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		:
	}
}

# Use Up + ^A to change 'echo' into 'cat'
history_echo_cat_prologue() {
	cat <<-:
	For this step I want you to re-run the previous command, but with one
	small difference: instead of $(cmd echo), you will use $(cmd cat).

	You do not need to re-type that whole command.  The shell remembers your
	old commands and can bring them back for you.

	The first shortcuts to learn are the $(kbd ARROW) keys (the same ones you use
	for games).

	$(cyn Shortcut) | $(cyn Action)
	---------|----------------------------------------------
	  $(kbd Up)     | Bring up older commands from history
	  $(kbd Down)   | Bring up newer commands from history
	  $(kbd Left)   | Move cursor BACKWARD one character
	  $(kbd Right)  | Move cursor FORWARD one character
	$_BACKSPACE

	You can see this table whenever you want by running a command called
	$(cmd shortcuts).  I'll update it with new shortcuts as the lesson goes on.

	Using these shortcuts, find your last command
	  $(cmd $_PREV)
	and change $(cmd echo) into $(cmd cat).
	:
}

history_echo_cat_post() {
	_PREV=${_CMD[@]}
}

history_echo_cat_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a disorganized.txt -a combinatorially.txt
}

history_echo_cat_statelog() {
	_TUTR_STATE_CODE=0
	_TUTR_STATE_TEXT=$(ls -a)
}

history_echo_cat_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:
	Using these shortcuts, find your previous command, namely
	  $(cmd $_PREV)
	and change the word $(cmd echo) into $(cmd cat).
	:
}

history_echo_cat_epilogue() {
	_tutr_pressenter

	cat <<-:

	It worked!

	What you are learning is how to control the shell's $(bld line editor).
	$(bld Line editor) is the name of that part of the shell that enables you to
	write and edit commands in the terminal.

	The part of the shell that responds to the keyboard is called the $(bld line)
	$(bld editor).  You probably haven't given it any thought since it doesn't have
	an appearance of its own.  You can think of the $(bld line editor) as the
	shell's equivalent to a web browser's address bar.

	If you tried to use the mouse to move your cursor to the beginning of
	the line, you will have found that didn't work.  The line editor relies
	$(bld entirely) on the keyboard to control the cursor.  This is due to the fact
	that mice weren't widespread when terminals were invented.

	This remains true today because there are better ways to move the
	cursor that don't require taking your hands away from the keyboard.

	:
	_tutr_pressenter
}



# Use ^A, M-B, M-F to insert reorganization.txt before disorganized.txt
ctrl_a_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
	$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		:
	}
}

ctrl_a_ff() {
	_PREV="cat reorganization.txt disorganized.txt combinatorially.txt"
}

ctrl_a_prologue() {
	if [[ $_OS = MacOSX ]]; then
		cat <<-:
		Using the arrow keys was a big improvement over retyping the whole
		command from the beginning.  But you can still do better than
		pressing $(kbd Left) dozens of times!

		You can use these line editor shortcuts instead:

		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		   $(kbd "^A")  * | Move cursor to START of line
		   $(kbd "^E")    | Move cursor to END of line
		   $(kbd M-B) **| Move cursor BACKWARD one whole word
		   $(kbd M-F)   | Move cursor FORWARD one whole word

		*  The caret $(kbd '^') stands for the $(kbd Control) key
		   $(kbd '^A') means "Press $(kbd Control + A)".
		   Some documentation abbreviates "$(kbd Control)" as $(kbd 'C-')

		** $(kbd M) represents the $(kbd Option) key
		   ($(kbd M) is an abbreviation for $(kbd Meta))
		   $(kbd M-B) means "Press $(kbd Option + B)"

		Use these shortcuts to move your cursor within the command line
		  $(cmd $_PREV)

		Insert the filename $(path reorganization.txt) in front of $(path disorganized.txt)
		:
	else
		cat <<-:
		Using the arrow keys was a big improvement over retyping the whole
		command from the beginning.  But you can still do better than
		pressing $(kbd Left) dozens of times!

		You can use these line editor shortcuts instead:

		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		   $(kbd "^A")  * | Move cursor to START of line
		   $(kbd "^E")    | Move cursor to END of line
		   $(kbd M-B) **| Move cursor BACKWARD one whole word
		   $(kbd M-F)   | Move cursor FORWARD one whole word

		*  The caret $(kbd '^') stands for the $(kbd Control) key
		   $(kbd '^A') means "Press $(kbd Control + A)".
		   Some documentation abbreviates "$(kbd Control)" as $(kbd 'C-')

		** $(kbd M) represents the $(kbd Alt) key
		   ($(kbd M) is an abbreviation for $(kbd Meta))
		   $(kbd M-B) means "Press $(kbd Alt + B)"

		Use these shortcuts to move your cursor within the command line
		  $(cmd $_PREV)

		Insert the filename $(path reorganization.txt) in front of $(path disorganized.txt)
		:
	fi
}

ctrl_a_post() {
	_PREV=${_CMD[@]}
}

ctrl_a_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a reorganization.txt -a disorganized.txt -a combinatorially.txt
}

ctrl_a_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:

	Insert the filename $(path reorganization.txt) in front of $(path disorganized.txt)
	in the command line
	  $(cmd $_PREV)
	:
}

ctrl_a_epilogue() {
	cat <<-:
	That picture is coming along nicely!

	:
	_tutr_pressenter

	cat <<-:

	The $(kbd "^") and $(kbd "M-") notation is a little funny, but you need to learn it
	because you'll encounter it in error messages, help files and other
	documentation.

	:

	if [[ $_OS = MacOSX ]]; then
		cat <<-:

		Why does the shell refer to your keyboard's $(bld Option) key as $(bld Meta)?

		Your keyboard follows the layout Apple established for their personal
		computers in 1983.  The mainframes on which the Unix shell was made
		predates Apple by over a decade, weren't built by Apple, and were not
		"personal" computers.  The keys surrounding their space bar were labeled
		$(kbd Meta) and served a similar purpose to Apple's $(kbd Option) key.

		Apple keyboards have both a $(kbd Control) key and a $(kbd Command) key,
		and your terminal distinguishes between them.  These shortcuts denoted
		by $(kbd '^') use $(kbd Control):

		$(cyn Shortcut) | $(cyn Shell Line Editor Action)
		---------|---------------------------------------------
		  $(kbd "^Z")     | Put a process to sleep
		  $(kbd "^X")     | Begin chorded command & wait for another key
		  $(kbd "^C")     | Cancel (Terminate) a running process
		  $(kbd "^V")     | Verbatim; next keystroke is taken literally

		:

		_tutr_pressenter

		cat <<-:

		Incidentally, the $(kbd Command) shortcuts you learned on the Desktop
		still work as you expect in the shell.  Specifically, these combos
		retain their familiar functions in the Terminal app:

		$(cyn Shortcut)   | $(cyn Action)
		-----------|-------
		  $(kbd CMD+Z)    | Undo
		  $(kbd CMD+X)    | Cut
		  $(kbd CMD+C)    | Copy
		  $(kbd CMD+V)    | Paste

		:
	else
		cat <<-:
		Why does the shell refer to your keyboard's $(bld Alt) key as $(bld Meta)?

		Your keyboard follows the layout IBM established for their Personal
		Computers in 1981.  The mainframes on which the Unix shell was made
		predates the IBM PC by over a decade, weren't created by IBM, and were not
		"personal" computers.  The keys surrounding their space bar were labeled
		$(kbd Meta) and served the same purpose as IBM's $(kbd Alt) key.

		Incidentally, the keyboard shortcuts you learned on the Desktop don't
		work as you would think in the shell.  Specifically, these keystrokes
		won't do what you expect:

		$(cyn Shortcut) | $(cyn IBM-PC Action) | $(cyn Shell Line Editor Action)
		---------|---------------|---------------------------------------------
		  $(kbd "^Z")     | Undo          | Put a process to sleep
		  $(kbd "^X")     | Cut           | Begin chorded command & wait for another key
		  $(kbd "^C")     | Copy          | Cancel (Terminate) a running process
		  $(kbd "^V")     | Paste         | Verbatim; next keystroke is taken literally

		:
	fi

	_tutr_pressenter
}


ctrl_c_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		  $(kbd "^C")     | Cancel (terminate) the currently running process
		:
	}
}


# 4. Cancel runaway processes with ^C
ctrl_c_prologue() {
	cat <<-:
	Why not practice $(kbd "^C") right now?

	Run the command $(cmd sleep 3600), which will pause the shell for an hour.
	Instead of waiting for the clock to run out, $(kbd "^C") stops it early.
	:
}

ctrl_c_test() {
	_SLEEP_TOO_SMALL=99
	_SLEEP_FOR_REALS=98
	_tutr_noop shortcuts && return $NOOP
	if [[ ${_CMD[0]} == 'sleep' ]]; then
		(( ${#_CMD[@]} < 2 )) && return $TOO_FEW_ARGS
		(( ${_CMD[1]} < 180 )) && return $_SLEEP_TOO_SMALL
		(( $_RES == 0 )) && return $_SLEEP_FOR_REALS
		return 0
	fi
	_tutr_generic_test -c sleep -a 3600
}


ctrl_c_hint() {
	case $1 in
		$_SLEEP_TOO_SMALL)
			cat <<-:
			C'mon, you can let it sleep longer than that.
			Go crazy and pick a $(bld really big) number!
			:
			;;
		$_SLEEP_FOR_REALS)
			cat <<-:
			Did you really wait around for ${_CMD[1]} seconds just to
			see what would happen?  You must be so disappointed right now.
			:
			;;
		*)
			_tutr_generic_hint $1 sleep "$_BASE"
			;;
	esac

	cat <<-:

	Run $(cmd sleep 3600) to pause the shell for an hour.
	Instead of waiting for the clock to run out, use $(kbd "^C") to stop it now.
	:
}

ctrl_c_epilogue() {
	cat <<-:
	Excellent!

	We've all written our share of infinite loops.  When one of your
	programs "gets away" from you, remember that $(kbd "^C") $(red cancels) it.

	:
	_tutr_pressenter
}



# Up + Tab to add 'sequentializing.txt', 'obfuscatory.txt' to the FRONT of the cmdline
tab_ff() {
	_PREV="cat sequentializing.txt obfuscatory.txt reorganization.txt disorganized.txt combinatorially.txt"
}

tab_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		  $(kbd "^C")     | Cancel (terminate) the currently running process
		  $(kbd Tab)    | Complete the command or filename at cursor
		:
	}
}

tab_prologue() {
	cat <<-:
	These shortcuts are great, but you're still doing $(bld way) too much typing.

	Your phone and web browser are able to figure out what you're trying to
	say and finish your words for you.  Your IDE has code completion.  These
	21st century innovations are great time-savers.  Oh, did I say 21st
	century?  I meant 20th century.  Command shells have been doing this
	since the early 90's.

	From now on, all you'll ever need to type are first few characters of a
	file's name followed by $(kbd Tab).  If the shell can find a file whose name
	begins with that sequence of characters, it will finish it for you.

	$(cyn Shortcut) | $(cyn Action)
	---------|----------------------------------------------
	  $(kbd Tab)    | Complete the command or filename at cursor

	:

	_tutr_pressenter

	cat <<-:

	Try it now.  Find your last $(cmd cat) command using the arrows:
	  $(cmd $_PREV)

	Position the cursor on the space between $(cmd cat) and $(path reorganization.txt).
	Type another space so the cursor doesn't touch $(cmd cat).  Now type $(kbd se) and hit
	$(kbd Tab); the shell automatically adds the rest of the letters to spell
	$(path sequentializing.txt).

	Next, add another space, then $(kbd o) and press $(kbd Tab).  Watch the shell write
	$(path obfuscatory.txt) for you!
	:
}

tab_post() {
	_PREV=${_CMD[@]}
}

tab_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a sequentializing.txt -a obfuscatory.txt -a reorganization.txt -a disorganized.txt -a combinatorially.txt
}

tab_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:
	The command you are trying to write looks like this:
	  $(cmd cat sequentializing.txt obfuscatory.txt reorganization.txt disorganized.txt combinatorially.txt)

	If Tab completion isn't working for you, add a few extra spaces between
	words such that your cursor doesn't touch another word that you do not
	intend to complete.
	:
}

tab_epilogue() {
	cat <<-:
	Eh, not bad.  Just needs a little work.

	:

	_tutr_pressenter

	cat <<-:

	One little problem with $(kbd Tab) completion occurs when multiple file names
	begin with the same characters.  Because the shell can't read your mind,
	it completes as much as it can based on what you typed, and then
	displays the remaining matches.  You must type a bit more to narrow its
	choices.  Eventually, you will arrive at a unique match.

	In some shells you must hit $(kbd Tab) twice to trigger this feature.

	If you hit $(kbd Tab) several times and $(bld still) don't get anywhere, it means
	that $(bld nothing) matches.  You may have a typo in your command.

	When that happens, delete the part of the word the cursor is on and hit
	$(kbd Tab) again to see what new choices the shell finds.

	:
	_tutr_pressenter
}



# M-B + M-F to move by words - ^W remove disorganized.txt, ^E goto end and ^Y to paste it there
cutpaste_words_ff() {
	_PREV="cat reorganization.txt disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt"
}

cutpaste_words_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		  $(kbd "^C")     | Cancel (terminate) the currently running process
		  $(kbd Tab)    | Complete the command or filename at cursor
		  $(kbd "^W")     | Kill (cut) BACKWARD from cursor to beginning of word
		  $(kbd "^K")     | Kill FORWARD from cursor to end of line (kill)
		  $(kbd "^Y")     | Yank (paste) text to the RIGHT of the cursor
		:
	}
}


cutpaste_words_prologue() {
	cat <<-:
	The picture is getting bigger.  It looks like the top part needs to go
	to the bottom.  What this calls for is some cut & paste.

	Instead of selecting text with the mouse and hitting $(kbd "^X") to cut it,
	the line editor $(red kills) text from the point of the cursor.  Different
	shortcuts $(red kill) varying amounts of text in either direction.

	Like a desktop word processor, the cut ($(red killed)) text is stored in
	the clipboard ($(blu yank buffer)) and can be pasted ($(blu yanked)) later.

	$(cyn Shortcut) | $(cyn Action)
	---------|----------------------------------------------
	  $(kbd "^W")     | Kill (cut) BACKWARD from cursor to beginning of word
	  $(kbd "^K")     | Kill FORWARD from cursor to end of line (kill)
	  $(kbd "^Y")     | Yank (paste) text to the RIGHT of the cursor

	(Reminder: run $(cmd shortcuts) to view the complete table at any time)

	Use these shortcuts to make the old command line
	  $(cmd $_PREV)

	look like this:
	  $(cmd cat reorganization.txt disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt)
	:
}

cutpaste_words_post() {
	_PREV=${_CMD[@]}
	_CMD=()
}

cutpaste_words_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a reorganization.txt -a disorganized.txt -a combinatorially.txt -a sequentializing.txt -a obfuscatory.txt
}

cutpaste_words_hint() {
	_tutr_generic_hint $1 cat "$_BASE"
	cat <<-:

	Use $(red kill) and $(blu yank) commands to make the old command line
	  $(cmd $_PREV)

	look like this:
	  $(cmd cat reorganization.txt disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt)
	:
}

cutpaste_words_epilogue() {
	_tutr_pressenter
}



clear_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		  $(kbd "^C")     | Cancel (terminate) the currently running process
		  $(kbd Tab)    | Complete the command or filename at cursor
		  $(kbd "^W")     | Kill (cut) BACKWARD from cursor to beginning of word
		  $(kbd "^K")     | Kill FORWARD from cursor to end of line (kill)
		  $(kbd "^Y")     | Yank (paste) text to the RIGHT of the cursor
		  $(kbd "^L")     | Clear the screen while preserving command line
		:
	}
}



# clear the screen and leave command prompt intact with ^L
clear_prologue() {
	cat <<-:
	You're almost there!

	You're putting a lot of text on the screen, and that can be over-
	whelming.  In a previous lesson you learned that the $(cmd clear) command
	cleans up the screen and puts the prompt back up at the top.

	The shortcut $(kbd "^L") does that $(bld and) leaves the command you're writing
	unchanged in the line editor.

	$(cyn Shortcut) | $(cyn Action)
	---------|-----------------------------------------------
	  $(kbd "^L")     | Clear the screen while preserving command line

	This way you can clear the screen without throwing away your command!

	Use the $(kbd Up arrow) to find your last command
	  $(cmd $_PREV)

	and use $(kbd "^L") to clean up the screen.  Re-run that command to proceed.
	:
}

clear_test() {
	[[ ${_CMD[0]} == clear ]] && return 99
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a reorganization.txt -a disorganized.txt -a combinatorially.txt -a sequentializing.txt -a obfuscatory.txt
}

clear_hint() {
	case $1 in
		99)
			echo "Use $(kbd "^L") - it's only 2 keystrokes instead of the 6 needed for $(cmd clear)"
			;;
		*)
			_tutr_generic_hint $1 cat "$_BASE"
			;;
	esac
	cat <<-:

	Use the $(kbd Up arrow) to find your last command line
	  $(cmd $_PREV)
	and use $(kbd "^L") to clean up the screen.  Then re-run that command to proceed.
	:
}

clear_epilogue() {
	_tutr_pressenter
}



#  ^U to cut the whole cmdline, run 'ls', ^Y to paste it back
#  cat painstakingly.txt nonsequential.txt fragmentary.txt reorganization.txt
#  disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt
cut_line_pre() {
	shortcuts() {
		cat <<-:
		$(cyn Shortcut) | $(cyn Action)
		---------|----------------------------------------------
		  $(kbd Up)     | Bring up older commands from history
		  $(kbd Down)   | Bring up newer commands from history
		  $(kbd Left)   | Move cursor BACKWARD one character
		  $(kbd Right)  | Move cursor FORWARD one character
		$_BACKSPACE
		  $(kbd "^A")     | Move cursor to START of line
		  $(kbd "^E")     | Move cursor to END of line
		  $(kbd M-B)    | Move cursor BACKWARD one whole word
		  $(kbd M-F)    | Move cursor FORWARD one whole word
		  $(kbd "^C")     | Cancel (terminate) the currently running process
		  $(kbd Tab)    | Complete the command or filename at cursor
		  $(kbd "^W")     | Kill (cut) BACKWARD from cursor to beginning of word
		  $(kbd "^K")     | Kill FORWARD from cursor to end of line (kill)
		  $(kbd "^Y")     | Yank (paste) text to the RIGHT of the cursor
		  $(kbd "^L")     | Clear the screen while preserving command line
		  $(kbd "^U")     | Kill the entire command line
		:
	}
}

cut_line_prologue() {
	cat <<-:
	Awesome!  There is one more trick I want you to learn.

	Sometimes, when you're in the midst of editing a command, you really
	must set it aside to do something else.  Perhaps you need to run $(cmd ls) to
	learn the name of a file.

	$(cyn Shortcut) | $(cyn Action)
	---------|----------------------------------------------
	  $(kbd "^U")     | Cut the entire command line

	:
	if [[ $_SH = Zsh ]]; then
		cat <<-:
		$(kbd "^U") kills the entire command line into the $(blu yank buffer) $(bld regardless) of
		where the cursor is.  You can then run as many commands as you want
		before restoring the original command from the $(blu yank buffer) with $(kbd "^Y").

		Why don't you try it out?

		Hit the $(kbd Up arrow) to bring back your big command, put the cursor
		somewhere in the middle, then use $(kbd "^U") to $(red kill) it into the $(blu yank buffer).
		:
	else
		cat <<-:
		$(kbd "^U") kills from the position of the cursor $(bld back) to the beginning of the
		command line, storing the killed text in the $(blu yank buffer).  You can then
		run as many commands as you want before restoring the original command
		from the $(blu yank buffer) with $(kbd "^Y").

		Why don't you try it out?

		Hit $(kbd Up arrow) and bring back your big command, and with the cursor
		at the $(bld end of the line), use $(kbd "^U") to $(red kill) it into the $(blu yank buffer).
		:
	fi

	echo
	echo "Then run $(cmd ls) to proceed"
}

cut_line_test() {
	_tutr_generic_test -c ls -d "$_BASE"
}

cut_line_hint() {
	_tutr_generic_hint $1 ls "$_BASE"
}



paste_line_prologue() {
	cat <<-:
	Now yank your big command back into the command line with $(kbd "^Y") and run it.
	:
}

paste_line_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -c cat -d "$_BASE" -a reorganization.txt -a disorganized.txt -a combinatorially.txt -a sequentializing.txt -a obfuscatory.txt
}

paste_line_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:

	Yank your big command back into the command line with $(kbd "^Y") and run it.

	Just in case you lost it, the command to run is
	  $(cmd cat reorganization.txt disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt)
	:
}

paste_line_epilogue() {
	_tutr_pressenter
}



finish_pre() {
	# Uncomment this if somebody, somehow nukes the files and needs to get them back
	# _create_files
	typeset -ix _FAIL=0
}

finish_prologue() {
	cat <<-:
	That's pretty slick!  Now you know how to use the shell's line editor
	like a pro.  This was a lot of new knowledge to throw on you all at
	once, but you handled it like a champ!

	The key to remembering these shortcuts is to use them often.  Pick one
	or two to practice and $(bld intentionally) use them frequently as you work.
	If you catch yourself doing something "the old way", start over and use
	the new shortcut.  After a day or two of this regimen, they will become
	ingrained in your $(cyn muscle memory).

	You'll know you've arrived when you catch yourself using $(kbd "^W") to erase
	words and $(kbd "^L") to clear the screen in other programs!

	:

	_tutr_pressenter

	cat <<-:

	You're almost done with the puzzle.  This is what the finished product
	looks like:

	:

	solution

	cat <<-:

	The lesson will end when you $(cmd cat) the files in the correct order.

	Take a look at the names of the other files in this directory and
	complete the picture.  With your new tricks, this won't be hard.

	* Run $(cmd shortcuts) to review the new shell tricks you learned today.
	* Run $(cmd solution) to see the whole picture.
	:
}

finish_test() {
	_tutr_noop shortcuts && return $NOOP
	_tutr_generic_test -d "$_BASE" -c cat -a painstakingly.txt -a nonsequential.txt -a fragmentary.txt -a reorganization.txt -a disorganized.txt -a combinatorially.txt -a sequentializing.txt -a obfuscatory.txt
	local _r=$?
	case $_r in
		$WRONG_ARGS|$TOO_FEW_ARGS|$TOO_MANY_ARGS) (( _FAIL++ )) ;;
	esac
	return $_r
}


finish_hint() {
	if   (( _FAIL > 8 )) && [[ $1 == $WRONG_ARGS || $1 == $TOO_FEW_ARGS || $1 == $TOO_MANY_ARGS ]]; then
		cat <<-:
		It looks like you're struggling.  Here's the command:
		  $(cmd cat painstakingly.txt nonsequential.txt fragmentary.txt reorganization.txt disorganized.txt combinatorially.txt sequentializing.txt obfuscatory.txt)

		:
	elif (( _FAIL > 4 )) && [[ $1 == $WRONG_ARGS || $1 == $TOO_FEW_ARGS || $1 == $TOO_MANY_ARGS ]]; then
		cat <<-:
		You're so close!

		:
		_tutr_generic_hint $1 cat "$_BASE"
	elif (( _FAIL > 2 )) && [[ $1 == $WRONG_ARGS || $1 == $TOO_FEW_ARGS || $1 == $TOO_MANY_ARGS ]]; then
		cat <<-:
		Keep trying!

		:
		_tutr_generic_hint $1 cat "$_BASE"
	else
		_tutr_generic_hint $1 cat "$_BASE"
	fi
}

finish_epilogue() {
	if (( _FAIL <= 8 )); then
		cat <<-:

		$(grn "That's it!  You did it!")

		:
	fi
	_tutr_pressenter
}



epilogue() {
	cat <<-EPILOGUE
	In this lesson you learned how to save keystrokes with

	* The shell's command history
	* Line editor shortcuts
	* Tab completion

	EPILOGUE

	_tutr_pressenter
}



cleanup() {
	(( $1 == $_COMPLETE)) && _tutr_check_shortcuts
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}



_STEPS=(
	ls
	cat_star
	echo_1
	echo_2
	history_echo_cat
	ctrl_a
	ctrl_c
	tab
	cutpaste_words
	clear
	cut_line
	paste_line
	finish
	)

if [[ $_OS = MacOSX ]]; then
	_STEPS=(mac_keyboard ${_STEPS[@]})
fi

source main.sh && _tutr_begin ${_STEPS[@]}

# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
