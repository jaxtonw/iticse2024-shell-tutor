#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=20

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

source ansi-terminal-ctl.sh
source open.sh
source progress.sh

if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source noop.sh
	source platform.sh
	source quiz.sh
	_Google() { echo ${_B}G${_R}o${_Y}o${_B}g${_G}l${_R}e${_z}; }
	_err() { (( $# == 0 )) && echo $(red _err) || echo $(red "$*"); }
	_py() { (( $# == 0 )) && echo $(grn Python) || echo $(grn $*) ; }
fi

_man_not_found() {
	case $_PLAT in
		*MINGW*)
			cat <<-MNF
			The command $(cmd man) was not found.  It is required for this lesson.

			Read "$(bld Installing the Unix Manual)" in $(path README.md) to learn how to set this
			up. I will open this page for you now.

			If this error persists, contact $_EMAIL
			MNF
_tutr_open 'https://gitlab.cs.usu.edu/erik.falor/shell-tutor#installing-the-unix-manual'
			;;
		*)
		cat <<-MNF
			The command $(cmd man) was not found.  It is required for this lesson.

			Contact $_EMAIL for help
			MNF
			;;
	esac
}

setup() {
	source screen-size.sh 80 30
	source platform.sh
	source assert-program-exists.sh
	_tutr_assert_program_exists man _man_not_found

	export _BASE="$PWD/lesson1"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"

	export EFILE=Elegant
	cat <<-TEXT > "$_BASE/$EFILE"
		elegant: adj.
		
		  [common; from mathematical usage] Combining simplicity, power, and
		  a certain ineffable grace of design. Higher praise than 'clever',
		  'winning', or even 'cuspy'.
		  
		  The French aviator, adventurer, and author Antoine de Saint-
		  Exupéry, probably best known for his classic children's book
		  "The Little Prince", was also an aircraft designer. He gave us
		  perhaps the best definition of engineering elegance when he said
		  "A designer knows he has achieved perfection not when there is
		  nothing left to add, but when there is nothing left to take away."

	https://www.catb.org/jargon/html/E/elegant.html

	TEXT
	touch -t 197311170853 "$_BASE/$EFILE"

	export MFILE=Menuitis
	cat <<-TEXT > "$_BASE/$MFILE"
		menuitis: /men'yoo-i:-tis/, n.
		
		  Notional disease suffered by software with an obsessively
		  simple-minded menu interface and no escape. Hackers find this
		  intensely irritating and much prefer the flexibility of
		  command-line or language-style interfaces, especially those
		  customizable via macros or a special-purpose language in which one
		  can encode useful hacks.
		
		  See user-obsequious, drool-proof paper, WIMP environment, for the
		  rest of us.

	https://www.catb.org/jargon/html/M/menuitis.html

	TEXT
	touch -t 199108250527 "$_BASE/$MFILE"

	export IFILE=Indent-Style
	cat <<-TEXT > "$_BASE/$IFILE"
		indent style: n.
		
		  [C, C++, and Java programmers] The rules one uses to indent code
		  in a readable fashion. There are four major C indent styles,
		  described below; all have the aim of making it easier for the
		  reader to visually track the scope of control constructs. They
		  have been inherited by C++ and Java, which have C-like syntaxes.
		  The significant variable is the placement of { and } with respect
		  to the statement(s) they enclose and to the guard or controlling
		  statement (if, else, for, while, or do) on the block, if any.
		
		  K&R style — Named after Kernighan & Ritchie, because the examples
		  in K&R are formatted this way. Also called kernel style because
		  the Unix kernel is written in it, and the 'One True Brace Style'
		  (abbrev. 1TBS) by its partisans. In C code, the body is typically
		  indented by eight spaces (or one tab) per level, as shown here.
		  Four spaces are occasionally seen in C, but in C++ and Java four
		  tends to be the rule rather than the exception.
		
		    if (<cond>) {
		            <body>
		    }
		
		  Allman style — Named for Eric Allman, a Berkeley hacker who wrote
		  a lot of the BSD utilities in it (it is sometimes called BSD
		  style). Resembles normal indent style in Pascal and Algol. It is
		  the only style other than K&R in widespread use among Java
		  programmers. Basic indent per level shown here is eight spaces,
		  but four (or sometimes three) spaces are generally preferred by
		  C++ and Java programmers.
		
		    if (<cond>)
		    {
		            <body>
		    }
		
		  Whitesmiths style — popularized by the examples that came with
		  Whitesmiths C, an early commercial C compiler. Basic indent per
		  level shown here is eight spaces, but four spaces are occasionally
		  seen.
		
		    if (<cond>)
		            {
		            <body>
		            }
		
		  GNU style — Used throughout GNU EMACS and the Free Software
		  Foundation code, and just about nowhere else. Indents are always
		  four spaces per level, with { and } halfway between the outer and
		  inner indent levels.
		
		    if (<cond>)
		      {
		        <body>
		      }
		
		  Surveys have shown the Allman and Whitesmiths styles to be the
		  most common, with about equal mind shares. K&R/1TBS used to be
		  nearly universal, but is now much less common in C (the opening
		  brace tends to get lost against the right paren of the guard part
		  in an if or while, which is a Bad Thing).  Defenders of 1TBS argue
		  that any putative gain in readability is less important than their
		  style's relative economy with vertical space, which enables one to
		  see more code on one's screen at once. The Java Language
		  Specification legislates not only the capitalization of
		  identifiers, but where nouns, adjectives, and verbs should be in
		  method, class, interface, and variable names (section 6.8). While
		  the specification stops short of also standardizing on a bracing
		  style, all source code originating from Sun Laboratories uses the
		  K&R style. This has set a precedent for Java programmers, which
		  most follow.
		
		  Doubtless these issues will continue to be the subject of holy wars.

	https://www.catb.org/jargon/html/I/indent-style.html

	TEXT
	touch -t 200103241305 "$_BASE/$IFILE"

	export TFILE=TTY
	cat <<-TEXT > "$_BASE/$TFILE"
		tty: /T-T-Y/, /tit-ee/, n.
		
		  The latter pronunciation was primarily ITS, but some Unix people
		  say it this way as well; this pronunciation is not considered to
		  have sexual undertones.
		
		  1. A terminal of the teletype variety, characterized by a noisy
		     mechanical printer, a very limited character set, and poor
		     print quality. Usage: antiquated (like the TTYs themselves).
		     See also bit-paired keyboard.
		
		  2. [especially Unix] Any terminal at all; sometimes used to refer
		     to the particular terminal controlling a given job.
		
		  3. [Unix] Any serial port, whether or not the device connected to
		     it is a terminal; so called because under Unix such devices
		     have names of the form tty*. Ambiguity between senses 2 and 3
		     is common but seldom bothersome

	https://www.catb.org/jargon/html/T/tty.html

	TEXT

	export SFILE=Spaghetti-Code
	cat <<-TEXT > "$_BASE/$SFILE"
		spaghetti code: n.

		Code with a complex and tangled control structure, esp. one using many
		GOTOs, exceptions, or other 'unstructured' branching constructs. Pejorative.
		The synonym kangaroo code has been reported, doubtless because such code has
		so many jumps in it.

	https://www.catb.org/jargon/html/S/spaghetti-code.html

	TEXT
	touch -t 197111031402 "$_BASE/$SFILE"


	export _LESS_KEYS="* Press $(kbd q) or $(kbd Q) to quit
* Press $(kbd j) or $(kbd Down Arrow) to scroll down by one line
* Press $(kbd k) or $(kbd Up Arrow) to scroll up by one line
* Press $(kbd spacebar) to scroll down by one page
* $(kbd h) or $(kbd H) opens the help screen; $(kbd q) closes it again"
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #1: Running Commands in the Shell

	In the last lesson you learned the basics of using a command shell to
	run simple commands and recover from errors.

	This time you will:

	 * Write and run even more complicated commands
	 * Use the $(cmd less) pager to read large documents in the terminal
	 * Learn the difference between $(bld arguments) and $(bld options)
	 * Find out how to get help in the shell

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



ls_prologue() {
	cat <<-:
	Begin by running $(cmd ls) to see what files are here.
	:
}

ls_test() {
	_tutr_generic_test -c 'ls|dir' -d "$_BASE"
}

ls_hint() {
	_tutr_generic_hint $1 ls "$_BASE"
	cat <<-:

	Run $(cmd ls) to see what files are here.
	:
}

ls_epilogue() {
	_tutr_pressenter
	if [[ ${_CMD[0]} == dir ]]; then
		cat <<-:

		${_R}   ___________    ${_Z}
		${_R}  /           \   ${_Z}     Old habits are tough to break, aren't they!
		${_R} / __ ___ _  __\  ${_Z}      While $(cmd dir) does work, this tutorial expects
		${_R}| / _|  _/ \|_ \| ${_Z}                you to use $(cmd ls) instead.
		${_R}| \_ \||| o | _/| ${_Z}
		${_R}| |__/|| \_/||  | ${_Z}It's more versatile and standard across Unix systems,
		${_R} \             /  ${_Z}      and will serve you better in the long run!
		${_R}  \___________/   ${_Z}

		:
		_tutr_pressenter
	fi
}




echo_prologue() {
	cat <<-:
	Those are some oddly-named files...

	In the last lesson you learned the $(cmd echo) command, which simply prints its
	arguments to the screen.  Recall that $(bld arguments) are what we call the
	words that come after a command's name on the command line.  They serve
	the same purpose as arguments to a function in $(_py).

	It doesn't make a difference to $(cmd echo) if its arguments happen to be names
	of files.  Run $(cmd echo) with these arguments: the names of two files, and
	one word that is not a file

	  $(cmd echo Elegant Spaghetti-Code Black-Art)
	:
}

echo_test() {
	_tutr_generic_test -c echo -a Elegant -a Spaghetti-Code -a ".*"
}

echo_hint() {
	_tutr_generic_hint $1 echo
}

echo_epilogue() {
	_tutr_pressenter
}



cat_es_prologue() {
	cat <<-:
	Likewise, you can give $(cmd cat) multiple arguments.

	$(cmd cat) the names of those two files, $(path Elegant) and $(path Spaghetti-Code),
	along with the non-file $(cmd Black-Art)
	:
}

cat_es_test() {
	_tutr_generic_test -f -c cat -a Elegant -a Spaghetti-Code -a Black-Art -d "$_BASE"
}

cat_es_hint() {
	_tutr_generic_hint $1 cat "$_BASE"
}

cat_es_epilogue() {
	_tutr_pressenter

	cat <<-:

	${_Y}    _.-._   ${_z}
	${_Y}   | | | |_ ${_z}
	${_Y}   | | | | |${_z}
	${_Y}   | | | | |${_z}     Say hi to our familiar friend,
	${_Y} _ |  '-._ |${_z}  the $(_err No such file or directory) error!
	${_Y} \\\`\\\`-.'-._;${_z}
	${_Y}  \    '   |${_z}          Long time, no see!
	${_Y}   \  .\`  / ${_z}
	${_K}jgs${_Y} |    |  ${_z}


	This demonstration illustrates the difference between $(cmd cat) and $(cmd echo):

	 *  $(cmd echo) prints the $(bld names) of files
	 *  $(cmd cat) prints what's $(bld inside) of files

	:
	_tutr_pressenter
}




cat_mmm_prologue() {
	cat <<-:
	You can $(cmd cat) the same filename over and over again.  The result looks
	like one long file.

	Repeat the file $(path Menuitis) three times
	:
}

cat_mmm_test() {
	_tutr_generic_test -c cat -a Menuitis -a Menuitis -a Menuitis -d "$_BASE"
}

cat_mmm_hint() {
	_tutr_generic_hint $1 cat "$_BASE"
}

cat_mmm_epilogue() {
	_tutr_pressenter
}



cat_emts_pre() {
	_LINES=$(tput lines)
}

cat_emts_prologue() {
	cat <<-:
	Let's try that again, but with a different mix of filenames:

	  $(cmd cat Spaghetti-Code Menuitis TTY Elegant)
	:
}

cat_emts_test() {
	_tutr_generic_test -c  cat -a Spaghetti-Code -a Menuitis -a TTY -a Elegant -d "$_BASE"
}

cat_emts_hint() {
	_tutr_generic_hint $1 cat "$_BASE"
}

cat_emts_epilogue() {
	if   (( _LINES < 30 )); then
		cat <<-:
		Most of the text generated by $(cmd cat) scrolled right off the screen.

		You $(bld might) be able to read it by scrolling up, but what a hassle!

		:
	elif (( _LINES < 59 )); then
		cat <<-:
		That much text doesn't fit on the screen!

		The first few lines have scrolled off the top.  You $(bld might) be able
		to read them by scrolling up, but what a hassle!

		:
	elif (( _LINES < 64 )); then
		cat <<-:
		That much text $(bld just barely) fits on your screen!

		What if your terminal window was smaller, or if those files were
		longer?

		:
	else
		cat <<-:
		You have a pretty large terminal, so all of that text fits on your
		screen.  But what if your terminal window was smaller, or those
		files were longer?

		:
	fi

	_tutr_pressenter
}



cat_i_pre() {
	_LINES=$(tput lines)
}

cat_i_prologue() {
	if   (( _LINES > 76 )); then
		cat <<-:
		The file $(path Indent-Style) is longer than all of the others, but somehow
		still fits on your screen.  I have to ask, are you really able to read
		this text?  Your font must be so small!

		Anyhow, run this command now:
		  $(cmd cat Indent-Style)
		:
	else
		cat <<-:
		$(path Indent-Style) certainly will not fit on your screen, but I am going to ask
		you to $(cmd cat) it anyway.
		:
	fi
}

cat_i_test() {
	_tutr_generic_test -c cat -a Indent-Style -d "$_BASE"
}

cat_i_hint() {
	_tutr_generic_hint $1 cat "$_BASE"

	cat <<-:

	Run this command to proceed:
	  $(cmd cat Indent-Style)
	:
}

cat_i_epilogue() {
	_tutr_pressenter
	cat <<-:

	${_M} _____ _       ____  ____    ${_Z}
	${_M}|_   _| |    _|  _ \\|  _ \\ ${_Z}
	${_M}  | | | |   (_) | | | |_) |  ${_Z}
	${_M}  | | | |___ _| |_| |  _ <   ${_Z}
	${_M}  |_| |_____( )____/|_| \\_\ ${_Z}
	${_M}            |/               ${_Z}
	               ${_C}amirite?${_Z}

	Now you'll learn what to do with text that overflows the screen.

	:
	_tutr_pressenter
}




less_prologue() {
	cat <<-:
	$(cmd less) is a program called a "$(bld pager)".  It is used like $(cmd cat) to display text
	on a terminal.  In contrast to $(cmd cat), $(cmd less) shows one page of text at a
	time and waits for you to press a key before showing the next page.

	In $(cmd less) you can scroll up and down through the text with the $(kbd keyboard);
	your mouse's scroll wheel may or may not work in this program.
	Depending on your outlook, this is not necessarily a bad thing.

	$_LESS_KEYS

	Read the file $(path Indent-Style) in $(cmd less).  Use these keys to scan all the way
	through it.  There is a quiz afterward.
	:
}

less_test() {
	_tutr_generic_test -c less -a Indent-Style -d "$_BASE"
}

less_hint() {
	_tutr_generic_hint $1 less "$_BASE"
}

less_epilogue() {
	cat <<-:
	Why is it called $(cmd less)?  Because it was preceeded by an earlier
	program called $(cmd more).  $(cmd more) showed a screenful of text at a time, but did
	not support scrolling back.  $(cmd less) is an improved "drop-in" replacement.

	As the saying goes, "$(bld less is more)".

	:
	_tutr_pressenter
}



quiz() {
	local intro="Which indentation style is this?"

	case $_VARIANT in
		"K&R")
			cat <<-:
				$intro

			    if (<cond>) {
			            <body>
			    }

			:
			_tutr_quiz "K&R" Allman Whitesmiths GNU
			;;

		Allman)
			cat <<-:
				$intro

			    if (<cond>)
			    {
			            <body>
			    }

			:
			_tutr_quiz Allman "K&R" Whitesmiths GNU
			;;

		Whitesmiths)
			cat <<-:
				$intro

			    if (<cond>)
			            {
			            <body>
			            }

			:
			_tutr_quiz Whitesmiths Allman "K&R" GNU
			;;

		GNU)
			cat <<-:
				$intro

			    if (<cond>)
			      {
			        <body>
			      }

			:
			_tutr_quiz GNU Whitesmiths Allman "K&R"
			;;

		*)
			cat <<-:
				Hang on!  It's not yet time to take the quiz.
			:
			return 0
			;;
	esac
}

indentation_quiz_pre() {
	declare -a variants=("K&R" Allman Whitesmiths GNU)
	declare -g _VARIANT=${variants[$(( RANDOM % ${#variants[@]}))]}
}

indentation_quiz_prologue() {
	cat <<-:
	I wasn't kidding about the quiz.

	If you get it wrong, re-read $(path Indent-Style) with $(cmd less) and try again.

	Run $(cmd quiz) to proceed.
	:
}

indentation_quiz_test() {
	_REREAD_FILE=1
	_RAN_LESS=2
	_TRY_AGAIN=3
	_GAVE_UP=6
	[[ ${_CMD[0]} == quiz && $_RES == 0 ]] && return 0
	[[ ${_CMD[0]} == quiz && $_RES == $_GAVE_UP ]] && return 0
	[[ ${_CMD[0]} == quiz ]] && return $_TRY_AGAIN
	[[ ${_CMD[@]} == "less Indent-Style" ]] && return $_REREAD_FILE
	[[ ${_CMD[0]} == less ]] && return $_RAN_LESS
	return $_PASS
}

indentation_quiz_hint() {
	case $1 in
		$_REREAD_FILE)
		cat <<-:
		Now that you've looked at that file again, run $(cmd quiz) to try again.
		:
		;;

	$_RAN_LESS)
		cat <<-:
		Remember to use the arrow keys (or j/k) to scroll up and down to
		find the right section of the document.
		:
		;;

	*)
		cat <<-:
		The important thing here isn't to memorize indentation styles from a
		programming language you aren't using in this class.  This is to
		help you practice navigating a long document in the $(cmd less) pager.

		Run $(cmd less Indent-Style) to read up on the indentation types and
		try again.
		:
		;;
	esac
}

indentation_quiz_epilogue() {
	if [[ $_RES == $_GAVE_UP ]]; then
		cat <<-:
		I can't say I blame you for dipping out.
		Nerd fights are exhausting.

		:
	fi

	cat <<-:
	Who knew that indentation could be such a touchy topic?
	Now you know why $(_py) insists on only one indentation style!

	:
	_tutr_pressenter
}



man_cat_prologue() {
	cat <<-:
	While $(cmd less) is handy when you need to read a text file that is too big
	for your screen, usually, you will not directly run it yourself.  You
	will most often use $(cmd less) through other programs that produce too much
	output to be read comfortably in a plain terminal.

	Let's switch gears for a moment, and consider a hypothetical:
	${_Y}  ___  ${_Z}
	${_Y} |__ \ ${_Z} What would you do if I asked you to find a shell
	${_Y}   / / ${_Z} command to add a rule to your computer's firewall
	${_Y}  |_|  ${_Z}
	${_Y}  (_)  ${_Z} (Don't worry, there is no quiz this time)

	:
	_tutr_pressenter

	cat <<-:

	You're probably thinking "I'd $(_Google) it"!  That can work, but consider:

	 * There are many different versions of $(bld shells) and $(cmd commands) out there.
	   How can you be sure the article you found on the web applies to the
	   versions of software on your computer right now?

	 * The command shell long predates the World Wide Web, and more so
	   $(_Google).  How did people figure things out before the internet?

	 * What would you do if the WiFi were down?  Give up and call it a day?

	:

	_tutr_pressenter

	cat <<-:

	The $(bld official) way to get help in the shell is through the system manual
	accessed through the $(cmd man) command.  $(cmd man) takes as an argument the name of
	another command, and displays its manual page using $(cmd less).

	 * When you install programs on your computer, the most up-to-date
	   instructions are installed at the same time.

	 * If $(cmd man) cannot find the manual page for that command, it usually
	   means that program is not installed on that computer.

	 * When programs are installed with their own documentation you can be
	   confident that the instructions will match the code you are running,
	   even if a newer version is available online.

	:
	_tutr_pressenter

	cat <<-:

	Try this out now by opening the manual for $(cmd cat).

	As a reminder, these are the shortcut keys for $(cmd less):

	$_LESS_KEYS
	:
}

man_cat_test() {
	_tutr_generic_test -c man -a cat
}

man_cat_hint() {
	_tutr_generic_hint $1 man
	cat <<-:

	Read the manual for the $(cmd cat) command.
	:
}

man_cat_epilogue() {
	cat <<-:
	Who knew that a simple program like $(cmd cat) could have so many options?

	$(path http://gaul.org/files/cat_-v_considered_harmful.html)

	:
	_tutr_pressenter

	cat <<-:

	You will be referring to manual pages for the remainder of this lesson.
	It may be helpful to open another terminal window to read the manual
	while running commands in this one.

	:
	_tutr_pressenter
}



cat_n_mmm_prologue() {
	cat <<-:
	Command-line arguments beginning with a dash '$(cmd -)' (A.K.A. minus) are
	called "$(bld options)".  Options are not understood by the command as a file
	that should be opened.  Rather, they control the program's behavior.

	There's nothing magic about the dash; it is just a convention because
	people $(bld usually) don't give files names beginning with '$(cmd -)'.  When a
	program sees an argument that begins with '$(cmd -)' it can assume it does not
	refer to a file.  Of course, this causes problems if you accidentally
	create files with weird names, so try not to do that, okay?

	The $(cmd man) page you just looked at shows that $(cmd cat) can take many options.
	There is an option that causes $(cmd cat) to print $(bld line numbers) in front of its
	output.  It's okay if you didn't catch it before; you can re-read the
	manual to find it.

	Then, run $(cmd cat) again using that option with $(path Menuitis) repeated thrice to
	see how many lines in total are output.

	In other words, fill the blank in this command with $(cmd cat)'s line
	numbering option:
	  $(cmd cat __ Menuitis Menuitis Menuitis)
	:
}

cat_n_mmm_test() {
	_LITERALLY=99
	_ALMOST=98
	_READ_MANUAL=97
	[[ "${_CMD[@]}" == "man cat" ]] && return $_READ_MANUAL
	_tutr_noop && return $NOOP
	[[ "${_CMD[@]}" == "cat __ Menuitis Menuitis Menuitis" ]] && return $_LITERALLY
	[[ "${_CMD[@]}" == "cat -b Menuitis Menuitis Menuitis" ]] && return $_ALMOST
	_tutr_generic_test -c cat -a -n -a Menuitis -a Menuitis  -a Menuitis -d "$_BASE"
}

cat_n_mmm_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you are looking for?  Let's find out!

			Run $(cmd cat) with the option that puts a line number before each line.
			:
			;;

		$_LITERALLY)
			_tutr_pressenter
			cat <<-:

			Do you always take instructions this literally?

			If you scroll up to the beginning of this command's output, you will
			see this $(_err error) message:
			  $(_err "cat: __: No such file or directory")

			This happened because $(cmd cat) misinterpreted $(path __) as a filename.

			$(bld Replace the blank in this command) with the option from $(cmd cat)'s manual that
			enables line numbering.
			  $(cmd cat __ Menuitis Menuitis Menuitis)
			:
			;;

		$_ALMOST)
			_tutr_pressenter
			cat <<-:

			That was a $(bld really) good guess, but not the option I am looking for.

			Notice that emptly lines were not numbered.  The option I want you to use
			puts numbers in front of every line, even blanks.

			Back to the manual!
			:
			;;
		*)
			_tutr_generic_hint $1 cat "$_BASE"
			;;
	esac
}

cat_n_mmm_epilogue() {
	if [[ $_PLAT != Apple ]]; then
		_tutr_pressenter

		cat <<-:

		$(blu 42)... that number keeps popping up everywhere.
		I wonder if it has any significance?

		:
	fi

	_tutr_pressenter
}



ls_1_pre() {
	unset "_NOOP[ls]"
}

ls_1_prologue() {
	cat <<-:
	$(cmd ls) is much more sophisticated than $(cmd cat), and has many more options.
	Consequently, its man page is longer.  I want you to dive in and find
	a particular option.

	You will have noticed that, by default, $(cmd ls) prints its list horizontally.
	Find an option that lists files $(bld one per line), making a $(bld single column).
	Then run that command.
	:
}

ls_1_test() {
	_READ_MANUAL=97
	[[ "${_CMD[@]}" == "man ls" ]] && return $_READ_MANUAL
	_tutr_noop && return $NOOP
	_tutr_generic_test -c ls -a '^--format=single-column$|^-1$' -d "$_BASE"
}

ls_1_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you are looking for?

			Run $(cmd ls) with the option that prints the list of filenames in a
			single column.
			:
			;;

		*)
			_tutr_generic_hint $1 ls

			cat <<-:

			Here are some hints:
			  0. Options can be $(bld digits), not just letters
			  1. $(bld Scroll down) - the answer is not near the top
			  2. You're looking for a $(bld short option) (starts with one '$(cmd -)'), and
			     not a $(bld long option) (they begin with two '$(cmd --)')

			When in the manual page viewer, use these keys to navigate:

			$_LESS_KEYS

			Run $(cmd ls) with the option that list file names one per line,
			in a $(bld single column).
			:
			;;
	esac
}

ls_1_epilogue() {
	if [[ "${_CMD[@]}" = *single-column* ]]; then
		cat <<-:
		Good work!  But that was a lot of typing.

		$(cmd ls) has a shorter option that does the very same thing: $(cmd "-1").
		Isn't that short and sweet?

		I'll let you get away with $(cmd "--format=single-column") this time,
		but for the rest of the lesson I will only accept $(cmd "-1").

		Just looking out for your carpal tunnels :)

		:
	else
		cat <<-:
		Good work!

		:
	fi
	_tutr_pressenter

	cat <<-:

	Besides being accessible even when the internet is down, the biggest
	advantage of man pages is that they $(bld exactly) match the software on your
	computer right now.

	You must $(bld always) be aware of version mismatches when looking up help
	online.  It is way too easy to find obsolete or inaccurate information
	with a search engine.  Mac users will find that Linux-specific webpages
	give advice that doesn't work on their computer, and vice versa.

	Man pages also don't have ads, so there's that.

	:
	_tutr_pressenter
}



ls_1S_prologue() {
	cat <<-:
	Let's try a few more of these.

	$(cmd ls) has another option that lists files by $(ylw size), largest first.
	Use it along with '$(cmd "-1")' to display the files in one column.
	The order that you give these options to $(cmd ls) doesn't matter.
	:
}

ls_1S_test() {
	local pattern='^ls -S1$|^ls -1S$|^ls -1 -S$|^ls -S -1$'
	_READ_MANUAL=99
	_MAN_NO_PAGE=95
	_MAN_WRONG_PAGE=94
	_SORTED=98
	_SINGLE=97
	_PRINT_SIZE=96

	[[ "${_CMD[@]}" == "man ls" ]] && return $_READ_MANUAL
	[[ "${_CMD[@]}" == man ]] && return $_MAN_NO_PAGE
	[[ "${_CMD[0]}" == man ]] && return $_MAN_WRONG_PAGE
	[[ "${_CMD[@]}" == "ls -S" ]] && return $_SORTED
	[[ "${_CMD[@]}" == "ls -1" ]] && return $_SINGLE
	[[ "${_CMD[@]}" == ls*s* ]] && return $_PRINT_SIZE
	_tutr_noop && return $NOOP
	[[ "${_CMD[@]}" =~ $pattern ]] && return 0
	_tutr_generic_test -c ls -a -1 -a -S -d "$_BASE"
}

ls_1S_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find the option that lists files by $(ylw size), largest first?
			The order that you give these options to $(cmd ls) doesn't matter.
			:
			;;

		$_MAN_NO_PAGE)
			cat <<-:
			The $(cmd man) command needs an argument!

			Try running $(cmd man ls).
			:
			;;

		$_MAN_WRONG_PAGE)
			cat <<-:
			$(cmd "${_CMD[@]}")? That's an odd choice.

			I don't think you'll find what you're looking for in there.
			Try reading $(cmd man ls).
			:
			;;

		$_PRINT_SIZE)
			cat <<-:
			You used the option that $(bld prints the size) of files.  I asked you
			to list the files $(bld sorted) by their $(ylw size).

			Try again.
			:
			;;

		$_SINGLE)
			cat <<-:
			So close!

			That's the option that prints the files in one column.  But you need to
			combine it with an option that sorts files by their $(ylw size).
			:
			;;

		$_SORTED)
			cat <<-:
			You're halfway there!

			That's the option that prints the files in the right order.  But you
			need to combine it with $(cmd "-1") so the list runs down the page.
			:
			;;

		*)
			_tutr_generic_hint $1 man

			cat <<-:

			When in the manual page viewer, use these keys to navigate:

			$_LESS_KEYS

			Run $(cmd ls) with options that print the files in one
			column from largest to smallest.  The order that you give these
			options to $(cmd ls) doesn't matter.
			:
			;;
	esac
}

ls_1S_epilogue() {
	_tutr_pressenter
	cat <<-:
	${_Y}      _         ${_z}
	${_Y}     /(|        ${_z}
	${_Y}    (  :        ${_z}
	${_Y}   __\  \ ${_B} _____${_z}
	${_Y} (____)  \`${_B}|     ${_z} I think you're getting the hang of this!
	${_Y}(____)|   ${_B}|     ${_z}
	${_Y} (____).__${_B}|     ${_z}
	${_Y}  (___)__.${_B}|_____${_z}

	:
	_tutr_pressenter
}



ls_1t_prologue() {
	cat <<-:
	There is an option that lists files $(ylw chronologically) based on how
	$(bld recently) they were modified.

	Combine that with $(cmd "-1") to list files vertically from youngest to oldest.

	The correct command $(bld does not) show the $(bld dates) the files were changed;
	just their names.
	:
}

ls_1t_test() {
	local pattern="^ls -t1$|^ls -1t$|^ls -1\ -t$|^ls -t\ -1$"
	_READ_MANUAL=99
	_SORTED=98
	_SINGLE=97
	_MAN_NO_PAGE=96
	_MAN_WRONG_PAGE=95

	[[ "${_CMD[@]}" == man ]] && return $_MAN_NO_PAGE
	[[ "${_CMD[@]}" == "man ls" || "${_CMD[@]}" == "man 1 ls" ]] && return $_READ_MANUAL
	[[ "${_CMD[0]}" == man ]] && return $_MAN_WRONG_PAGE
	[[ "${_CMD[@]}" == "ls -t" ]] && return $_SORTED
	[[ "${_CMD[@]}" == "ls -1" ]] && return $_SINGLE
	_tutr_noop && return $NOOP
	[[ "${_CMD[@]}" =~ $pattern ]] && return 0
	_tutr_generic_test -c ls -a -1 -a -t -d "$_BASE"
}

ls_1t_hint() {
	case $1 in
		$NOOP)
			;;

		$_SINGLE)
			cat <<-:
			So close!

			That's the option that prints the files in one column.  But you need to
			combine it with an option that sorts files by their $(bld modification time).
			Again, the order that you give these options to $(cmd ls) doesn't matter.
			:
			;;

		$_SORTED)
			cat <<-:
			You're halfway there!

			That's the option that prints the files in the right order.  But you
			need to combine it with $(cmd "-1") so the list runs down the page.
			Again, the order that you give these options to $(cmd ls) doesn't matter.
			:
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you are looking for?

			Run $(cmd ls) with options that print the files in a single column from
			youngest to oldest.  Again, the order that you give these options to
			$(cmd ls) doesn't matter.
			:
			;;

		$_MAN_NO_PAGE)
			cat <<-:
			The $(cmd man) command needs an argument!

			Try running $(cmd man ls).
			:
			;;

		$_MAN_WRONG_PAGE)
			cat <<-:
			$(cmd "${_CMD[@]}")? That's an odd choice.

			I don't think you'll find what you're looking for in there.
			Try reading $(cmd man ls).
			:
			;;

		*)
			_tutr_generic_hint $1 ls

			cat <<-:

			When in the manual page viewer, use these keys to navigate:

			$_LESS_KEYS

			Run $(cmd ls) with options that print the files in one column from
			youngest to oldest.
			:
			;;
	esac
}

ls_1t_epilogue() {
	_tutr_pressenter
	cat <<-:

${_Y}      _.-'''''-._    ${_Z}
${_Y}    .'  _     _  '.  ${_Z}
${_Y}   /   (_)   (_)   \ ${_Z}
${_Y}  |  ,           ,  |${_Z}  Nailed it!
${_Y}  |  \\\`.       .\`/  |${_Z}
${_Y}   \  '.\`'""'"\`.'  / ${_Z}
${_Y}    '.  \`'---'\`  .'  ${_Z}
${_K}jgs${_Y}   '-._____.-'    ${_Z}

	:
	_tutr_pressenter
}



ls_1tr_prologue() {
	cat <<-:
	I often want to know which file was most recently changed.  Sorting
	the list from newest to oldest works when there are only a few files;
	I can just look at the file on top.

	Sometimes I work with hundreds of files, and the top of the list
	generated by $(cmd ls -1t) flies off the top of the screen, leaving
	behind a list of ancient files.

	Go back into the manual and find a way to $(red reverse) the file listing.
	This command will use three options:
	  * $(cmd "-1") output one column of words
	  * $(cmd "-t") list files by time of $(ylw last change)
	  * $(cmd "-X") the new option to $(red reverse) the sort order
	    (hint: it's not $(cmd "-X"))
	:
}


ls_1tr_test() {
	_LITERALLY=99
	_READ_MANUAL=97
	local pattern="^ls -r -t -1$|^ls -t -r -1$|^ls -r -1 -t$|^ls -1 -r -t$|^ls -t -1 -r$|^ls -1 -t -r$|^ls -tr -1$|^ls -1 -tr$|^ls -rt -1$|^ls -1 -rt$|^ls -r -t1$|^ls -t1 -r$|^ls -r -1t$|^ls -1t -r$|^ls -t -1r$|^ls -1r -t$|^ls -t -r1$|^ls -r1 -t$|^ls -rt1$|^ls -tr1$|^ls -r1t$|^ls -1rt$|^ls -t1r$|^ls -1tr$"

	[[ "${_CMD[@]}" == "man ls" ]] && return $_READ_MANUAL
	_tutr_noop && return $NOOP
	[[ ${_CMD[0]} == ls && "${_CMD[@]}" == *X* ]] && return $_LITERALLY
	[[ "${_CMD[@]}" =~ $pattern ]] && return 0
	_tutr_generic_test -c ls -a -1 -a -r -a -t -d "$_BASE"
}

ls_1tr_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you are looking for?  Let's find out!

			Run $(cmd ls) with options to list files in $(red reverse) chronological
			order in one column.
			:
			;;

		$_LITERALLY)
			_tutr_pressenter
			cat <<-:

			Did you actually expect the $(cmd "-X") to work?

			Run $(cmd ls) with options to list files in $(red reverse) $(ylw chronological)
			$(ylw order) in one column.
			:
			;;
		*)
			_tutr_generic_hint $1 ls "$_BASE"
			cat <<-:

			Run $(cmd ls) with options to list files in $(red reverse) $(ylw chronological)
			$(ylw order) in a single column.
			:
			;;
	esac
}

ls_1tr_epilogue() {
	_tutr_pressenter
	cat <<-:
	${_Y}        _ _   ${_z}
	${_Y}     .-/ / )  ${_z}
	${_K}VK  ${_Y} |/ / /   ${_z}
	${_Y}     /.' /    ${_z}
	${_Y}    // .---.  ${_z}   Nice!
	${_Y}   /   .--._\ ${_z}
	${_Y}  /    \`--' / ${_z}
	${_Y} /     .---'  ${_z}
	${_Y}/    .'       ${_z}
	${_Y}    /         ${_z}

	:
	_tutr_pressenter
}




man_fail_prologue() {
	cat <<-:
	Now is a good time to find out what happens when you request the manual
	for a command that does not exist.

	Just take a guess at a name of a program that isn't installed on your
	computer.  It shouldn't be hard, there are lots of programs that you
	don't have.  For instance, you (probably) don't have a program called
	"non-existent-program", so looking up its man page should fail:
	  $(cmd man non-existent-program)

	(If that man page actually exists, contact $_EMAIL for help)
	:
}


man_fail_test() {
	_tutr_generic_test -c man -a .+ -f
}

man_fail_hint() {
	case $1 in
		$STATUS_WIN)
			cat <<-:
			Well, it looks like you do have $(cmd ${_CMD[-1]}) on your computer.
			Who knew?

			Try harder to think of a command that $(bld is not) installed.

			As much as I try, $(cmd pyhton) never works on my computer.
			Maybe it doesn't work on your computer either.
			:
			;;

		*)
			_tutr_generic_hint $1 man
			;;
	esac
}

man_fail_epilogue() {
	_tutr_pressenter
	cat <<-:

	${_W}         ${_R}\|/${_z}
	${_W}        .${_R}-${_Y}*${_R}-${_z}
	${_W}       / ${_R}/|\ ${_z}
	${_w}      _${_W}L${_w}_     ${_z}
	${_w}    ,"   ".   ${_z}
	${_w}   /       \  ${_z}  Now that's what I call failing with style!
	${_w}  |         | ${_z}
	${_w}   \       /  ${_z}
	${_w}    \.___,/   ${_z}

	:
	_tutr_pressenter
}



man_man_prologue() {
	cat <<-:
	When you know a command's name, you can easily access its man page.
	For example, $(cmd man less) is a good way to learn about the options $(cmd less)
	accepts.  However, if you're unsure of a command's name and want to
	explore available programs, searching by name just isn't possible.

	What you need is a way to perform a $(bld keyword) search across all of the
	manuals on your system.  Luckily, $(cmd man) can do that!

	The $(cmd man) command itself has a manual page.  Read it and look for a
	$(bld short option) that is equivalent to a program called "$(cmd apropos)" (whatever
	$(bld that) is... looks pretty Frenchy to me).

	Recall that a $(bld SHORT OPTION) is a dash '$(cmd -)' followed by one character.

	Be prepared to scroll down a few screens.

	When you find that option, run it and search for the keyword $(bld manual),
	like this:
	  $(cmd man __ manual)
	:
}

man_man_test() {
	_LITERALLY=99
	_ALMOST=98
	_READ_MANUAL=97
	_MAN_WRONG_KEYWORD=96
	_MANDB_NOT_BUILT=95

	[[ ${_CMD[0]} = man && ${_CMD[1]} = "-k" && ${_CMD[2]} != manual ]] && return $_MAN_WRONG_KEYWORD
	# Exit status 16 according to `man(1)`:
	# 16     At least one of the pages/files/keywords didn't exist or wasn't matched.
	[[ ${_CMD[@]} = 'man -k manual' && $_RES == 16 ]] && return $_MANDB_NOT_BUILT
	[[ "${_CMD[@]}" == "man man" ]] && return $_READ_MANUAL
	_tutr_noop && return $NOOP
	[[ "${_CMD[@]}" == "man __ manual" ]] && return $_LITERALLY
	[[ "${_CMD[@]}" == "man -f manual" ]] && return $_ALMOST
	[[ "${_CMD[@]}" == "apropos manual" ]] && return 0
	_tutr_generic_test -c man -a -k -a manual
}

man_man_hint() {
	case $1 in
		$NOOP)
			;;

		$_READ_MANUAL)
			cat <<-:
			Did you find what you are looking for?  Let's find out!

			Run $(cmd man) with the option that performs a keyword search for "$(bld manual)".
			:
			;;

		$_LITERALLY)
			_tutr_pressenter
			cat <<-:

			Do you always take instructions this literally?

			I am not asking you to run this exact command:
			  $(cmd man __ manual)

			The $(cmd __) is a blank for you to fill in with an option that is
			equivalent to a command called $(cmd apropos).

			Read $(cmd man)'s manual and find that option.
			:
			;;

		$_ALMOST)
			_tutr_pressenter
			cat <<-:

			That was a $(bld really) good guess, but not the option I am looking for.

			The $(cmd "-f") option you find makes $(cmd man) behave like the $(cmd whatis) program.

			Instead, look for an option that makes $(cmd man) act like the $(cmd apropos) command.

			Back to the manual!
			:
			;;

		$_MAN_WRONG_KEYWORD)
			cat <<-:
			So close!  You even found the $(cmd "-k") option!

			What you just ran,
			  $(cmd ${_CMD[@]})
			is given as an example of $(cmd man)'s keyword search feature (get it?
			$(cmd -k) is for "$(cmd k)eyword").

			:

			if [[ -n ${_CMD[2]} ]]; then
				cat <<-:
				Try that again, but use $(cmd manual) as the keyword instead of
				$(cmd ${_CMD[2]})
				:
			else
				cat <<-:
				Try that again, but provide a keyword as the second argument instead
				of leaving it blank
				:
			fi
			;;

		$_MANDB_NOT_BUILT)
			_tutr_pressenter
			cat <<-:

			I'm sorry this has happened.  It appears that your manual's index is
			incomplete.  Rebuild it right now by running $(cmd sudo mandb) and try
			this step again.

			If this error persists, reach out to $_EMAIL for help.
			:
			;;

		*)
			_tutr_generic_hint $1 man

			cat <<-:

			Go back into the $(cmd man) command's manual and look again.  The option you
			are looking for is equivalent to another command named "$(bld apropos)".
			:
			;;
	esac
}

man_man_epilogue() {
	if [[ "${_CMD[@]}" == "apropos manual" ]]; then
		_tutr_pressenter
		local bleu=$'\x1b[44m'
		local blanc=$'\x1b[47m'
		local rouge=$'\x1b[41m'
		cat <<-:
		${_y}             .${_z}
		${_y}             |~${_z}
		${_y}            /|\\    ${_W} Vous plaisantez j'espère? Tu es un francophone?${_z}
		${_y}           |-.-|    ${_W}                  Merveilleux!${_z}
		${_y}           '-:-'
		${_y}            [|]       ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}            [|]       ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}            [|]       ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}            [|]       ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}            [|]       ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}           .[|].      ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}           :/|\:      ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}           [/|\]      ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}           [/|\]      ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}         .:_#|#_:.    ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}         |_ '-' _|    ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}         /\:-.-:/\    ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}        /\|_[|]_|/\   ${bleu}                ${blanc}                ${rouge}                ${_z}
		${_y}      _/\|~ [|] ~|/\_${_z}
		${_y}      [''=-.[|].-='']${_z}
		${_y}      :-._   |   _.-:${_z}
		${_y}      //\;::-:-::;/\\${_z}
		${_y}     /\.'-\\\\/|\//-'./\\${_z}
		${_y}   .'\/'   :\|/:   '\/'.${_z}
		${_y} .//\('    [\|/]    ')/\\\\.${_z}
		${_y}'':][\.'  .[\|/].  './][:''${_z}
		${_y}    ''    :/\|/\:    ''${_z}
		${_y}         .[\/|\/].${_z}
		${_y}           '.|.'${_z}
		${_y}             '${_z}
		:

	fi

	_tutr_pressenter

	if [[ "${_CMD[@]}" != "apropos manual" ]]; then
		cat <<-:

		Excellent!
		:
	fi

	cat <<-:

	Each line of output is the title of a man page that involves the keyword
	$(bld manual), plus a brief description of that command.

	The numbers in parentheses (e.g. $(bld "(1)"), $(bld "(3)"), $(bld "(8)")) tells you which section
	(i.e. chapter) of the manual that page belongs to.  The sections are
	arranged topically as follows:

	:

	if [[ $_PLAT == Apple ]]; then
		cat <<-:
		 1. General Commands Manual
		 2. System Calls Manual
		 3. Library Functions Manual
		 4. Kernel Interfaces Manual
		 5. File Formats Manual
		 6. Games Manual
		 7. Miscellaneous Information Manual
		 8. System Manager's Manual
		 9. Kernel Developer's Manual

		:
	else
		cat <<-:
		 1  Executable programs or shell commands
		 2  System calls (functions provided by the kernel)
		 3  Library calls (functions within program libraries)
		 4  Special files (usually found in /dev)
		 5  File formats and conventions, e.g. /etc/passwd
		 6  Games
		 7  Miscellaneous (including macro packages and conventions),
		    e.g. man(7), groff(7), man-pages(7)
		 8  System administration commands (usually only for root)
		 9  Kernel routines [Non standard]

		:
	fi

	_tutr_pressenter
	cat <<-:

	$(cmd man -k) (or the equivalent $(cmd apropos) command if you're feeling fancy)
	is a quick replacement for $(_Google) when you don't quite know which
	command you are looking for.

	As I said before, the biggest advantage man pages have over $(_Google) is
	that $(cmd man -k) $(bld knows) which commands are installed on this very computer.
	That's something that $(_Google) (probably) doesn't know.

	:
	_tutr_pressenter
}




epilogue() {
	cat <<-EPILOGUE
	And that wraps up Lesson #1.  In this lesson you have learned how to:

	 * Write and run even more complicated commands
	 * Use the $(cmd less) pager to read large documents in the terminal
	 * Learn the difference between $(bld arguments) and $(bld options)
	 * Find out how to get help in the shell

	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}


S=(
	ls
	echo
	cat_es
	cat_mmm
	cat_emts
	cat_i
	less
	indentation_quiz
	man_cat
	cat_n_mmm
	ls_1
	ls_1S
	ls_1t
	ls_1tr
	man_fail
	man_man
)

source main.sh && _tutr_begin ${S[@]}


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
