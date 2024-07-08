#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=30

# Put tutorial library files into $PATH
PATH=$PWD/.lib:$PATH

source ansi-terminal-ctl.sh
source platform.sh
source progress.sh
_nano() { (( $# == 0 )) && echo $(cyn Nano) || echo $(cyn $*) ; }
_py() { (( $# == 0 )) && echo $(grn Python) || echo $(grn $*) ; }
if [[ -n $_TUTR ]]; then
	source editors+viewers.sh
	source generic-error.sh
	source noop.sh
	source open.sh
	_junk() { (( $# == 0 )) && echo $(red JUNK) || echo $(red $*); }
	_md() { (( $# == 0 )) && echo $(blu MARKDOWN) || echo $(blu $*) ; }
	_txt() { (( $# == 0 )) && echo $(ylw TEXT) || echo $(ylw $*); }
	_code() { (( $# == 0 )) && echo $(cyn code) || echo $(cyn $*); }
	_duckie() { (( $# == 0 )) && echo $(ylw DuckieCorp) || echo $(ylw $*) ; }
fi


# git hash-object FILENAME
README_HSH="e6035bcf89ae32931dfa43595921d44a0759df01"
PLAN_HSH="1f04f36fbf3bbc71ef8e701565ff6692af6c8902"
SIG_HSH="9c84522e22b254d9b1f5743e922c411f138de5eb"
MAIN_HSH="cda181d43b66461abde44f792d4f82cce28b41e5"

_python3_not_found() {
	cat <<-PNF
	I could not find a $(_py Python 3) interpreter on your computer.
	It is required for this lesson.

	Contact $_EMAIL for help
	PNF
}

_nano_not_found() {
	cat <<-NNF
	I could not find the $(_nano) editor on your computer.

	You need a text editor for this lesson.  When this lesson refers to
	$(_nano), you may use your preferred editor instead.

	NNF
}

_mac_keyboard_shortcut_setting_msg() {
	cat <<-:
	It appears that you are using a Mac.  There is a setting that you need
	to enable in your Terminal App before starting this lesson.

	$(ylw If you have already done this, you can ignore this message.)

	This setting makes your $(kbd Option) key usable in the shell.
	Follow these steps to achieve the proper configuration:

	*   Open the $(blu Terminal) menu and select $(blu Settings...)
	*   Select the $(blu Profiles) page
	*   Select the $(blu Keyboard) tab
	*   Check the option $(blu Use Option as Meta Key) near the bottom

	:
	_tutr_pressenter
}

create_files() {
	cat <<-TEXT > "$_BASE/main.py"
	import sys

	def main(args):
	    if len(args) == 0:
	        print("Usage: main.py FILE...")
	        sys.exit(1)

	    for filename in args:
	        f = open(filename)
	        print(f.read())
	        f.close()

	def return_one():
	    return 1

	def return_two():
	    return 2

	def return_true():
	    return True

	def return_false():
	    return True

	if __name__ == '__main__':
	    main(sys.argv[1:])
	TEXT


	cat <<-TEXT > "$_BASE/runTests.py"
	import unittest, sys
	from Testing import test_numbers, test_booleans

	suite = unittest.TestSuite()

	for test in (test_numbers.TestNumbers, test_booleans.TestBooleans):
	    suite.addTest(unittest.makeSuite(test))

	runner = unittest.TextTestRunner(verbosity=2)
	if not runner.run(suite).wasSuccessful():
	    sys.exit(1)
	TEXT


	cat <<-TEXT > "$_BASE/test_booleans.py"
	import unittest
	import main

	class TestBooleans(unittest.TestCase):
	    def test_true(self):
	        self.assertTrue(main.return_true())

	    def test_false(self):
	        self.assertFalse(main.return_false())

	if __name__ == '__main__':
	    unittest.main()
	TEXT


	cat <<-TEXT > "$_BASE/test_numbers.py"
	import unittest
	import main

	class TestNumbers(unittest.TestCase):
	    def test_one(self):
	        self.assertEqual(main.return_one(), 1)

	    def test_two(self):
	        self.assertEqual(main.return_two(), 2)

	if __name__ == '__main__':
	    unittest.main()
	TEXT

	cat <<-TEXT > "$_BASE/README.md"
	# Welcome to the Nano text editor!

	Nano is a user-friendly editor with a simple interface.  You will find
	hints at the bottom of the screen for the most common commands.
	This is how Nano describes its shortcut keys:

	*   "^"  means "Control"
	    Example: ^K means "press Ctrl+K"
	TEXT

	if [[ $_OS == MacOSX ]]; then
		cat <<-TEXT >> "$_BASE/README.md"
		*   "M-" stands for the "Meta" key, which corresponds to "Option" on your
		    keyboard.
		    Example: M-U means "press Option+U"
		    *   You must have enabled the 'Use Option as Meta Key' setting in the
		        Terminal App for this to work!
		TEXT
	else
		cat <<-TEXT >> "$_BASE/README.md"
		*   "M-" stands for the "Meta" key, which corresponds to "Alt" on your
		    keyboard.
		    Example: M-U means "press Alt+U"
		TEXT
	fi

	cat <<-TEXT >> "$_BASE/README.md"

	Your mouse does not work in here :(
	Use the arrow keys to move the cursor and scroll up and down.

	Besides Nano, there are other popular text editors such as Vim and
	Emacs.  While most developers prefer to work in an IDE, it is not
	uncommon for others to work exclusively in a text editor.  You can use
	your preferred editor in this class (and in this lesson).  If you do not
	already have a strong preference, Nano is fine.

	Use your editor to complete the following tasks:

	0.  Write your A-Number somewhere in this file.  Your A-Number should begin
	    with a capital 'A' and be followed by eight digits.  Write it as a
	    free-standing word that is not connected to other text.
	1.  Delete this line of text that mentions Brown M&M's.  There is a hint at
	    the bottom of Nano that shows a command that will delete an entire line
	    of text in one stroke.
	2.  Exit your editor, saving your changes to this file as you leave.
	    Nano shows the Exit command in a hint at the bottom of the screen.
	    *   When you exit Nano you will be asked "Save modified buffer?".
	        "Buffer" is the name for text on the screen before it is written to
	        a file on the disk.  Press 'y' to answer this question.
	    *   You will then be asked "File Name to Write" with a suggestion of
	        "README.md".  This is how you perform a "Save As..." in Nano.
	        Hit "Enter" to leave this filename as "README.md"
	TEXT

	cat <<-TEXT > "$_BASE/data0.txt"
	# This is some data for the Python script to use
	n,a(n)
	0,0
	1,1
	2,4
	3,9
	4,16
	5,25
	6,36
	7,49
	8,64
	9,81
	10,100
	11,121
	12,144
	13,169
	14,196
	15,225
	16,256
	17,289
	18,324
	19,361
	20,400
	21,441
	22,484
	23,529
	24,576
	25,625
	TEXT

	cat <<-TEXT > "$_BASE/data1.txt"
	# This is some data for the Python script to use
	n,a(n)
	0,0
	1,1
	2,8
	3,27
	4,64
	5,125
	6,216
	7,343
	8,512
	9,729
	10,1000
	11,1331
	12,1728
	13,2197
	14,2744
	15,3375
	16,4096
	17,4913
	18,5832
	19,6859
	20,8000
	21,9261
	22,10648
	23,12167
	24,13824
	25,15625
	TEXT

	cat <<-TEXT > "$_BASE/song.mp3"
	This file is junk and should be deleted
	TEXT

	cat <<-TEXT > "$_BASE/image.png"
	This file is junk and should be deleted
	TEXT

	cat <<-TEXT > "$_BASE/movie.mkv"
	This file is junk and should be deleted
	TEXT

	cat <<-'TEXT' > "$_BASE/Plan.md"
	# Software Development Plan

	## Phase 0: Requirements Analysis (tag name `analyzed`)
	*(20% of your effort)*

	**Important - do not change the code in this phase**

	Deliver:

	*   [ ] Re-write the instructions in your own words.
	    *   If you don't do this, you won't know what you're supposed to do!
	    *   Don't leave out details!
	*   [ ] Explain the problem this program aims to solve.
	    *   Describe what a *good* solution looks like.
	    *   List what you already know how to do.
	    *   Point out any challenges that you can foresee.
	*   [ ] List all of the data that is used by the program, making note of where it comes from.
	    *   Explain what form the output will take.
	*   [ ] List the algorithms that will be used (but don't write them yet).


	## Phase 1: Design (tag name `designed`)
	*(30% of your effort)*

	**Important - do not change the code in this phase**

	Deliver:

	*   [ ] Function signatures that include:
	    *   Descriptive names.
	    *   Parameter lists.
	    *   Documentation strings that explain its purpose and types of inputs and outputs.
	*   [ ] Pseudocode that captures how each function works.
	    *   Pseudocode != source code.  Do not paste your finished source code into this part of the plan.
	*   Explain what happens in the face of good and bad input.
	    *   Write a few specific examples that occur to you, and use them later when testing.


	## Phase 2: Implementation (tag name `implemented`)
	*(15% of your effort)*

	**Finally, you can write code!**

	Deliver:

	*   [ ] More or less working code.
	*   [ ] Note any relevant and interesting events that happened while you wrote the code.
	    *   e.g. things you learned, things that didn't go according to plan.
	*   [ ] **Tag** the last commit in this phase `implemented` and push it to GitLab.


	## Phase 3: Testing and Debugging (tag name `tested`)
	*(30% of your effort)*

	Deliver:

	*   [ ] A set of test cases that you have personally run on your computer.
	    *   Include a description of what happened for each test case.
	    *   For any bugs discovered, describe their cause and remedy.
	    *   Write your test cases in plain language such that a non-coder could run them and replicate your experience.
	*   [ ] **Tag** the last commit in this phase `tested` and push it to GitLab.


	## Phase 4: Deployment (tag name `deployed`)
	*(5% of your effort)*

	Deliver:

	*   [ ] **Tag** the last commit in this phase `deployed` and push it to GitLab.
	*   [ ] Your repository is pushed to GitLab.
	*   [ ] **Verify** that your final commit was received by browsing to its project page on GitLab.
	    *   Ensure the project's URL is correct.
	    *   Look for all of the tags in the **Tags** tab.
	    *   Review the project to ensure that all required files are present and in correct locations.
	    *   Check that unwanted files have not been included.
	    *   Make any final touches to documentation, including the Sprint Signature and this Plan.
	*   [ ] **Validate** that your submission is complete and correct by cloning it to a new location on your computer and re-running it.
	    *    Run your program from the command line so you can see how it will behave when your grader runs it.  **Running it in PyCharm is not good enough!**
	    *   Run through your test cases to avoid nasty surprises.
	    *   Check that your documentation files are all present.


	## Phase 5: Maintenance

	Spend a few minutes writing thoughtful answers to these questions.  They are meant to make you think about the long-term consequences of choices you made in this project.

	Deliver:

	*   [ ] Write brief and honest answers to these questions:
	    *   What parts of your program are sloppily written and hard to understand?
	        *   Are there parts of your program which you aren't quite sure how/why they work?
	        *   If a bug is reported in a few months, how long would it take you to find the cause?
	    *   Will your documentation make sense to...
	        *   ...anybody besides yourself?
	        *   ...yourself in six month's time?
	    *   How easy will it be to add a new feature to this program in a year?
	    *   Will your program continue to work after upgrading...
	        *   ...your computer's hardware?
	        *   ...the operating system?
	        *   ...to the next version of Python?
	*   [ ] Make one final commit and push your **completed** Software Development Plan to GitLab.
	*   [ ] Respond to the **Assignment Reflection Survey** on Canvas.
	TEXT

	cat <<-TEXT > "$_BASE/Signature.md"
	*TODO: Replace the example entries with your own*

	| Date        | Time Spent | Events
	|-------------|------------|--------------------
	| Nocember 19 | 1 hour     | Lorem ipsum dolor sit amet, consectetur adipiscing elit.
	| Nocember 20 | 0.75 hours | Itaque hic ipse iam pridem est reiectus.
	| Nocember 21 | 1.25 hours | Restinguet citius, si ardentem acceperit.
	| Nocember 22 | 2.5 hours  | Quid de Platone aut de Democrito loquar.
	| Nocember 23 | 0.25 hours | Istic sum, inquit. Quae in controversiam veniunt, de iis, si placet, disseramus.
	| Nocember 24 | 0 hours    | Id mihi magnum videtur. Eid, Pmurt, Eid. Maximus dolor, inquit, brevis est.
	| Nocember 25 | 3 hours    | Multoque hoc melius nos veriusque quam Stoici.
	| Nocember 26 | 2.25 hours | Rhetorice igitur, inquam, nos mavis quam dialectice disputare.
	| Nocember 27 | 1.5 hours  | Suo genere perveniant ad extremum; Quod quidem nobis non saepe contingit.
	| TOTAL       | 12.5 hours | *Your TOTAL should agree with your daily entries*
	TEXT

	cat <<-TEXT > "$_BASE/Instructions.md"
	# CS 1440 Assignment 0 Instructions

	## Description

	In this assignment you will write your own versions of classic Unix
	text-processing programs.  The tools you write for this assignment are
	not intended to be perfect clones of the programs they are mimicking.  I
	have relaxed requirements that your code should meet.

	This assignment is essentially a re-implementation of simple Unix
	text-processing programs in Python.  Each tool will be a Python function
	which takes as input a list of arguments supplied by the user from the
	command line.
	TEXT

	cat <<-TEXT > "$_BASE/Rubric.md"
	# CS 1440 Assignment 1 Rubric

	| Points | Criteria
	|:------:|--------------------------------------------------------------------------------
	| 5      | Eligible error messages are displayed with 'usage()'<br/> Errors that can reasonably be detected by your code are reported with 'usage()'<br/> others are left to Python's error reporting
	| 10     | cat & tac
	| 10     | head & tail
	| 10     | wc
	| 10     | grep
	| 10     | sort
	| 15     | cut
	| 15     | paste

	**Total points: 85**
	TEXT

}




setup() {
	source screen-size.sh 80 30
	export _BASE="$PWD/lesson4"
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	mkdir -p "$_BASE"

	source assert-program-exists.sh
	_tutr_warn_if_program_missing nano _nano_not_found

	if   which python &>/dev/null && [[ $(python -V 2>&1) = "Python 3"* ]]; then
		export _PY=python
	elif which python3 &>/dev/null && [[ $(python3 -V 2>&1) = "Python 3"* ]]; then
		export _PY=python3
	else
		_tutr_die _python3_not_found
    fi

	create_files
}




prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #4: Working in Projects

	In this lesson you will learn how to

	* Create and edit text files with the $(_nano) editor
	* Organize files into directories
	* Follow the $(_duckie) standard project structure
	* Run unit tests and interpret their results
	* Write project documentation

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



# nano README.md
nano_readme_pre() {
	if [[ $_OS == MacOSX ]]; then
		_tutr_warn _mac_keyboard_shortcut_setting_msg
	fi
}

nano_readme_prologue() {
	cat <<-:
	$(_nano) is a small and friendly text editor.  $(_nano) can edit any program
	regardless of the language it is written in.  This is in contrast to
	PyCharm, which is an Integrated Development Environment (IDE).
	PyCharm's text editor is just a small part of a larger tool and
	specializes in authoring $(_py) code, plus a few related languages.

	The majority of professionals in the industry use an IDE like PyCharm
	exclusively.  However, there are tasks for which a simple text editor
	like $(_nano) are more appropriate.  Additionally, $(_nano) is already installed
	on any workstations and servers that you will use in your job.  When you
	learn $(_nano) you are at home on $(bld any) computer.

	:

	_tutr_pressenter

	cat <<-:

	The syntax for running $(_nano) from the command line is
	  $(cmd "nano [FILENAME]...")

	This means that $(cmd nano) can take 0 or more filenames as arguments.
	The files $(bld DO NOT) need to already exist to open them with $(_nano)!

	$(bld Example:) edit the file $(path Signature.md)
	  $(cmd nano Signature.md)

	$(bld Example:) open to a fresh, empty file and choose its name when you save
	  $(cmd nano)

	Open $(path README.md) in $(_nano) and $(bld follow the instructions found therein).
	You will move on to the next step when $(path README.md) has been changed
	appropriately.
	:
}

_T=0
_F=1


nano_readme_rw() {
	# remove A number
	sed -i -e 's/A[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]//g' "$_BASE/README.md"

	# restore brown M&Ms
	echo "* Delete this line of text that mentions Brown M&M's.  There is a hint" >>  "$_BASE/README.md"
}

nano_readme_ff() {
	# add A number
	echo A01234567 >> "$_BASE/README.md"

	# remove brown M&Ms
	sed -i -e '/Brown M&M/d' "$_BASE/README.md"
}

nano_readme_test() {
	_README_UNCHANGED=97
	_ANUM_MISSING=99
	_ANUM_LOWERCASE=96
	_BROWN_MMS_STILL_THERE=98
	_OPENED_SIGNATURE=95

	if   [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ $(git hash-object "$_BASE/README.md") = $README_HSH ]]; then
		# The safe way to access last element in an array
		if [[ -n $_CMD && "${_CMD[${#_CMD[@]}-1]}" == Signature.md ]]; then return $_OPENED_SIGNATURE
		else return $_README_UNCHANGED
		fi
	fi

	egrep -qw 'A[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' "$_BASE/README.md" >/dev/null
	_HAS_ANUM=$?
	grep -q "Brown M&M's" "$_BASE/README.md" >/dev/null
	_BROWN_MMS=$?
	egrep -qw 'a[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' "$_BASE/README.md" >/dev/null
	_LOWERCASE_ANUM=$?

	if   (( $_LOWERCASE_ANUM == $_T )); then return $_ANUM_LOWERCASE
	elif (( $_HAS_ANUM == $_T && $_BROWN_MMS == $_F )); then return 0
	elif (( $_HAS_ANUM == $_F )); then return $_ANUM_MISSING
	elif (( $_BROWN_MMS == $_T )); then return $_BROWN_MMS_STILL_THERE
	else return $WRONG_CMD
	fi
}

nano_readme_hint() {
	case $1 in

		$_OPENED_SIGNATURE)
			cat <<-:
			You opened $(path Signature.md)?

			That was just an example of how you $(bld might) run $(_nano).
			:
			;;

		$_README_UNCHANGED)
			cat <<-:
			$(path README.md) is unchanged.

			Were you able to save your changes in your editor?

			Start by writing your A-Number in the file.  It should be a
			capital $(mgn "'A'") followed by eight digits.

			:
			;;

		$_ANUM_LOWERCASE)
			cat <<-:
			You didn't write your A-Number with a lower-case $(mgn "'A'"), did you?

			:
			;;

		$_ANUM_MISSING)
			cat <<-:
			Start by writing your A-Number in the file.  Remember, I'm
			looking for a capital $(mgn "'A'") followed by $(mgn eight digits).

			:
			;;

		$_BROWN_MMS_STILL_THERE)
			cat <<-:
			Delete the line of text from $(path README.md) that mentions Brown M&M's.

			Put the cursor on that line and execute the $(bld Cut Text) command.

			:
			;;

		$WRONG_CMD)
			cat <<-:
			$(cmd "${_CMD[0]}") wasn't the right command to run at this time.

			:
			;;
		*)
			_tutr_generic_hint $1 nano "$_BASE"
			;;
	esac

	cat <<-:
	Open $(path README.md) in $(_nano) and $(bld follow the instructions found therein).
	  $(cmd nano README.md)

	You will move on to the next step when $(path README.md) has been changed
	appropriately.
	:
}

nano_readme_epilogue() {
	cat <<-:
	${_Y}        _ _
	${_Y}     .-/ / )
	${_Y}     |/ / /      ${_Z}Nicely done!
	${_Y}     /.' /
	${_Y}    // .---.     ${_C}Nano${_Z} is a handy little program to have on
	${_Y}   /   .--._\\   ${_Z} hand in a pinch, even if it is not your
	${_Y}  /    \`--' /   ${_Z} favorite way to edit text files.
	${_Y} /     .---'
	${_Y}/    .'
	${_Y}    /
	:
    _tutr_pressenter
}



mkdirs_rw() {
	rmdir "$_BASE/src/Testing/" "$_BASE/src/" "$_BASE/doc/" "$_BASE/data/" "$_BASE/instructions/" "$_BASE/junk/"
}

mkdirs_ff() {
	mkdir -p "$_BASE/src/Testing/" "$_BASE/doc/" "$_BASE/data/" "$_BASE/instructions/" "$_BASE/junk/"
}

# mkdir to create necessary dirs + junk/
mkdirs_prologue() {
	cat <<-:
	For each assignment in this class I will give you starter code that is
	organized in a standard way.  Except for $(bld this) directory; here there are
	a bunch of disorganized files.

	To teach you how the starter code will be organized and to give you more
	practice with commands learned in previous lessons, you will sort these
	files into their proper locations.

	Use as many commands as needed to create these new directories:

	  * $(path src/)
	  * $(path src/Testing/)
	  * $(path doc/)
	  * $(path data/)
	  * $(path instructions/)
	  * $(path junk/)

	Unfortunately, since these directories do not yet exist, $(bld tab completion)
	can't help you.
	:
}

mkdirs_test() {
	_SRC=99
	_DOC=98
	_DAT=97
	_JNK=96
	_TST=95
	_INS=94

	if   [[ -d "$_BASE/src"
		&& -d "$_BASE/src/Testing"
		&& -d "$_BASE/doc"
		&& -d "$_BASE/data"
		&& -d "$_BASE/junk"
		&& -d "$_BASE/instructions" ]]; then return 0
	elif _tutr_noop rmdir; then return $NOOP
	elif [[ ! -d "$_BASE/src" ]]; then return $_SRC
	elif [[ ! -d "$_BASE/src/Testing" ]]; then return $_TST
	elif [[ ! -d "$_BASE/doc" ]]; then return $_DOC
	elif [[ ! -d "$_BASE/data" ]]; then return $_DAT
	elif [[ ! -d "$_BASE/instructions" ]]; then return $_INS
	elif [[ ! -d "$_BASE/junk" ]]; then return $_JNK
	else _tutr_generic_test -c mkdir -d "$_BASE"
	fi
}

mkdirs_hint() {
	case $1 in
		$_SRC) echo "You need to make $(path src/)" ;;
		$_DOC) echo "It seems that you lack the subdirectory $(path doc/)" ;;
		$_DAT) echo "Make the $(path data/) subdirectory" ;;
		$_JNK) echo "Now you need a place for the $(path junk/) files" ;;
		$_TST) echo "$(path src/Testing/) will be a subdirectory under $(path src)" ;;
		$_INS) echo "I can't find the subdirectory $(path instructions/).  Make it next." ;;
		*) _tutr_generic_hint $1 mkdir $_BASE ;;
	esac
}



# use cp, rm & mv to sort files into their correct locations
sort_files_rw() {
	rm -rf "$_BASE/src/Testing/" "$_BASE/src/" "$_BASE/doc/" "$_BASE/data/" "$_BASE/instructions/" "$_BASE/junk/"
	mkdir -p "$_BASE/src/Testing/" "$_BASE/doc/" "$_BASE/data/" "$_BASE/instructions/" "$_BASE/junk/"
	create_files
}

sort_files_ff() {
	cd "$_BASE"
	mv test_*.py src/Testing
	mv *.py src
	mv Plan.md Signature.md doc
	mv *.md instructions
	mv *.txt data
	mv movie.mkv image.png song.mp3 junk
}

sort_files_prologue() {
	cat <<-:
	Next, sort the files into their proper locations.

	  * $(_py .py) files with names beginning with $(_py test_) go in $(path src/Testing/)
	  * All other $(_py .py) files go under $(path src/)
	  * $(_md Plan.md) and $(_md Signature.md) belong in $(path doc/)
	  * $(_md README.md), $(_md Instructions.md) and $(_md Rubric.md) go in $(path instructions/)
	  * $(_txt .txt) files go in $(path data/)
	  * Move $(_junk "anything else that doesn't fit") into $(path junk/)

	Use the commands $(cmd rm) and $(cmd mv) to put everything into place.  If you
	accidentally delete the wrong file or otherwise get stuck there are two
	ways to fix it:

	  * Run the $(cmd create_files) command to re-create all files; you may need to
	    erase some duplicate files if you do this
	  * Exit and then re-start this lesson

	Don't forget to save some keystrokes with $(bld tab completion)!
	:
}

sort_files_test() {
	_MAIN_NO_SRC=99
	_RUNTESTS_NO_SRC=98
	_BOOL_NO_SRCTST=97
	_NUMS_NO_SRCTST=96
	_PLAN_NO_DOC=95
	_README_NO_INSTRS=94
	_DAT0_NO_DAT=93
	_DAT1_NO_DAT=92
	_SONG_NO_JUNK=91
	_MOVIE_NO_JUNK=90
	_IMAGE_NO_JUNK=89
	_RUBRIC_NO_INS=88
	_INSTRS_NO_INS=87
	_MAIN_IN_SRCTST=86
	_RUNTESTS_IN_SRCTST=85
	_BOOL_IN_SRC=84
	_NUMS_IN_SRC=83
	_RUBRIC_IN_DOC=82
	_INSTRS_IN_DOC=81
	_PLAN_IN_INSTRS=80
	_README_IN_DOC=79
	_SIG_NO_DOC=78
	_SIG_IN_INSTRS=77

	if   [[ -f "$_BASE/src/main.py" \
		&& -f "$_BASE/src/runTests.py" \
		&& -f "$_BASE/src/Testing/test_booleans.py" \
		&& -f "$_BASE/src/Testing/test_numbers.py" \
		&& -f "$_BASE/doc/Plan.md" \
		&& -f "$_BASE/doc/Signature.md" \
		&& -f "$_BASE/instructions/README.md" \
		&& -f "$_BASE/instructions/Rubric.md" \
		&& -f "$_BASE/instructions/Instructions.md" \
		&& -f "$_BASE/data/data0.txt" \
		&& -f "$_BASE/data/data1.txt" \
		&& -f "$_BASE/junk/song.mp3" \
		&& -f "$_BASE/junk/movie.mkv" \
		&& -f "$_BASE/junk/image.png" \
		]]; then return 0
	elif _tutr_noop cd pushd popd create_files; then return $NOOP
	elif [[ $_RES == 127 ]]; then _tutr_generic_test -c mv -x
	elif [[ $PWD != $_BASE ]]; then return $WRONG_PWD

	elif [[   -f "$_BASE/src/Testing/main.py" ]]; then return $_MAIN_IN_SRCTST
	elif [[ ! -f "$_BASE/src/main.py" ]]; then return $_MAIN_NO_SRC

	elif [[   -f "$_BASE/src/Testing/runTests.py" ]]; then return $_RUNTESTS_IN_SRCTST
	elif [[ ! -f "$_BASE/src/runTests.py" ]]; then return $_RUNTESTS_NO_SRC

	elif [[   -f "$_BASE/src/test_booleans.py" ]]; then return $_BOOL_IN_SRC
	elif [[ ! -f "$_BASE/src/Testing/test_booleans.py" ]]; then return $_BOOL_NO_SRCTST

	elif [[   -f "$_BASE/src/test_numbers.py" ]]; then return $_NUMS_IN_SRC
	elif [[ ! -f "$_BASE/src/Testing/test_numbers.py" ]]; then return $_NUMS_NO_SRCTST

	elif [[   -f "$_BASE/instructions/Plan.md" ]]; then return $_PLAN_IN_INSTRS
	elif [[ ! -f "$_BASE/doc/Plan.md" ]]; then return $_PLAN_NO_DOC

	elif [[   -f "$_BASE/instructions/Signature.md" ]]; then return $_SIG_IN_INSTRS
	elif [[ ! -f "$_BASE/doc/Signature.md" ]]; then return $_SIG_NO_DOC

	elif [[   -f "$_BASE/doc/README.md" ]]; then return $_README_IN_DOC
	elif [[ ! -f "$_BASE/instructions/README.md" ]]; then return $_README_NO_INSTRS

	elif [[   -f "$_BASE/doc/Rubric.md" ]]; then return $_RUBRIC_IN_DOC
	elif [[ ! -f "$_BASE/instructions/Rubric.md" ]]; then return $_RUBRIC_NO_INS

	elif [[   -f "$_BASE/doc/Instructions.md" ]]; then return $_INSTRS_IN_DOC
	elif [[ ! -f "$_BASE/instructions/Instructions.md" ]]; then return $_INSTRS_NO_INS

	elif [[ ! -f "$_BASE/data/data0.txt" ]]; then return $_DAT0_NO_DAT
	elif [[ ! -f "$_BASE/data/data1.txt" ]]; then return $_DAT1_NO_DAT
	elif [[ ! -f "$_BASE/junk/song.mp3" ]]; then return $_SONG_NO_JUNK
	elif [[ ! -f "$_BASE/junk/movie.mkv" ]]; then return $_MOVIE_NO_JUNK
	elif [[ ! -f "$_BASE/junk/image.png" ]]; then return $_IMAGE_NO_JUNK
	else _tutr_generic_test -c mv -x -d "$_BASE"
	fi
}

sort_files_hint() {
	case $1 in
		$_MAIN_NO_SRC) echo "Now move $(_py main.py) under $(path src/)" ;;
		$_RUNTESTS_NO_SRC) echo "$(_py runTests.py) should go under $(path src/)" ;;
		$_BOOL_NO_SRCTST) echo "Now move $(_py test_booleans.py) into $(path src/Testing/)" ;;
		$_NUMS_NO_SRCTST) echo "Now move $(_py test_numbers.py) to $(path src/Testing/)" ;;
		$_PLAN_NO_DOC) echo "Now move $(_md Plan.md) to $(path doc/)" ;;
		$_README_NO_INSTRS) echo "Now move $(_md README.md) into $(path instructions/)" ;;
		$_DAT0_NO_DAT) echo "$(_txt data0.txt) should go into $(path data/)" ;;
		$_DAT1_NO_DAT) echo "$(_txt data1.txt) belongs in $(path data/)" ;;
		$_SONG_NO_JUNK) echo "$(_junk song.mp3) seems like $(path junk/)" ;;
		$_MOVIE_NO_JUNK) echo "$(_junk movie.mkv) is a junk file" ;;
		$_IMAGE_NO_JUNK) echo "$(_junk image.png) is another junk file" ;;
		$_RUBRIC_NO_INS) echo "$(_md Rubric.md) goes in $(path instructions/)" ;;
		$_INSTRS_NO_INS) echo "$(_md Instructions.md) belongs under $(path instructions/)" ;;
		$_MAIN_IN_SRCTST) echo "$(_py main.py) should be under $(path src/), not $(path src/Testing/)" ;;
		$_RUNTESTS_IN_SRCTST) echo "$(_py runTests.py) should be under $(path src/), not $(path src/Testing/)" ;;
		$_BOOL_IN_SRC) echo "$(_py test_booleans.py) is supposed to be under $(path src/Testing/), not $(path src/)" ;;
		$_NUMS_IN_SRC) echo "$(_py test_numbers.py) is supposed to be under $(path src/Testing/), not $(path src/)" ;;
		$_RUBRIC_IN_DOC) echo "You put $(_md Rubric.md) under $(path doc/), but it belongs in $(path instructions/)" ;;
		$_INSTRS_IN_DOC) echo "You put $(_md Instructions.md) under $(path doc/), but it belongs in $(path instructions/)" ;;
		$_PLAN_IN_INSTRS) echo "You put $(_md Plan.md) under $(path instructions/), but it belongs in $(path doc/)" ;;
		$_README_IN_DOC) echo "You put $(_md README.md) under $(path doc/), but it belongs in $(path instructions/)" ;;
		$_SIG_NO_DOC) echo "$(_md Signature.md) belongs under $(path doc/)"  ;;
		$_SIG_IN_INSTRS) echo "You put $(_md Signature.md) under $(path instructions/), but it belongs in $(path doc/)" ;;
		*) _tutr_generic_hint $1 mv "$_BASE" ;;
	esac
}



# rm -rf junk/
remove_junk_rw() {
	mkdir "$_BASE/junk"
	touch "$_BASE/junk/song.mp3" "$_BASE/junk/image.png" "$_BASE/junk/movie.mkv"
}

remove_junk_ff() {
	rm -rf "$_BASE/junk"
}

remove_junk_prologue() {
	cat <<-:
	That's better!  A clean project directory prevents confusion.

	Before I delete anything, I like to first move them into a temporary
	$(path junk/) folder so I can be sure of what I'm about to do.

	Unlike the graphical desktop systems you are familiar with, file
	deletion in the Unix shell is $(bld forever).  There is no $(cmd undelete) command
	here.  This extra step is something that I learned years ago to avoid
	disasters.

	Please take one last look at the contents of $(path junk/) before you get
	rid of it.  Then run a command that will permanently wipe $(path junk/) off
	your computer $(bld forever).
	:
}

remove_junk_test() {
	_RAN_BAD_CMD=97
	_RMDIR=98
	_JUNK_NOT_DELETED=99

	if   [[ -n $_BAD_CMD ]]; then return $_RAN_BAD_CMD
	elif [[ ! -d "$_BASE/src" ]]; then
		_BAD_CMD="${_CMD[@]}"
		return $_RAN_BAD_CMD
	elif [[ -d "$_BASE/src" && ! -d "$_BASE/junk" ]]; then return 0
	# if _BASE is NOT a substring of the current dir, then report an error
	elif ! [[ $PWD = $_BASE* ]]; then return $WRONG_PWD
	elif _tutr_noop man cd; then return $NOOP
	elif [[ ${_CMD[0]} = rmdir ]]; then return $_RMDIR
	elif [[ ${_CMD[0]} != rm ]]; then return $WRONG_CMD
	elif [[ -d "$_BASE/junk" ]]; then return $_JUNK_NOT_DELETED
	fi
}

remove_junk_hint() {
	case $1 in
		$_JUNK_NOT_DELETED)
			cat <<-:
			Try using the $(cmd rm) command with the options that cause it to
			forcefully remove all files and subdirectories recursively.

			You can read the manpage for $(cmd rm) if you need a refresher.
			:
			;;

		$_RMDIR)
			cat <<-:
			$(cmd rmdir) isn't the right command for this job.  Try using the $(cmd rm)
			command with the options that cause it to forcefully remove all
			files and subdirectories recursively.

			You can read the manpage for $(cmd rm) if you need a refresher.
			:
			;;

		$_RAN_BAD_CMD)
			cat <<-:
			Whoops, you've accidentally removed the $(path src/) directory!
			You needed that to complete the lesson.

			Quit and re-start this lesson so I can put everything back as it
			was before so you can try again.

			The command which got you into trouble was
			  $(cmd $_BAD_CMD)

			...so, maybe don't do that next time $(red ;-P)
			:
			;;

		*)
			_tutr_generic_hint $1 rm "$_BASE"
			cat <<-:

			Are you ready to get rid of the junk files?

			Run the command that will permanently erase $(path junk/) and its
			contents from the computer.
			:
			;;
	esac
}



# Fix a bug in the Python program so the tests pass
# 	*	Read & update the software dev plan with Nano
# 	*	Edit the code with Python

cd_into_src_rw() {
	cd "$_BASE"
}

cd_into_src_ff() {
	cd "$_BASE/src"
}

cd_into_src_pre() {
	_tutr_open_init  # set value $_OPEN for a later message
}

cd_into_src_prologue() {
	cat <<-:
	Now that all of these files are sorted into their proper directories,
	$(cmd cd) into the $(path src/) directory.

	If desired, you can open a graphical file explorer by running this
	command ($(bld "note the dot at the end!")):
	  $(cmd $_OPEN .)
	:
}

cd_into_src_test() {
	if   [[ "$PWD" == "$_BASE/src" ]]; then return 0
	elif _tutr_noop; then return $NOOP
	else _tutr_generic_test -c cd -a src -d "$_BASE/src"
	fi
}

cd_into_src_hint() {
	_tutr_generic_hint $1 cd "$_BASE/src"
}


run_tests_prologue() {
	cat <<-:
	This directory contains a $(_py) program called $(_py main.py) as well as
	another file named $(_py runTests.py) which performs a set of $(bld unit tests) on
	$(_py main.py) to check for bugs.

	$(_py) programs can be run on the command line by invoking the $(cmd $_PY)
	command with the name of a $(_py) file as its argument:
	  $(cmd $_PY PROGRAM.py)

	See for yourself whether there are any problems in $(_py main.py) by running
	$(_py runTests.py) with the $(cmd $_PY) command.

	If you accidentally enter $(_py "Python's") interactive mode (you'll see $(_py "Python's")
	characteristic $(bld '>>>') prompt) press $(mgn '^D') or run $(_code "exit()") to
	return to $(cyn $_SH).
	:
}

run_tests_test() {
	_ENTERED_REPL=99

	if   _tutr_noop man; then return $NOOP
	elif [[ ${_CMD[@]} = $_PY ]]; then return $_ENTERED_REPL
	else _tutr_generic_test -f -c $_PY -a runTests.py -d "$_BASE/src"
	fi
}

run_tests_hint() {
	case $1 in
		$_ENTERED_REPL)
			cat <<-:
			That wasn't a bad thing to do!  By the end of this class you
			will be as comfortable in $(_py "Python's") interactive mode as you
			are in the shell.

			This time be sure to give $(_py runTests.py) as the argument to the
			$(cmd ${_CMD[0]}) command.
			:
			;;

		$WRONG_ARGS)
			cat <<-:
			The $(_py) program you need to run is called $(_py runTests.py).
			:
			;;
		*)
			_tutr_generic_hint $1 $_PY "$_BASE"

			cat <<-:

			  $(cmd $_PY runTests.py)
			:
			;;
	esac
}

run_tests_epilogue() {
	_tutr_pressenter
	cat <<-:

	WOW!!! That wall of text sure looks scary!

	In time you'll learn to appreciate how detailed this information is.
	All of this output will save you time because it helps you zero in on
	the bugs in your programs.

	Allow me to translate.  $(bld Four) automated tests were run on the program
	$(_py main.py), and $(bld one) test failed.

	When a test fails you are shown:

	0.  The name of the file that contains the failing test
	    $(path ...lesson4/src/Testing/test_booleans.py)
	1.  The line number and function where the failure occurred
	    $(_code line 9, in test_false)
	2.  You are even shown the very line of code that failed
	    $(_code 'self.assertFalse(main.return_false())')
	3.  The exact error is named and explained
	    $(red 'AssertionError: True is not false')

	In other words, a test named $(_code test_false) expected the function
	$(cmd "main.return_false()") to return $(_code False).  Instead, that function
	returned $(_code True).

	Now that you have identified which test failed, you can work to uncover
	the root cause.  This means taking a look at the function $(_code 'return_false()')
	defined in $(_py main.py).

	:
	_tutr_pressenter
}


nano_main_py_prologue() {
	cat <<-:
	Use $(cmd nano) to take a look at $(_py main.py).  Your goal is to find the error
	the automated test is alerting you about.

	$(ylw "!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	$(ylw "!!! DON'T TOUCH ANYTHING !!!")
	$(ylw "!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

	Resist the urge to fix the error.  Leave $(_py main.py) unchanged.
	This is just a recon mission.
	:
}

nano_main_py_test() {
	if   _tutr_noop cd pushd popd; then return $NOOP
	elif [[ "$PWD" != "$_BASE/src" ]]; then return $WRONG_PWD
	elif _tutr_is_editor && [[ ${_CMD[1]} == main.py ]]; then return 0
	else _tutr_generic_test -c nano -a main.py
	fi
}

nano_main_py_hint() {
	_tutr_generic_hint $1 nano "$_BASE/src"
}

nano_main_py_epilogue() {
	# check SHA-1 sum of main.py - if the match fails, say something
	if [[ $(git hash-object "$_BASE/src/main.py") != $MAIN_HSH ]]; then
		cat <<-:
		You just couldn't resist, could you?

		I hope you didn't create $(bld another) problem to fix!

		:
	fi
	cat <<-:
	Now that you found the problem you can make a plan to fix it.

	:
	_tutr_pressenter
}



edit_plan_prologue() {
	cat <<-:
	It is a good habit to document your efforts in a Software Development
	Plan.  As you work on a project over the course of months or years this
	information will serve you and your teammates well.

	A Software Development Plan (SDP) is required for every assignment in
	this class.  I'll spend time in a lecture explaining what this document
	entails and how it helps you to design better software.

	Leave this directory and go back into $(path ../doc).

	There you will edit $(_md Plan.md) with $(_nano) and write a brief description of
	the problem you found and what you will do to fix it.  Add your remarks
	under the $(bld "Phase 3: Testing & Debugging") heading.

	Finally, save the file to proceed with the lesson.
	:
}


edit_plan_test() {
	_STILL_IN_SRC=97
	_IN_DOC=98
	_IN_BASE=96
	_PLAN_UNCHANGED=97

	if   [[ "$PWD" == "$_BASE/src" ]]; then return $_STILL_IN_SRC
	elif [[ ${_CMD[0]} == cd && "$PWD" == "$_BASE/doc" ]]; then return $_IN_DOC
	elif [[ "$PWD" = "$_BASE" ]]; then return $_IN_BASE
	elif [[ "$PWD" != "$_BASE/doc" ]]; then return $WRONG_PWD
	elif _tutr_is_editor; then
		[[ $(git hash-object "$_BASE/doc/Plan.md") = $PLAN_HSH ]]
		_UNCHANGED=$?
		if   (( $_UNCHANGED == $_T )); then return $_PLAN_UNCHANGED
		else return 0
		fi
	else _tutr_generic_test -c nano -a Plan.md -d "$_BASE/doc"
	fi
}

edit_plan_hint() {
	case $1 in
		$_STILL_IN_SRC)
			cat <<-:
			From here you need to go up one directory, then into $(path doc).

			Try
			  $(cmd cd ../doc)
			:
			;;

		$_IN_DOC)
			cat <<-:
			Now that you're here, open $(_md Plan.md) in $(_nano) and add your
			remarks under the $(bld "Phase 3: Testing & Debugging") heading.

			Follow the on-screen instructions to save your changes back into the file.
			:
			;;

		$_PLAN_UNCHANGED)
			cat <<-:
			It doesn't look like you changed $(_md Plan.md) at all.  Were you
			able to save it in your text editor?

			Try again, and make sure that you don't accidentally save the
			file under a new name.
			:
			;;

		$_IN_BASE)
			cat <<-:
			Now go into $(path doc/)
			  $(cmd cd doc)
			:
			;;

		$WRONG_ARGS)
			cat <<-:
			The name of the file you should edit is $(_md Plan.md).
			:
			;;

		*)
			_tutr_generic_hint $1 nano "$_BASE/doc"
			;;
	esac
}



fix_bug_rw() {
	sed -i -e "23 c\    return True" "$_BASE/src/main.py"
}

fix_bug_ff() {
	sed -i -e "23 c\    return False" "$_BASE/src/main.py"
}

fix_bug_prologue() {
	cat <<-:
	Return to the $(path src/) directory and use $(_nano) to edit $(_py main.py) to fix the
	bug according to your plan.

	Then, re-run the unit tests with $(cmd $_PY runTests.py).

	This step will be complete when all four unit tests pass.
	:
}

fix_bug_test() {
	_NOT_FIXED=99
	_NOT_IN_SRC=97
	_MAIN_PY_CHANGED=98
	_MAIN_PY_UNCHANGED=96

	if   _tutr_noop cd pushd popd; then return $NOOP
	elif [[ "$PWD" = "$_BASE" ]]; then return $_NOT_IN_SRC
	elif [[ "$PWD" != "$_BASE/src" ]]; then return $WRONG_PWD
	elif _tutr_is_editor; then
		[[ $(git hash-object "$_BASE/src/main.py") != $MAIN_HSH ]]
		_CHANGED=$?
		if   (( $_CHANGED == $_T )); then return $_MAIN_PY_CHANGED
		else return $_MAIN_PY_UNCHANGED
		fi
	elif [[ ${_CMD[@]} == "$_PY runTests.py" && $_RES != 0 ]]; then return $_NOT_FIXED
	else _tutr_generic_test -c $_PY -a runTests.py -d "$_BASE/src"
	fi
}

fix_bug_hint() {
	case $1 in
		$_NOT_FIXED)
			cat <<-:
			Hmm, that didn't quite fix it.  Try again.
			:
			;;

		$_MAIN_PY_CHANGED)
			cat <<-:

			Now try re-running the test to make sure the bug is fixed
			   $(cmd $_PY runTests.py)
			:
			;;

		$_NOT_IN_SRC)
			cat <<-:
			Go into the $(path src/) subdirectory of this lesson to proceed.

			When you get there edit $(_py main.py) in $(_nano).
			:
			;;


		$_MAIN_PY_UNCHANGED)
			cat <<-:
			Edit $(_py main.py) in $(_nano) to fix the bug.

			Once you've done that, re-run the automated test
			   $(cmd $_PY runTests.py)
			:
			;;

		*)
			_tutr_generic_hint $1 $_PY "$_BASE/src"

			cat <<-:
			Edit $(_py main.py) in $(_nano) to fix the bug.

			Re-run the test to see that the bug is fixed
			   $(cmd $_PY runTests.py)
			:
			;;
	esac
}

fix_bug_epilogue() {
	cat <<-:
	${_Y}       _
	${_Y}      / )
	${_Y}    .' /
	${_Y}---'  (____        Great!
	${_Y}          _)
	${_Y}          __)   You fixed it!
	${_Y}         __)
	${_Y}---.______)
	${_Y}

	:
	_tutr_pressenter
}


signature_prologue() {
	cat <<-:
	Return to the $(path ../doc) subdirectory to finalize your documentation.
	Keep a daily log of your software development efforts in a file called
	$(_md Signature.md).

	The sprint signature file is composed of brief, dated entries describing
	what you did each day.  A one line description per day is plenty.

	Open and save this file in $(_nano), as usual.

	  * Create a new entry for today's work, with the date and time spent
	  * Delete all of the phony $(bld Nocemeber) entries; they are just examples
	  * Remove the entire line containing the $(bld TODO) message
	:
}

signature_test() {
	_MISSING=99
	_NOCEMBER=98
	_GOTO_DOC=97
	_TODO=96
    _TOTAL=95

	if   _tutr_noop cd pushd popd; then return $NOOP
	elif [[ $PWD = "$_BASE" ]]; then return $_GOTO_DOC
	elif [[ $PWD != "$_BASE/doc" ]]; then return $WRONG_PWD
	elif [[ ! -f "$_BASE/doc/Signature.md" ]]; then return $_MISSING
	elif grep -iqw "Nocember" "$_BASE/doc/Signature.md" >/dev/null; then return $_NOCEMBER
	elif grep -iqw "TODO" "$_BASE/doc/Signature.md" >/dev/null; then return $_TODO
    elif ! grep -iqw "TOTAL" "$_BASE/doc/Signature.md" >/dev/null; then return $_TOTAL
	elif [[ $(git hash-object "$_BASE/doc/Signature.md") != $SIG_HSH ]]; then return 0
	else _tutr_generic_test -c nano -a Signature.md -d "$_BASE/doc"
	fi
}

signature_hint() {
	case $1 in
        $_TOTAL)
			cat <<-:
			$(_md Signature.md) doesn't show your $(bld TOTAL) time investment!

			Please add that back into the file.
			:
			;;

		$_NOCEMBER)
			cat <<-:
			$(_md Signature.md) still contains placeholder entries that refer to the made-up
			month $(bld Nocember).  Those should not be in your final submission.

			Please remove these now.
			:
			;;

		$_TODO)
			cat <<-:
			The $(bld TODO) note is still at the top of $(_md Signature.md).  It is pretty
			unprofessional to leave TODO's in products that you intend to turn in
			to somebody else.

			Please get rid of it.
			:
			;;

		$_MISSING)
			cat <<-:
			$(_md Signature.md) is missing from $(path doc/)!

			You need to write something!

			Move it back here, or make a new one from scratch.
			:
			;;

		$_GOTO_DOC)
			cat <<-:
			Go into the $(path doc/) subdirectory of this lesson to proceed.

			When you get there, $(_md Signature.md) with $(cmd nano).
			:
			;;

		*)
			_tutr_generic_hint $1 nano "$_BASE/doc"
			;;
	esac

	cat <<-:

	Write a brief description of your work on this project in $(_md Signature.md).
	Include today's date in your write-up.  Remove the placeholder entries
	as well as the $(bld TODO) note at the top.
	:
}

signature_epilogue() {
	cat <<-:
	Good job!

	This is the workflow that $(_duckie) programmers follow:

	  * Set up your work environment
	  * Run tests
	  * Locate bugs
	  * Plan and document the fix
	  * Perform the fix
	  * Re-run tests to see that the bug is truly squashed and to ensure
	    no new bugs were introduced
	  * Update the project's documentation

	The importance of maintaining up-to-date documentation cannot be
	overemphasized.

	:
	_tutr_pressenter
}


epilogue() {
	cat <<-EPILOGUE
	Way to go!  You're almost done!  Do you feel smarter yet?
	You sure are getting there!

	In this lesson you have learned how to

	* Create and edit text files with the $(_nano) editor
	* Organize files into directories
	* Follow the $(_duckie) standard project structure
	* Run unit tests and interpret their results
	* Write project documentation

                                   $(blk ASCII art credit: Veronica Karlsson)
	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -d "$_BASE" ]] && rm -rf "$_BASE"
	_tutr_lesson_complete_msg $1
}



source main.sh && _tutr_begin \
	nano_readme \
	mkdirs \
	sort_files \
	remove_junk \
	cd_into_src \
	run_tests \
	nano_main_py \
	edit_plan \
	fix_bug \
	signature \


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
