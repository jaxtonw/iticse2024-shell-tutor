#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=20

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

source ansi-terminal-ctl.sh
source progress.sh
if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source noop.sh
	source open.sh
	source platform.sh
fi


ask_to_open_explorer_msg() {
	cat <<-:
	In this lesson you will create, rename and delete files in the shell.
	You can watch what happens to them in a graphical file explorer window.
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

create_copy0_txt() {
	cat <<-TEXT > "$_BASE/copy0.txt"
	Use the copy command 'cp' to make two copies of this file.
	When you're done you will have three files:
	* copy0.txt
	* copy1.txt
	* copy2.txt
	TEXT
}

create_move0_txt() {
	cat <<-TEXT > "$_BASE/move0.txt"
	Use the move command 'mv' to rename this file.
	When you're done you will only have this one file, but it won't be
	named move0.txt anymore.
	TEXT
}

create_different_txt() {
	cat <<-TEXT > "$_BASE/different.txt"
	This file is not like the others!
	TEXT
}

# Find the command with the longest name on this system
# Set $REPLY to this command's name
find_longest_command() {
	if [[ -n $ZSH_NAME ]]; then
		setopt local_options nullglob
	fi
	local LONGEST=
	for CMD in /bin/* /usr/bin/* /usr/local/bin/*; do
		if [[ -x $CMD ]]; then
			CMD=${CMD##*/}
			if [[ ${#CMD} -gt ${#LONGEST} ]]; then
				LONGEST=$CMD
			fi
		fi
	done
	REPLY=$LONGEST
}

setup() {
	source screen-size.sh 80 30
	export _BASE="$PWD/lesson2"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"

	create_copy0_txt
	create_move0_txt
	create_different_txt
	find_longest_command
	export _LONGEST=$REPLY
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #2: Manipulating Files

	In this lesson you will learn how to

	* Make copies of files
	* Move and rename files
	* Take advantage of tab completion
	* Remove files
	* Refer to multiple files with wild cards

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}


# Case- and whitespace-insensitively compare a one line file with a specimen string
# Return 0 if the file contains only the specimen
# Return 1 otherwise
compare() {
	if (( $# < 2 )); then
		cat <<-:
		Usage:
		compare filename "string"
		:
		return 1
	fi

	eval 'tr A-Z a-z < $1 | tr -s "[[:blank:]]" | cmp - <(echo $2) >/dev/null 2>/dev/null'
}



copy01_rw() {
	command rm -f "$_BASE/copy1.txt"
}

copy01_ff() {
	create_copy0_txt
	command cp -f "$_BASE/copy0.txt" "$_BASE/copy1.txt"
}


copy01_pre() {
	ask_to_open_explorer
}

copy01_prologue() {
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

		If you accidentally close the file explorer window and want
		it back, just run $(cmd $_OPEN .) ($(bld "note the dot at the end!")).

		Of course, you can also see the files in the shell with $(cmd ls).

		:
	else
		cat <<-:
		As usual, you will be able to see the files by running $(cmd ls).

		If you change your mind later, this command brings up the file explorer:
		  $(cmd $_OPEN .)
		($(bld "note the dot at the end!"))

		:
	fi
	_tutr_pressenter

	cat <<-:

	Do you remember when I told you that shell commands are short and easy
	to type?  I hope that you aren't too attached to vowels...

	The Unix command that copies files is named $(cmd cp).  It copies a file named
	$(path SOURCE) to $(path DESTINATION):

	  $(cmd "cp SOURCE DESTINATION")

	Example: copy $(path hello.txt) into a new file named $(path world.doc)
	  $(cmd cp hello.txt world.doc)

	:
	_tutr_pressenter

	cat <<-:

	Use $(cmd cp) to copy $(path copy0.txt) to $(path copy1.txt)
	:
}

copy01_test() {
	if   _tutr_noop ls; then return $NOOP
	elif [[ -f $_BASE/copy0.txt && -f $_BASE/copy1.txt ]]; then return 0
	elif [[ ! -f $_BASE/copy0.txt ]]; then return 99
	else _tutr_generic_test -c cp -a copy0.txt -a copy1.txt -d "$_BASE"
	fi
}

copy01_hint() {
	case $1 in
		99)
			create_copy0_txt

			cat <<-:
			What happened to $(path copy0.txt)?
			No worries, I've replaced it for you.  Please try again.
			:
			;;
		*)
			_tutr_generic_hint $1 cp "$_BASE"
			;;
	esac

	cat <<-:

	Use $(cmd cp) to make a copy of $(path copy0.txt) called $(path copy1.txt).
	Your command should look like this:
	  $(cmd cp copy0.txt copy1.txt)
	:
}



copy02_rw() {
	command rm -f "$_BASE/copy2.txt"
}

copy02_ff() {
	create_copy0_txt
	command cp -f "$_BASE/copy0.txt" "$_BASE/copy2.txt"
}

copy02_prologue() {
	cat <<-:
	Now make another copy of $(path copy0.txt) called $(path copy2.txt).
	:
}

copy02_test() {
	if   _tutr_noop; then return $NOOP
	elif [[ -f $_BASE/copy0.txt && -f $_BASE/copy2.txt ]]; then return 0
	elif [[ ! -f $_BASE/copy0.txt ]]; then return 99
	else _tutr_generic_test -c cp -a copy0.txt -a copy2.txt -d "$_BASE"
	fi
}

copy02_hint() {
	case $1 in
		99)
			create_copy0_txt

			cat <<-:
			What happened to $(path copy0.txt)?
			Never mind, I've already replaced it for you.  Please try again.
			:
			;;
		*)
			_tutr_generic_hint $1 cp "$_BASE"
			;;
	esac

	cat <<-:

	Use $(cmd cp) to make a copy of $(path copy0.txt) called $(path copy2.txt).
	Your command should look like this:
	  $(cmd cp copy0.txt copy2.txt)
	:
}


list1_prologue() {
	if [[ -n "$_EXPLORER" ]]; then
		cat <<-:
		Compare what you see in the file explorer with what $(cmd ls) says.
		:
	else
		cat <<-:
		Look at your copies with $(cmd ls).
		:
	fi
}

list1_test() {
	_tutr_generic_test -c ls -d "$_BASE"
}

list1_hint() {
	_tutr_generic_hint $1 ls "$_BASE"
}

list1_epilogue() {
	_tutr_pressenter
	cat <<-:

	It is good to run $(cmd ls) frequently to make sure that your files are just
	as you expect.  Caution pays off because the shell has no $(bld undo) button.

	:
	_tutr_pressenter
}


cp_clobber_ff() {
	_PREV="cp copy0.txt different.txt"
}

cp_clobber_pre() {
	[[ ! -f $_BASE/copy0.txt ]] && create_copy0_txt
}

cp_clobber_prologue() {
	cat <<-:
	To recap, you have made two copies of $(path copy0.txt):
	  * $(path copy1.txt)
	  * $(path copy2.txt)
	All three files are identical.

	The new files did not already exist when you ran $(cmd cp).  If they had been
	present, they would have been $(bld overwritten), destroying their contents.

	Depending on how the shell is set up on your computer, $(cmd cp) $(bld may) prompt you
	for confirmation before overwriting a file as a precaution.  Or, $(cmd cp)
	might $(bld silently overwrite) the destination file.

	You should know how $(cmd cp) behaves on your computer.

	Copy $(path copy0.txt) onto $(path different.txt) to find out if $(cmd cp) stops and asks
	you to proceed.

	If $(cmd cp) does ask for permission, just hit $(kbd ENTER).
	:
}

cp_clobber_test() {
	_tutr_generic_test -i -c cp -a copy0.txt -a different.txt -d "$_BASE"
}

cp_clobber_hint() {
	_tutr_generic_hint $1 cp "$_BASE"

	cat <<-:
	Copy $(path copy0.txt) onto $(path different.txt) to see whether $(cmd cp) stops and asks
	you to proceed.

	The command you need to run is
	  $(cmd cp copy0.txt different.txt)

	If $(cmd cp) asks for permission, just hit $(kbd ENTER).
	:
}

cp_clobber_epilogue() {
	_tutr_pressenter

	cat <<-:

	That was enlightening!

	If $(cmd cp) asks for confirmation, you may respond in the affirmative with
	any string that begins with "$(bld Y)" or "$(bld y)".  Each of these strings are
	understood as affirmative responses:

	  * "$(bld YES)"
	  * "$(bld yup)"
	  * "$(bld yippee)"
	  * "$(bld "Yancy yearns for yesterday's yarrow yogurt")"

	For the sake of brevity, you can just enter "$(kbd y)".

	Any other string (including $(kbd ENTER) by itself) is a negative response.

	Once a file is overwritten there is no $(bld easy) way to get it back.
	Soon you will learn a program that can do this, but $(ylw caution) is always
	the best policy.

	:
	_tutr_pressenter
}

cp_clobber_post() {
	_PREV=${_CMD[@]}
}



tabcmplt_ls_d_prologue() {
	cat <<-:
	After running all of those commands, I'll bet that you feel like you are
	doing WAY too much typing.  The last command you ran,
	  $(cmd $_PREV)
	was $(bld ${#_PREV}) characters long.  That's too much work for a lazy Unix hacker!

	Your phone and web browser are able to figure out what you want to say
	and finish your thoughts for you.  Your word processor can do this, too.
	Even your programming environment has code completion.  This 21st
	century innovation is a great time-saver!

	Did I say 21st century?  I meant 20th century.
	Command shells have been autocompleting since the early 90's.

	:
	_tutr_pressenter

	cat <<-:

	From now on, all you'll ever need to type are first few characters of a
	file's name, followed by $(kbd '<TAB>').  If $_SH finds a file with a name
	that begins with those characters, it will finish it for you.

	Try it now with the $(cmd ls) command.  I want you to list $(bld only) the file
	$(path different.txt).

	The command to run, $(cmd ls different.txt), is 16 characters long.

	Instead of spelling it all out, I want you to type this:
	  $(cmd ls d)$(kbd '<TAB>')
	${_SH} will auto-magically fill in the rest (obviously, you will press
	the $(kbd Tab key) instead of typing out $(kbd '<TAB>')).

	Then, run that command to go to the next step.
	:
}

tabcmplt_ls_d_test() {
	_tutr_generic_test -c ls -a different.txt -d "$_BASE"
}

tabcmplt_ls_d_hint() {
	_tutr_generic_hint $1 ls "$_BASE"

	cat <<-:

	Type $(cmd ls d)$(kbd '<TAB>') so you can more easily run $(cmd ls different.txt)
	:
}

tabcmplt_ls_d_epilogue() {
	cat <<-:
	Just like magic, right?

	:
	_tutr_pressenter
}



tabcmplt_ls_c_prologue() {
	local _COPIES=(copy*)

	cat <<-:
	That last example worked so well because there is only one file whose
	name starts with '$(bld d)'.  What happens when there are other possibilities?
	It all depends on which shell you are running and how it is configured.

	There are ${#_COPIES[@]} files with names that start with the word '$(bld copy)'.
	Let's consider what happens when you type
	  $(cmd ls c)$(kbd '<TAB>')

	:

	_tutr_pressenter

	if [[ -n $ZSH_NAME ]]; then
		cat <<-:

		You are using Zsh, which has lots of options for configuring how Tab
		completion works.  Actually, Zsh just has a lot of options in general,
		but that's a rabbit hole you can explore on your own time.

		Unless you have already customized your Zsh, I can make a decent guess
		about what you will see when you try this.

		:

		_tutr_pressenter

		cat <<-:

		All ${#_COPIES[@]} of the "$(bld copy)" files' names share the first 4 letters.

		When you type $(kbd "c<TAB>"), Zsh fills in as much as is common among those
		files, so '$(bld c)' becomes '$(bld copy)'.  Press $(kbd '<TAB>') again, and the remaining
		possibilities are displayed below your command line.

		Continue to press $(kbd '<TAB>'), and the command line will change to include
		each filename in turn, from $(path copy0.txt) to $(path copy1.txt), etc.

		Once the command line looks good, you can either press $(kbd '<ENTER>') to run it,
		or continue typing more arguments.  At each point you can always hit
		$(kbd '<TAB>') and Zsh will provide more completions.

		If you type something that matches no files, Zsh will just ignore
		$(kbd '<TAB>')s, no matter how hard and furiously you press it.

		:

		_tutr_pressenter

		cat <<-:

		At least, I'm pretty sure that is what will happen for you.  Because Zsh
		is so customizable, it's possible that you'll experience different
		behavior.  There's only one way to find out!

		:
	else
		cat <<-:

		You are using Bash, where tab completion works like this:

		All ${#_COPIES[@]} of the "$(bld copy)" files' names share the first 4 letters.

		When you type $(kbd "c<TAB>"), Bash fills in as much as is common among those
		files, so '$(bld c)' becomes '$(bld copy)'.  The names of the three files which start
		with '$(bld copy)' are displayed, and a new command line is printed below this.

		:

		_tutr_pressenter

		cat <<-:

		As you continue to press $(kbd '<TAB>'), the same choices, along with a new
		prompt, are re-printed.  Type some more text to narrow down the choices,
		and press $(kbd '<TAB>') again to finish the filename.

		You can either press $(kbd '<ENTER>') to run the command, or continue adding more
		arguments.  At any point you can hit $(kbd '<TAB>') to make Bash fill in more
		filenames.

		:
	fi

	_tutr_pressenter

	cat <<-:

	Try it now!  Use tab completion to help you write the command
	  $(cmd ls copy0.txt copy1.txt copy2.txt)

	Be lazy and let ${_SH} do most of the typing!
	:
}

tabcmplt_ls_c_test() {
	_tutr_generic_test -c ls -a copy0.txt -a copy1.txt -a copy2.txt -d "$_BASE"
}

tabcmplt_ls_c_hint() {
	_tutr_generic_hint $1 ls "$_BASE"
	cat <<-:

	Use ${_SH}'s tab completion to help you type out the command
	  $(cmd ls copy0.txt copy1.txt copy2.txt)
	:
}

tabcmplt_ls_c_epilogue() {
	_tutr_pressenter
	cat <<-:

	Isn't that much better?

	:
	_tutr_pressenter
}



tabcmplt_ls_again_prologue() {
	cat <<-:
	Let's do that again, but with a twist.

	This time, use $(cmd ls) to list the files in this order:
	  * $(path copy2.txt)
	  * $(path move0.txt)
	  * $(path copy1.txt)
	  * $(path different.txt)
	  * $(path copy0.txt)

	This is a command with $(bld 5) arguments.  Use $(kbd '<TAB>') to minimize keystrokes.
	:
}

tabcmplt_ls_again_test() {
	_tutr_generic_test -c ls -a copy2.txt -a move0.txt -a copy1.txt -a different.txt -a copy0.txt
}

tabcmplt_ls_again_hint() {
	_tutr_generic_hint $1 ls "$_BASE"
	cat <<-:

	Use ${_SH}'s tab completion to help you type out the command
	  $(cmd ls copy2.txt move0.txt copy1.txt different.txt copy0.txt)

	The command must have these arguments in this order
	:
}

tabcmplt_ls_again_epilogue() {
	_tutr_pressenter
	cat <<-:

	Are you getting the hang of it yet?

	:
	_tutr_pressenter
}




tabcmplt_cp_c_rw() {
	command rm -f "$_BASE"/new.txt
}

tabcmplt_cp_c_ff() {
	create_copy0_txt
	command cp -f "$_BASE"/copy0.txt "$_BASE"/new.txt
}

tabcmplt_cp_c_prologue() {
	cat <<-:
	What if you ask ${_SH} to complete a filename that doesn't exist?

	This time I want you to run
	  $(cmd cp copy0.txt new.txt)

	First, enter $(cmd cp c)$(kbd '<TAB>').  Tab completion saves you typing by completing
	this to $(cmd cp copy), and a few more keystrokes can get you to
	  $(cmd cp copy0.txt)

	:

	_tutr_pressenter

	if [[ -n $ZSH_NAME ]]; then
		cat <<-:

		From $(cmd cp copy), you need to type another character to narrow down the
		remaining possibilities:

		* If you press $(kbd '<TAB>'), then Zsh cycles through the filenames it sees.
		* If you type '$(bld 0)' followed by $(kbd '<TAB>'), then Zsh can finish $(path copy0.txt).
		* If you type a '$(bld 1)' at that juncture, Zsh will complete that to
		  $(path copy1.txt).
		* If you type something that doesn't match any files, then Zsh does
		  nothing.

		:

	else
		cat <<-:

		From $(cmd cp copy), you need to type another character to narrow down the
		remaining possibilities:

		* If you type '$(bld 0)' followed by $(kbd '<TAB>'), then Bash can finish $(path copy0.txt).
		* If you type a '$(bld 1)' at that juncture, Bash will complete that to
		  $(path copy1.txt).
		* If you type something that doesn't match any files, Bash rings the
		  terminal's bell to get your attention.

		Sometimes the bell is an audible beep, or your screen may flash.
		Or nothing will happen.  It depends on your Terminal.

		:

	fi

	_tutr_pressenter

	cat <<-:

	But ${_SH} can't read your mind; it can only look at the files that are
	here.  It is not able to take you from
	  $(cmd cp copy0.txt n)$(kbd '<TAB>')
	to
	  $(cmd cp copy0.txt new.txt)

	You'll just have to write that part yourself.
	:
}

tabcmplt_cp_c_test() {
	_tutr_generic_test -c cp -a copy0.txt -a new.txt -d "$_BASE"
}

tabcmplt_cp_c_hint() {
	_tutr_generic_hint $1 cp "$_BASE"

	cat <<-:

	Run $(cmd cp copy0.txt new.txt) to proceed.
	:
}

tabcmplt_cp_c_epilogue() {
	cat <<-:
	Nicely done!

	:
	_tutr_pressenter
}



tabcmplt_cmd_prologue() {
	cat <<-:
	I have one more tab completion trick to share with you.  Did you know
	that ${_SH} can complete the names of commands?

	Now, I know what you're thinking - "just how lazy are these programmers
	who can't be bothered to type out $(cmd ls) or $(cmd cp) by themselves?  Moreover,
	isn't $(cmd l)$(kbd '<TAB>') just as many keystrokes as $(cmd ls)?"

	You aren't wrong.  But consider that
	  "$(cmd ${_LONGEST})"
	is the longest command on your system.  If you needed to run this
	program, would you want to type its name out, in full, every time?
	Would you even remember how to spell it?

	You can probably remember that it starts with "$(cmd ${_LONGEST:0:7})", which
	is enough for ${_SH} to help you narrow it down.

	:

	_tutr_pressenter

	cat <<-:

	Now, the completion output of $(cmd l)$(kbd '<TAB>') is going to be overwhelming:
	Your computer probably has hundreds of programs with names starting with
	that letter.  When ${_SH} detects that there are more than 100 or so
	possibilities, it will give you a prompt that looks like this:
	:
	if [[ -n $ZSH_NAME ]]; then
		cat <<-:
		  $(bld "zsh: do you wish to see all ### possibilities (## lines)?")

		You may need to press $(kbd '<ENTER>') or $(kbd Down Arrow) to view them.
		Again, because of customizations, your mileage may vary.
		You could very well see something different, or no prompt at all.
		:
	else
		echo "  $(bld "Display all ### possibilities? (y or n)")"
	fi

	echo
	_tutr_pressenter

	cat <<-:

	For this challenge, I want you to find the command whose name starts
	with '$(bld w)' and that prints out $(bld your username).  Use Tab completion to
	narrow down the field until you find the right one.
	:
}


tabcmplt_cmd_test() {
	_WRONG_LETTER=99
	_COLD=98
	_GETTING_WARMER=97
	_GOOGLE=96
	_UM_NO=95
	_SO_CLOSE=94

	[[ ${_CMD[@]} == whoami ]] && return 0
	[[ $_OS == Windows && ${_CMD[@]} == whoami.exe ]] && return 0
	[[ ${_CMD[@]} == "who am i" ]] && return $_SO_CLOSE
	[[ ${_CMD[@]} == whois ]] && return $_UM_NO
	[[ ${_CMD[0]} == who* ]] && return $_GETTING_WARMER
	[[ ${_CMD[@]} == "id -un" ]] && return $_GOOGLE
	[[ ${_CMD[@]} == 'echo $USER' ]] && return $_GOOGLE
	[[ ${_CMD[0]} == id ]] && return $_GOOGLE
	[[ ${_CMD[0]} = w* ]] && return $_COLD
	[[ ${_CMD[0]} != w* ]] && return $_WRONG_LETTER
	return $_UM_NO
}

tabcmplt_cmd_hint() {
	case $1 in
		$NOOP) ;;

		$_COLD)
			cat <<-:
			I'll give you a hint: the name of the command I'm thinking of
			has six letters.
			:
			;;

		$_SO_CLOSE)
			cat <<-:
			You are soooo close.
			:
			;;

		$_WRONG_LETTER)
			cat <<-:
			You're not even in the right ballpark!

			The command you are looking for starts with a '$(bld w)'
			:
			;;

		$_GETTING_WARMER)
			cat <<-:
			You're on the right track!  Keep going!
			:
			;;

		$_GOOGLE)
			cat <<-:
			Are you trying to solve this with Google, or something?
			:
			;;

		*)
			cat <<-:
			${_Y}  , ; ,   .-'"""'-.   , ; ,
			${_Y}  \\\\|/  .'         '.  \\|//
			${_Y}   \\-;-/   ()   ()   \\-;-/    ${_R}LOL WUT?
			${_Y}   // ;               ; \\\\
			${_Y}  //__; :.         .; ;__\\\\
			${_Y} \`-----\\'.'-.....-'.'/-----'
			${_Y}        '.'.-.-,_.'.'
			${_K}jgs${_Y}       '(  (..-'
			${_Y}            '-'${_Z}
			:
			;;

	esac
}

tabcmplt_cmd_epilogue() {
	cat <<-:
	${_G} _____                     _   _ _   _
	${_G}|  ___|__  _   _ _ __   __| | (_) |_| |
	${_G}| |_ / _ \\| | | | '_ \\ / _\` | | | __| |
	${_G}|  _| (_) | |_| | | | | (_| | | | |_|_|
	${_G}|_|  \\___/ \\__,_|_| |_|\\__,_| |_|\\__(_)${_Z}

	:

	_tutr_pressenter

	cat <<-:

	If nothing else, I hope that you are beginning to realize that ${_SH}
	isn't so hard to use after all.  And ${_SH} has many more time-saving
	shortcuts hidden beneath the surface!  There are so many that even $(bld I)
	don't know them all!

	Given enough time and practice, tab completion will become an automatic
	reflex.  You will find yourself hitting $(kbd '<TAB>') in other programs.

	Keep practicing tab completion through the rest of these lessons, and
	you'll be a command-line wizard in no time!

	Now, let's get back to manipulating files.

	:
	_tutr_pressenter
}



move01_rw() {
	create_move0_txt
	command rm -f "$_BASE/move1.txt"
}

move01_ff() {
	command mv -f "$_BASE/move0.txt" "$_BASE/move1.txt"
}

move01_prologue() {
	cat <<-:
	The Unix command to move files is named $(cmd mv).
	Its syntax is just like $(cmd cp):

	  $(cmd mv SOURCE DESTINATION)

	Example: move a file $(path hello.txt) to $(path world.doc)
	  $(cmd mv hello.txt world.doc)

	After running $(cmd mv) the $(path SOURCE) file no longer exists.  Be careful!!

	Use $(cmd mv) to move the file $(path move0.txt) to $(path move1.txt).
	You'll notice that pressing $(kbd '<TAB>') will complete the filename $(path move0.txt),
	but not $(path move1.txt).
	:
}

move01_test() {
	_MOVE0_LOST=99
	_DUP_ARGS=98
	[[ ! -f $_BASE/move0.txt && -f $_BASE/move1.txt ]] && return 0
	[[ ! -f $_BASE/move0.txt ]] && return $_MOVE0_LOST
	[[ ${_CMD[0]} == mv && ${_CMD[1]} == move0.txt && ${_CMD[2]} == move0.txt ]] && return $_DUP_ARGS
	_tutr_generic_test -c mv -a move0.txt -a move1.txt -d "$_BASE"
}

move01_hint() {
	case $1 in
		$_MOVE0_LOST)
			create_move0_txt

			cat <<-:
			What happened to $(path move0.txt)?
			No matter, I've replaced it for you.  Please try again.
			:
			;;

		$_DUP_ARGS)
			cat <<-:
			Look closely at the command you typed.  Does that even make sense?

			Did tab completion lead you astray?  You'll just have to type the second
			filename all by yourself.
			:
			;;
		*)
			_tutr_generic_hint $1 mv "$_BASE"
			;;
	esac

	cat <<-:

	Use $(cmd mv) to move the file $(path move0.txt) to $(path move1.txt).
	Your command should look like this:

	  $(cmd mv move0.txt move1.txt)
	:
}


move02_err_prologue() {
	cat <<-:
	Now use the move command to move $(path move0.txt) to $(path move2.txt).
	:
}

move02_err_test() {
	_MOVED_MOVE1=99
	_DUP_ARGS=98

	if [[ -f "$_BASE/move2.txt" && ! -f "$_BASE/move1.txt" ]]; then
		mv "$_BASE/move2.txt" "$_BASE/move1.txt"
		return $_MOVED_MOVE1
	elif [[ ${_CMD[0]} == mv && ${_CMD[1]} == move1.txt && ${_CMD[2]} == move1.txt ]]; then return $_DUP_ARGS
	else _tutr_generic_test -f -c mv -a move0.txt -a move2.txt -d "$_BASE"
	fi
}

move02_err_hint() {
	case $1 in
		$_MOVED_MOVE1)
			cat <<-MSG
			You ran the wrong command.  You moved $(path move1.txt) to $(path move2.txt), which
			is not the command I asked you to run.

			Did tab completion lead you astray?  On this step you'll have to type
			these filenames all by yourself.

			I'm going to put things back by moving $(path move2.txt) to $(path move1.txt) so you
			can try again.
			MSG
			;;
		$_DUP_ARGS)
			cat <<-:
			Look closely at the command you typed.  Does that even make sense?

			Did tab completion lead you astray?  You'll just have to type both
			arguments all by yourself.
			:
			;;
		*)
			_tutr_generic_hint $1 mv "$_BASE"
			;;
	esac

	cat <<-:

	Use $(cmd mv) to move the file $(path move0.txt) to $(path move2.txt).
	Your command should look like this:
	  $(cmd mv move0.txt move2.txt)
	:
}

move02_err_epilogue() {
	_tutr_pressenter

	cat <<-:

	What happened here?

	You previously moved $(path move0.txt) to the name $(path move1.txt), so $(path move0.txt)
	was not available to be moved to $(path move2.txt).

	Another way to think of this is to consider moving a file to be
	equivalent to $(bld COPYING) a file and then $(bld REMOVING) the original.

	Essentially, moving a file gives it a $(bld new name).  For this reason, Unix
	does not have a dedicated $(bld rename) command.  Renaming a file is the same
	thing as $(bld moving it to a new name).

	:
	_tutr_pressenter
}


move12_rw() {
	command rm -f "$_BASE/move1.txt" "$_BASE/move2.txt"
	create_move0_txt
	command mv -f "$_BASE/move0.txt" "$_BASE/move1.txt"
}

move12_ff() {
	create_move0_txt
	command cp -f "$_BASE/move0.txt" "$_BASE/move1.txt"
	command mv "$_BASE/move0.txt" "$_BASE/move2.txt"
}

move12_prologue() {
	cat <<-:
	Let's try that again, but with a file that exists.

	Use the $(cmd mv) command to rename $(path move1.txt) to $(path move2.txt).
	:
}

move12_test() {
	[[ ! -f $_BASE/move1.txt && -f $_BASE/move2.txt ]] && return 0
	[[ ! -f $_BASE/move1.txt ]] && return 99
	_tutr_noop && return $NOOP
	_tutr_generic_test -c mv -a move1.txt -a move2.txt -d "$_BASE"
}

move12_hint() {
	case $1 in
		99)
			create_move0_txt
			mv $_BASE/move0.txt $_BASE/move1.txt

			cat <<-:
			What happened to $(path move1.txt)?
			It doesn't matter, I've replaced it for you.  Try again.
			:
			;;

		*)
			_tutr_generic_hint $1 mv "$_BASE"
			;;
	esac

	cat <<-:

	Try running
	  $(cmd mv move1.txt move2.txt)
	:
}



mv_clobber_pre() {
	[[ ! -f $_BASE/different.txt ]] && create_different_txt
	if [[ ! -f $_BASE/move2.txt ]]; then
		create_move0_txt
		mv $_BASE/move0.txt $_BASE/move2.txt
	fi
}

mv_clobber_prologue() {
	cat <<-:
	By now you will have noticed that these commands don't output messages
	when they succeed.  As we say in Unix, "$(cyn 'no news is good news!')"

	But when a command does have something to say, $(bld 'you should pay attention!')

	$(cmd mv) carries a risk of overwriting the destination file.  Just like $(cmd cp), $(cmd mv)
	$(bld may) ask for confirmation before it does anything destructive.

	Find out what happens in ${_SH} when you move the file $(path move2.txt)
	onto $(path different.txt).  If prompted, answer $(kbd yes).
	:
}

mv_clobber_test() {
	_tutr_noop && return $NOOP
	[[ ! -f $_BASE/move2.txt && ! -f $_BASE/different.txt ]] && return 99
	_tutr_generic_test -c mv -a move2.txt -a different.txt -d "$_BASE"
}

mv_clobber_hint() {
	case $1 in
		99)
			mv_clobber_pre
			cat <<-:
			Huh, what happened to those files?
			Oh well, I've replaced them.  Do try again.
			:
			;;
		*)
			_tutr_generic_hint $1 mv "$_BASE"
			mv_clobber_pre
			;;
	esac

	cat <<-:

	Find out what happens on your computer when you overwrite the file
	$(path different.txt) with $(path move2.txt):

	  $(cmd mv move2.txt different.txt)

	If prompted, answer $(kbd yes)
	:
}

mv_clobber_epilogue() {
	_tutr_pressenter
	cat <<-:

	The fact that these commands can clobber other files so easily should
	scare you just a little bit.

	I hope that you get into the habit of considering your commands before
	hitting $(kbd '<ENTER>'), and carefully reading all prompts before pressing $(kbd y).

	:
	_tutr_pressenter
}


rm_1file_rw() {
	create_copy0_txt
}

rm_1file_ff() {
	command rm -f "$_BASE/copy0.txt"
}

rm_1file_pre() {
	create_copy0_txt
}

rm_1file_prologue() {
	cat <<-:
	The Unix command to delete/remove files is called $(cmd rm).
	This is its syntax:
	  $(cmd rm '[-f] FILENAME...')

	Example: remove the files $(path hello.txt) and $(path world.doc)
	  $(cmd rm hello.txt world.doc)

	$(cmd rm) expects at least one filename, but will accept many.  $(cmd rm) also accepts
	the $(cmd -f) option, which will be explained shortly.

	Files that are removed by $(cmd rm) are $(bld PERMANENTLY) deleted.  There is no
	recycle bin or "undelete" on Unix; this command is $(bld serious business).
	Like $(cmd cp) and $(cmd mv), $(cmd rm) may ask for confirmation before making permanent
	changes.  If it does, respond the same way that you have for the other
	commands.

	:

	_tutr_pressenter

	cat <<-:

	First, you should find out whether $(cmd rm) prompts for confirmation
	in your shell.

	Start small by removing only $(path copy0.txt).
	:
}

rm_1file_test() {
	if   _tutr_noop; then return $NOOP
	elif [[ ! -f $_BASE/copy0.txt ]]; then return 0
	elif [[ ${_CMD[@]} = "rm copy0.txt" && -f $_BASE/copy0.txt ]]; then return 99
	else _tutr_generic_test -c rm -a copy0.txt -d "$_BASE"
	fi
}

rm_1file_hint() {
	case $1 in
		99)
			cat <<-:
			Hmm, your command looks okay, but $(path copy0.txt) is still here.
			Did $(cmd rm) prompt you but you didn't respond affirmatively?

			Why don't you try this again.
			:
			;;
		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Remove the file $(path copy0.txt).
	  $(cmd rm copy0.txt)
	:
}

rm_1file_epilogue() {
	_tutr_pressenter
}



rm_star0_rw() {
	create_copy0_txt
	command cp -f "$_BASE/copy0.txt" "$_BASE/copy1.txt"
	command cp -f "$_BASE/copy0.txt" "$_BASE/new.txt"
	command mv -f "$_BASE/copy0.txt" "$_BASE/copy2.txt"
	create_move0_txt
	command mv -f "$_BASE/move0.txt" "$_BASE/move2.txt"
	create_different_txt
}

rm_star0_ff() {
	command rm -f "$_BASE/"*.txt
}

rm_star0_prologue() {
	cat <<-:
	Suppose you needed to delete 100 $(path .txt) files.

	To delete multiple files in a graphical file explorer, you would first
	highlight them with the mouse before pressing $(kbd '<DELETE>') or dragging
	them onto a representation of a garbage can.

	:

	_tutr_pressenter

	cat <<-:

	To remove those same files in the shell, you need to run $(cmd rm) with each
	target file's name as an argument.  Even with tab completion this would
	be unbearably tedious!

	What you need is a way to tell the shell to run $(cmd rm) on every file whose
	name ends with $(path .txt).  This is achieved with a $(bld wild card).

	:

	_tutr_pressenter

	cat <<-:

	A $(bld wild card) is a command line pattern that is replaced with matching
	filenames.  When you pass a wild card as an argument to a command, the
	shell replaces it with matching filenames before running your command.

	The shell has a few wild cards up its sleeve, but I will teach you the
	one that meets 90% of your needs.

	The asterisk '$(bld '*')' (a.k.a. "$(bld glob)", a.k.a. "$(bld star)") matches $(bld any) number of
	characters in a file's name:

	  $(cmd rm '*.txt')   => run $(cmd rm) on all files ending with $(bld .txt)
	  $(cmd rm 'l*.txt')  => run $(cmd rm) on all files beginning with the letter '$(bld l)' and
	                ending in $(bld .txt)
	  $(cmd rm '*t*')     => run $(cmd rm) on all files with "$(bld t)" anywhere in their names
	  $(cmd rm '*')       => run $(cmd rm) on every file here; this is $(bld "very dangerous!")

	Use a wild card to remove all files with names ending in $(bld .txt).
	:
}

rm_star0_test() {
	_TXTS_LEFT_BEHIND=99
	if [[ -n $ZSH_NAME ]]; then
		setopt local_options nullglob
	fi
	if   _tutr_noop; then return $NOOP
	elif [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif [[ -n $ZSH_NAME  && -z $(echo *.txt) ]]; then return 0
	elif [[ -n $BASH_VERSION && $(echo *.txt) = "*.txt" ]]; then return 0
	elif [[ ${_CMD[0]} = rm ]]; then return $_TXTS_LEFT_BEHIND
	else _tutr_generic_test -c rm -a "*.txt" -d "$_BASE"
	fi
}

rm_star0_hint() {
	case $1 in
		$_TXTS_LEFT_BEHIND)
			_tutr_pressenter
			cat <<-:

			There still exist one or more $(bld .txt) files after that command.
			You'll need to try again.
			:
			;;
		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Use a glob pattern to run $(cmd rm) on all files whose names end in $(bld .txt).

	Run $(cmd tutor hint) to see the shell wild card explanation again.
	:
}

rm_star0_epilogue() {
	_tutr_pressenter
	# this test doesn't match in Bash.  Glob expansion happens BEFORE the
	# preexec hook gets a look at the cmdline.  I don't think I can
	# distinguish 'rm *' from 'rm *.txt' without the presence of a non .txt
	local rx='^rm -f \*$|^rm \* -f$|^rm \*$'
	if [[ "${_CMD[@]}" =~ $rx ]]; then
		cat <<-:

		${_y}  """"""  """"""   ${_z}
		${_y} "              "  ${_z}
		${_W} .####.    .####.  ${_z}
		${_W},######,  ,######, ${_z}
		${_W}###  ###  ###  ### ${_z} Whoa, careful!  That command could have deleted $(bld too)
		${_W}'######' \'######' ${_z}  $(bld much)!  Fortunately for you, all of the files ended
		${_W} '####'   \'####'  ${_z}  in $(path .txt), so the command $(cmd "rm *") has the same effect
		${_W}           \       ${_z}  as $(cmd "rm *.txt").  But if there were other files here,
		${_W}         ___\      ${_z}            they'd have been $(cmd zapped), too!
		${_r}   ____________    ${_z}
		${_r}  /            \   ${_z}
		${_r}  \            /   ${_z}
		${_r}   \__________/    ${_z}

		This is a command that you need to be $(bld very) careful with.
		Running $(cmd "rm *") is playing with $(red fire).

		:
		_tutr_pressenter
	fi

	cat <<-:

	wild cards make you more efficient at removing files than a GUI.

	But being efficient when it comes to deleting files cuts both ways;
	in just a few keystrokes you can obliterate $(bld ALL) of your precious work!

	:
	_tutr_pressenter
}



rm_star1_pre() {
	# re-create any missing JPG or WAV files
	for I in {a..z}; do
		touch "$_BASE/$I.jpg"
	done

	for I in {0..9}; do
		touch "$_BASE/$I.wav"
	done
}

rm_star1_rw() {
	command rm -f "$_BASE/"*.jpg  "$_BASE/"*.wav
}
rm_star1_ff() {
	rm_star1_pre
	command rm -f "$_BASE/"*.wav
}

rm_star1_prologue() {
	cat <<-:
	Of course, wild cards can't save you from pressing '$(kbd y)' if $(cmd rm) prompts
	you for confirmation on every file.

	I just created 26 $(bld .jpg) and 10 $(bld .wav) files in this directory.

	You can use $(cmd ls) to see their names in the terminal.

	:

	if [[ -n "$_EXPLORER" ]]; then
		cat <<-:
		If you closed the file explorer window, reopen it with $(cmd $_OPEN .)
		(don't forget the dot at the end!).

		:
	else
		cat <<-:
		If you would like to see the files graphically, just run $(cmd $_OPEN .)
		(don't forget the dot at the end!).

		:
	fi

	cat <<-:
	Use $(cmd rm) with a wild card to remove all of the $(bld .wav) files with a single
	command.  Leave the $(bld .jpg) files alone.
	:
}

rm_star1_test() {
	_WAVS_LEFT_BEHIND=99
	_WRONG_FILES=98
	_STAR=97
	_TOO_MUCH=96

	if   _tutr_noop; then return $NOOP
	elif [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif [[ ${_CMD[0]} == rm && ${_CMD[1]} = "*" ]]; then return $_STAR
	elif [[ -n $ZSH_NAME ]]; then
		setopt local_options nullglob
		local JPG=$(echo *.jpg)
		local WAV=$(echo *.wav)
		if   [[ -n $JPG && -z $WAV ]]; then return 0
		elif [[ -z $JPG && -n $WAV ]]; then return $_WRONG_FILES
		elif [[ -z $JPG && -z $WAV ]]; then return $_TOO_MUCH
		elif [[ ${_CMD[0]} = rm && -n $WAV ]]; then return $_WAVS_LEFT_BEHIND
		fi
	else
		# TODO: save current state of shopt -p nullglob failglob
		# TODO: enable nullglob, disable failglob
		local JPG=$(echo *.jpg)
		local WAV=$(echo *.wav)
		# TODO: restore original nullglob, failglob
		if   [[ $JPG != "*.jpg" && $WAV  = "*.wav" ]]; then return 0
		elif [[ $JPG  = "*.jpg" && $WAV != "*.wav" ]]; then return $_WRONG_FILES
		elif [[ $JPG  = "*.jpg" && $WAV  = "*.wav" ]]; then return $_TOO_MUCH
		elif [[ ${_CMD[0]} = rm && $WAV != "*.wav" ]]; then return $_WAVS_LEFT_BEHIND
		fi
	fi
	_tutr_generic_test -c rm -a *.wav -d "$_BASE"
}

rm_star1_hint() {
	case $1 in
		$_WAVS_LEFT_BEHIND)
			_tutr_pressenter
			cat <<-:

			That command left some $(bld .wav) files behind.
			You'll need to try again.
			:
			;;

		$_WRONG_FILES)
			_tutr_pressenter
			rm_star1_pre
			cat <<-:

			I think that you deleted the $(bld wrong files)!
			I've put things back so you can try again.
			:
			;;

		$_TOO_MUCH)
			_tutr_pressenter
			rm_star1_pre
			cat <<-:

			Whoa, easy there!  That was $(bld much) too much.
			I've put things back so you can try again.
			:
			;;

		$_STAR)
			_tutr_pressenter
			rm_star1_pre
			rm_star0_rw
			cat <<-:

			You deleted everything!
			I've put things back so you can try again.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_BASE"
			return
			;;

		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Run $(cmd rm) with a wild card to remove all $(bld .wav) files in a single command.
	Leave the $(bld .jpg) files alone.

	Be ready to press '$(kbd y)' a whole bunch of times!
	:
}


rm_star1_epilogue() {
	cat <<-:
	They gone.

	:

	_tutr_pressenter
}



rm_star2_pre() {
	rm -rf "$_BASE"/{a..z}{a..z}.png "$_BASE"/{0..9}{0..9}.mp4
	touch "$_BASE"/{a..z}{a..z}.png "$_BASE"/{0..9}{0..9}.mp4
}


rm_star2_rw() {
	rm -rf "$_BASE"/{a..z}{a..z}.png "$_BASE"/{0..9}{0..9}.mp4
}

rm_star2_ff() {
	rm -rf "$_BASE"/{a..z}{a..z}.png "$_BASE"/{0..9}{0..9}.mp4
}

rm_star2_prologue() {
	cat <<-:
	To simulate your Downloads folder (a.k.a. the junk-drawer for computers)
	I have just created $(cyn 100) $(bld .mp4) and $(cyn 676) $(bld .png) files.  You can count them
	if you don't believe me.  I'm going to be a big jerk and make $(bld you) clean
	up $(bld my) mess.

	Does $(bld rm) prompt for confirmation on your computer?  If so, you're
	looking at pressing '$(kbd y)' $(cyn 776) times.  That is exactly the sort of tedious,
	repetitive thing that a computer ought to do for you.

	I'll remind you of $(cmd rm)'s syntax:
	  $(cmd rm '[-f] FILENAME...')

	This is where $(cmd rm)'s "$(bld force)" option $(cmd -f) comes in handy.
	$(cmd rm -f) temporarily disables confirmation prompts in favor of a
	"$(blu silent-but-deadly)" mode of operation.

	Example: forcibly remove all Markdown files in one command:
	  $(cmd rm -f '*.md')

	:
	_tutr_pressenter

	cat <<-:

	$(bld BE VERY CAREFUL WITH) $(cmd rm -f)$(bld '!!!')

	Every Unix hacker has their own harrowing story about this command.
	Don't become another statistic!  Think before you type, and think again
	before you hit $(kbd ENTER).  $(red Check yourself before you wreck yourself.)

	If you do find yourself answering hundreds of prompts, cancel the
	command with '$(kbd '^C')' and try again.  Understand that all files for which
	you answered "$(bld yes)" are already deleted.

	Are you ready to get dangerous?
	Remove all $(bld .png) and $(bld .mp4) files, leaving all other files unscathed.
	:
}

rm_star2_test() {
	_FILES_LEFT_BEHIND=99
	_REMOVED_JPGS=98
	if [[ -n $ZSH_NAME ]]; then
		setopt local_options nullglob
	fi
	if   _tutr_noop; then return $NOOP
	elif [[ -n $ZSH_NAME && -z $(echo *.jpg) ]]; then return $_REMOVED_JPGS
	elif [[ -n $BASH_VERSION && $(echo *.jpg) == "*.jpg" ]]; then return $_REMOVED_JPGS
	elif [[ -n $ZSH_NAME && -z $(echo *.png) && -z $(echo *.mp4) ]]; then return 0
	elif [[ -n $BASH_VERSION && $(echo *.png *.mp4) = "*.png *.mp4" ]]; then return 0
	elif [[ ${_CMD[0]} = rm ]]; then return $_FILES_LEFT_BEHIND
	else _tutr_generic_test -c rm -a *.png -a *.mp4 -d "$_BASE"
	fi
}

rm_star2_hint() {
	case $1 in
		$_FILES_LEFT_BEHIND)
			cat <<-:
			There are still some $(bld .png) or $(bld .mp4) files here.
			You'll need to try again.

			This command uses $(bld two) wild cards, $(cmd '*.png') and $(cmd '*.mp4').
			:
			;;
		$_REMOVED_JPGS)
			_tutr_pressenter
			cat <<-:

			Woah there buckaroo! You went a little crazy with that command and
			deleted the $(bld .jpg) files as well.  I put everything back to how
			it should be so you can try again.
			:
			rm_star2_pre
			rm_star1_ff
			;;
		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Use $(cmd rm) with a wild card to remove all 776 of the $(bld .png) and $(bld .mp4)
	files that I have created.

	  $(cmd rm -f '*.png') $(cmd '*.mp4')

	The $(cmd -f) option will let you avoid pressing "$(kbd y)" 776 times.
	:
}

rm_star2_epilogue() {
	cat <<-:
	How is $(bld that) for brute efficiency?

	Imagine doing that same task in a graphical file manager.  How much
	scrolling and dragging would it take to select that many files?

	And what if you accidentally highlighted a few $(bld .pdf) or $(bld .docx) files?

	I hope this gives you a glimpse of the power of the command shell.

	:
	_tutr_pressenter
}



rm_star3_ff() {
	command rm -f "$_BASE"/*
}

rm_star3_prologue() {
	cat <<-:
	For your last trick, use a bare glob '$(cmd '*')' to delete $(bld EVERYTHING) else in
	here.

	The '$(cmd '*')' pattern matches $(bld EVERY) file except for hidden ones.  Recall from
	Lesson #0 that hidden files have names that begin with a dot '$(path .)'.

	Add the $(cmd -f) option so you don't need to press '$(kbd y)' so many times.
	:
}

rm_star3_test() {
	if [[ -n $ZSH_NAME ]]; then
		setopt local_options nullglob
	fi

	if [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ -n $ZSH_NAME && -z $(echo *) ]]; then return 0
	elif [[ -n $BASH_VERSION && $(echo *) = "*" ]]; then return 0
	elif [[ ${_CMD[0]} = rm ]]; then return 99
	else _tutr_generic_test -c rm -a -f -a * -d "$_BASE"
	fi
}

rm_star3_hint() {
	case $1 in
		99)
			cat <<-:
			There are still files in here.
			These files are all junk anyway.  What are you waiting for?
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_BASE"
			return
			;;
		*)
			_tutr_generic_hint $1 rm "$_BASE"
			;;
	esac

	cat <<-:

	Use a bare glob '$(bld '*')' to delete all non-hidden files in this directory.
	You can combine this with the $(cmd -f) option to avoid pressing "$(kbd y)" so many
	times:
	  $(cmd 'rm -f *')
	:
}


rm_star3_epilogue() {
	cat <<-:
	Now that you've run that command, be careful the next time you feel it
	go out of your fingertips.  That is one command that should give you a
	sinking feeling each time you see it.

	Remember, in Unix file deletion is forever!

	:
	_tutr_pressenter
}


epilogue() {
	cat <<-EPILOGUE
	That wraps things up for now.  Before long the people looking over your
	shoulder will ask what you're hacking into and when the FBI will get
	here.  That's when you will know that you are a true shell user.

	If you opened a file explorer window, you may now $(red close) it.

	In this lesson you learned how to

	* Make copies of files
	* Move and rename files
	* Take advantage of tab completion
	* Remove files
	* Refer to multiple files with wild cards

	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}



case $_PLAT in
	WSL)  # Skip the step "tabcmplt_cmd" - tab completion for longest command
		source main.sh && _tutr_begin \
			copy01 \
			copy02 \
			list1 \
			cp_clobber \
			tabcmplt_ls_d \
			tabcmplt_ls_c \
			tabcmplt_ls_again \
			tabcmplt_cp_c \
			move01 \
			move02_err \
			move12 \
			mv_clobber \
			rm_1file \
			rm_star0 \
			rm_star1 \
			rm_star2 \
			rm_star3
		;;

	*)
		source main.sh && _tutr_begin \
			copy01 \
			copy02 \
			list1 \
			cp_clobber \
			tabcmplt_ls_d \
			tabcmplt_ls_c \
			tabcmplt_ls_again \
			tabcmplt_cp_c \
			tabcmplt_cmd \
			move01 \
			move02_err \
			move12 \
			mv_clobber \
			rm_1file \
			rm_star0 \
			rm_star1 \
			rm_star2 \
			rm_star3
		;;
esac

# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
