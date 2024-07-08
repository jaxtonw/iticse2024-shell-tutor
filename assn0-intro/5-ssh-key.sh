#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=10

PATH="$PWD/.lib:$PATH"

source ansi-terminal-ctl.sh
source progress.sh
source ssh-connection-test.sh
if [[ -n $_TUTR ]]; then
	source editors+viewers.sh
	source generic-error.sh
	source open.sh
	source platform.sh
	public() { (( $# == 0 )) && echo $(grn public) || echo $(grn $*) ; }
	private() { (( $# == 0 )) && echo $(red private) || echo $(red $*); }
	username() { (( $# == 0 )) && echo $(mgn username) || echo $(mgn $*) ; }
	password() { (( $# == 0 )) && echo $(ylw password) || echo $(ylw $*); }
	_duckie() { (( $# == 0 )) && echo $(ylw DuckieCorp) || echo $(ylw $*) ; }
fi

# TODO: rewrite this lesson to prefer an ED25519 key (if possible)
#       macOS defaults to RSA b/c of an older version of OpenSSH
_KEYSIZE=2048
_GL_IPADDR=129.123.29.225


_ssh_key_is_already_installed_msg() {
	cat <<-MSG
	${_Y}       _
	${_Y}      / )
	${_Y}    .' /
	${_Y}---'  (____     ${_Z}Your SSH key is already installed on GitLab.
	${_Y}          _)
	${_Y}          __)   ${_Z}You are good to go!
	${_Y}         __)
	${_Y}---.______)
	${_Y}

	MSG
	_tutr_pressenter
}

_ssh_key_exists_msg() {
	cat <<-MSG
	I found an SSH key named $(path $(basename $1)) under $(path ~/.ssh).

	  * If you proceed with the lesson, you will skip over the step that
	    creates a new SSH key.

	  * If you would like to re-generate your SSH key under the tutorial's
	    guidance, exit this lesson, delete these files and start over again:

	  $(path $1)
	  $(path $1.pub)

	MSG
	_tutr_pressenter
}

# There are four ways connecting to GitLab could fail
#  0. No internet|host key verification failed = fix the problem and try again
#  1. No local SSH keys = create and upload new key to GitLab
#  2. Local SSH key is not on GitLab = don't re-create, but upload to GitLab
#  3. Local key exists on GitLab = mark this lesson complete and move on
#
# This function is adapted from ssh_tutr_assert_ssh_connection_is_okay()
# from .lib/ssh-connection-test.sh.  It differs by allowing the lesson
# to proceed when an SSH key does not exist.  In other lessons the user
# should re-create their SSH key by themselves or by re-doing this lesson.
_tutr_check_ssh_connection() {
	[[ -z $DEBUG ]] && clear || set -x

	ssh-keygen -F $_GL >/dev/null 2>&1 || _tutr_info _ssh_add_hostkey_msg

	local msg stat ret
	msg=$(ssh -o PasswordAuthentication=no -o ConnectTimeout=7 -T git@$_GL 2>&1)
	stat=$?
	ret=0

	case $stat in
		0)
			# User logged in with SSH key; this lesson can be skipped
			:
			;;
		255)
			if   [[ $msg == *"Permission denied"* ]]; then
				# This message means the internet is working and
				# the SSH key is not on GitLab.
				ret=1
			elif [[ $msg == *"Could not resolve hostname"* ]]; then
				# DNS is down
				_tutr_die _no_internet_msg "$msg"
			elif [[ $msg == *"Connection timed out"* ]]; then
				# Network is down
				_tutr_die _no_internet_msg "$msg"
			elif [[ $msg == *"Host key verification failed"* ]]; then
				# Host key changed/spoofed
				_tutr_die _host_key_verification_fail_msg "'$msg'"
			elif [[ $msg == *"Too many authentication failures"* ]]; then
				# User was prompted for password
				_tutr_die _too_many_auth_failures_msg "'$msg'"
			else
				_tutr_die _other_problem_msg "'$msg'"
			fi
			;;
		*)
			if _tutr_ssh_key_is_present; then
				_tutr_warn _ssh_key_exists_msg $REPLY
			else
				_tutr_die _ssh_key_is_missing_msg
			fi
			;;
	esac
	[[ -n $DEBUG ]] && set +x
	return $ret
}

setup() {
	source screen-size.sh 80 30

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh-keygen
	_tutr_assert_program_exists ssh

	if _tutr_check_ssh_connection; then
		_tutr_info _ssh_key_is_already_installed_msg
		_record_completion ${_TUTR#./} lesson_complete
		cleanup $_COMPLETE
		exit
	fi

	export _BASE="$PWD"
	# Because I can't count on GNU Coreutils realpath(1) or readlink(1) on
	# all systems, get parent dir's real name the old fashioned way
	export PARENT="$(cd .. && pwd)"
	export _REPO_PATH="$PARENT/ssh-key-test"
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	Shell Lesson #5: SSH Keys

	In this lesson you will

	* Create an SSH key with $(cmd ssh-keygen)
	* Learn what an SSH key is and how to put it on GitLab
	* Test that your SSH key is correctly set up with $(cmd ssh)

	This lesson takes around $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter

	cat <<-:

	$(cyn SSH), the $(cyn S)ecure $(cyn SH)ell, is a system for securely running commands on a
	remote computer.

	Most programmers know it as the tool that lets them log in to another
	computer to run shell commands.  This gives rise to the saying:

	 $(cyn '"Remote login is a lot like astral projection"')

	But SSH is much more than an out-of-body experience for computers.
	$(bld Any) program, not just a command shell, can be executed from a
	distance.  This has great implications for programmers and system
	administrators, and it is something that you will do regularly in this
	class once you begin using $(bld Git).

	Securing this connection is of the utmost importance.

	:

	_tutr_pressenter

	cat <<-:

	$(bld "Cool story, bro.  But what is an SSH key?")

	An SSH key is a file on your computer that contains a really long random
	number.  In a moment you'll get to see what one looks like.

	Your SSH key will serve as both your $(username) and your $(password) when
	connecting to GitLab from the command line.  This point is very
	important.  When you begin using Git at $(_duckie), your SSH key will
	save you from re-typing your $(password) dozens of times each day.

	Besides enabling you to be more lazy than ever, your SSH key is still
	more secure than your $(password).

	Sound too good to be true?  Hang on tight, and I'll explain everything!

	:

	_tutr_pressenter
}



ssh_keygen_ff() {
	if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
		ssh-keygen -t rsa -b $_KEYSIZE
	fi

	if [[ ! -f "$HOME/.ssh/id_rsa.pub" ]]; then
		ssh-keygen -y -f "$HOME/.ssh/id_rsa" > "$HOME/.ssh/id_rsa.pub"
	fi
}

ssh_keygen_prologue() {
	cat <<-MSG
	An SSH key is generated with a program called $(cmd ssh-keygen).
	You can run it like this:
	  $(cmd ssh-keygen -t rsa -b $_KEYSIZE)

	* The $(cmd "-t rsa") option creates a key for use with the $(bld RSA)
	  encryption algorithm.

	* $(cmd "-b $_KEYSIZE") builds the key with a $_KEYSIZE-bit random number.  This
	  is big enough to keep the bad guys from guessing your key (for now).

	MSG

	_tutr_pressenter

	cat <<-MSG

	Before you run $(cmd ssh-keygen), I want to give you a quick heads-up.
	You will be asked some questions, and you should just hit $(kbd '<ENTER>') for
	each of them.

	The first prompt asks $(bld where) to save your key.  The default is
	$(path '$HOME/.ssh/id_rsa'), and this lesson expects exactly that
	location.  Don't type anything else.  Just press $(kbd '<ENTER>').

	The second prompt asks for a $(bld passphrase).  Most users $(bld leave this)
	$(bld blank).  You will be asked for it twice, so hit $(kbd '<ENTER>') twice.

	MSG

	_tutr_pressenter

	cat <<-MSG

	After your SSH key is created, you'll be shown its $(bld fingerprint) and
	$(bld randomart) image.  They look weird, and are mostly harmless, so
	you can ignore them.

	Run $(cmd ssh-keygen -t rsa -b $_KEYSIZE) to create your SSH key.
	MSG
}

ssh_keygen_test() {
	[[ -n $DEBUG ]] && echo ssh_keygen_test && _tutr_pressenter
	_KEYGEN_ARG=99
	if _tutr_ssh_key_is_present; then return 0
	elif [[ ${_CMD[0]} == ssh && ${_CMD[1]} == -keygen ]]; then return $_KEYGEN_ARG
	elif [[ ${_CMD[*]} == "ssh-keygen "*"-b"*"-t"* ]]; then
		_tutr_generic_test -c ssh-keygen -a "-b" -a $_KEYSIZE -a "-t" -a rsa
	else
		_tutr_generic_test -c ssh-keygen -a "-t" -a rsa -a "-b" -a $_KEYSIZE
	fi
}

ssh_keygen_hint() {
	case $1 in
		$NOOP)
			;;
		$_KEYGEN_ARG)
			cat <<-:
			$(cmd "-keygen") is not an option for $(cmd ssh).

			$(cmd ssh-keygen) is one word.  Try again.
			:
			;;
		*)
			_tutr_generic_hint $1 ssh-keygen $_BASE
			cat <<-:

			Create your SSH key with $(cmd ssh-keygen -t rsa -b $_KEYSIZE).
			:
			;;
	esac
}

ssh_keygen_epilogue() {
	if [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt ksh_arrays
	fi

	local rorschach=(
		"a butterfly hovering above a hurricane"
		"a burning fire extinguisher"
		"a dragon breathing fire on a windmill"
		"a sad clown juggling smaller, happier clowns"
		"a sea lion playing the violin"
		"a bird, a plane, or maybe Superman in flight"
		"an explosion of fruit flavor"
		"a jumbled assortment of letters, numbers, and symbols"
		"a mythological creature, perhaps a fairy or an honest politician"
		"a map of an imaginary country called 'Canada'"
	)

	cat <<-:
	I see ${rorschach[$RANDOM % ${#rorschach[@]}]}.
	What do you think it looks like?

	:
	_tutr_pressenter
}



chdir_to_ssh_dir_rw() {
	cd
}

chdir_to_ssh_dir_ff() {
	cd ~/.ssh
}

chdir_to_ssh_dir_prologue() {
	cat <<-MSG
	Let's navigate to the directory that contains your SSH key.

	Change directories into $(path '~/.ssh').
	MSG
}

chdir_to_ssh_dir_test() {
	if [[ "$PWD" == "$HOME/.ssh" ]]; then return 0
	else _tutr_generic_test -c cd -d "$HOME/.ssh"
	fi
}

chdir_to_ssh_dir_hint() {
	_tutr_generic_hint $1 "cd ~/.ssh" "$HOME/.ssh"
	[[ $1 = $WRONG_PWD ]] && return
	cat <<-:

	$(cmd cd) into the $(path ~/.ssh) directory.
	:
}



ls_ssh_dir_prologue() {
	cat <<-MSG
	Now take a look at the contents of this directory.
	MSG
}

ls_ssh_dir_test() {
	_tutr_generic_test -c ls -x -d "$HOME/.ssh"
}

ls_ssh_dir_hint() {
	_tutr_generic_hint $1 ls "$HOME/.ssh"
}

ls_ssh_dir_epilogue() {
	_tutr_pressenter
	cat <<-:

	There may be a few other files here, but I want you to focus on
	these two: $(private id_rsa) and $(public id_rsa.pub).

	:
	_tutr_pressenter
}



view_private_key_prologue() {
	cat <<-:
	Your SSH key comes in two parts: a $(private) key and its corresponding
	$(public) key.  Obviously, you should strive to keep the $(private) key
	a secret.

	Do you want to see it?  $(private id_rsa) is just a plain text file that you can
	view with $(cmd cat).  Take a look at it now.
	:
}

view_private_key_test() {
	VIEWED_WRONG_KEY=99

	# Negative array subscripts only allowed in Zsh and Bash >= 4.2
	# The safe way to access last element in an array  ${_CMD[${#_CMD} - 1]}
	if  _tutr_is_viewer; then
		if [[ ${_CMD[@]} != *id_rsa ]]; then
			return $VIEWED_WRONG_KEY
		else
			_tutr_generic_test -c ${_CMD[0]} -a id_rsa -d "$HOME/.ssh"
		fi
	else
		_tutr_generic_test -c cat -a id_rsa -d "$HOME/.ssh"
	fi
}

view_private_key_hint() {
	case $1 in
		$NOOP)
			;;

		$VIEWED_WRONG_KEY)
			cat <<-:
			You looked at the $(public) SSH key, not the $(private) one!

			$(cmd cat) $(private id_rsa), not $(public id_rsa.pub).
			:
			;;
		*)
			_tutr_generic_hint $1 cat "$HOME/.ssh"

			cat <<-:

			Run $(cmd cat id_rsa) to view the $(private) key.
			:
			;;
	esac
}

view_private_key_epilogue() {
	_tutr_pressenter

	cat <<-MSG

	Huh.  So $(bld "that's") what $_KEYSIZE bits of randomness looks like.

	This illustrates what I was saying about your SSH key being
	more secure than your $(password).

	MSG
}



pop_quiz0_prologue() {
	cat <<-:
	${_Y} ___             ___       _
	${_Y}| _ \\___ _ __   / _ \\ _  _(_)___
	${_Y}|  _/ _ \\ '_ \\ | (_) | || | |_ /
	${_Y}|_| \\___/ .__/  \\__\\_\\\\_,_|_/__|
	${_Y}   	 |_|${_Z}

	True or False: your current $(password) is dumb and predictable, like
	$(ylw_ chocolate), $(ylw_ 123456) or $(ylw_ password).

	Run $(cmd true) or $(cmd false) to answer this question.  Be honest.
	:
}


pop_quiz0_test() {
	if   [[ ${_CMD[0]} == true || ${_CMD[0]} == false ]]; then return 0
	else return 1
	fi
}

pop_quiz0_hint() {
	cat <<-:
	Is your current $(password) something dumb like $(ylw_ 123456), $(ylw_ chocolate)
	or $(ylw_ password)?

	Run $(cmd true) or $(cmd false) to answer this question.  Be honest.
	:
}

pop_quiz0_epilogue() {
	if [[ ${_CMD[0]} == true ]]; then
		cat <<-:
		Your candor does you credit.

		:
	else
		cat <<-:
		                 ${_Y}
		                 ${_Y}      .     :     .
		                 ${_Y}    .  :    |    :  .
		                 ${_Y}     .  |   |   |  ,
		                 ${_Y}      \\  |     |  /
		                 ${_Y}  .     ,-'"""\`-.     .
		                 ${_Y}    "- /${_B}  __ __  ${_Y}\\ -"
		                 ${_Y}      |${_B}==|  I  |==${_Y}|
		                 ${_Y}- --- | ${_R}_${_B}\`--^--'${_R}_${_Y} | --- -
		                 ${_Y}      |${_R}'\`.     ,'\`${_Y}|
		                 ${_Y}    _- \\${_R}  "---"  ${_Y}/ -_
		                 ${_Y}  .     \`-.___,-'     .
		                 ${_Y}      /  |     |  \\
		                 ${_Y}    .'  |   |   |  \`.
		                 ${_Y}       :    |    :
		                 ${_Y}      .     :     .

		                 ${_W}Hearing that made my day!${_Z}

		:
	fi

	cat <<-:
	Anyway, which do you think is harder for a hacker to guess?
	Your little, itty-bitty $(password), or this magnificent SSH key?

	:

	_tutr_pressenter

	cat <<-:

	I think we both know the answer.

	So, maybe you shouldn't show $(private id_rsa) to anyone else, ever.
	And definitely don't put it on somebody else's computer!

	If the integrity of your $(private) key is ever compromised, you should
	delete it and make a new one with $(cmd ssh-keygen).

	:

	_tutr_pressenter
}



stow() {

	This file we just viewed the contents of is the *private* key. This key
	is *not* what you want to share with others. This key is how your
	computer will be able to authenticate that the public key shared with
	another device is *actually* a match. This is done by using a special
	math encryption algorithm, the RSA encryption algorithm.

	We need to be very careful with this private key, as knowledge of the
	private key can be used to generate fake matching public keys. This
	cannot be done the other way around. Hence why we can share the public
	key but cannot share the private key.
	MSG
	_tutr_pressenter



}

stow() {
	cat <<-MSG

	The file 'id_rsa.pub' is your *public* SSH key. This file is the file
	we want to share with others to authenticate a connection.
	MSG
	_tutr_pressenter

	cat <<-MSG

	When an SSH key is generated, there are two parts of this key; a
	public key and a private key. The public part of the key is shared
	with the device you want to connect to, and the private key stays on
	your device. By sharing the public key with another device, you are
	stating that it is A-Okay for your two devices to establish a secure
	connection between them. You can share the public key with numerous
	devices, allowing your device to establish an SSH connection with
	various devices.
	MSG
	_tutr_pressenter
}




view_public_key_prologue() {
	cat <<-MSG
	Which brings us to the next file, $(public id_rsa.pub), your SSH $(public) key.

	The rules for this key are the opposite of the $(private) key.  You can
	hand $(public id_rsa.pub) out like candy at Halloween.  This is the file that you
	will put on GitLab.

	Wanna check it out?  Go on and $(cmd cat) it.
	MSG
}

view_public_key_test() {
	VIEWED_WRONG_KEY=99

	if  _tutr_is_viewer; then
		if [[ ${_CMD[@]} != *id_rsa.pub ]]; then
			return $VIEWED_WRONG_KEY
		else
			_tutr_generic_test -c ${_CMD[0]} -a id_rsa.pub -d "$HOME/.ssh"
		fi
	else
		_tutr_generic_test -c cat -a id_rsa.pub -d "$HOME/.ssh"
	fi

}

view_public_key_hint() {
	case $1 in
		$NOOP)
			;;

		$VIEWED_WRONG_KEY)
			cat <<-:
			You looked at the $(private) SSH key, not the $(public) one!

			$(cmd cat) $(public id_rsa.pub), not $(private id_rsa).
			:
			;;
		*)
			_tutr_generic_hint $1 cat "$HOME/.ssh"

			cat <<-:

			Run $(cmd cat id_rsa.pub) to view the $(public) key.
			:
			;;
	esac
}

view_public_key_epilogue() {
	cat <<-:
	It's not much, but it'll do.

	:

	_tutr_pressenter

	cat <<-:

	${_R}      _____       ${_G}      _____
	${_R}  ,ad8PPPP88b,    ${_G}   ,d88PPPP8ba,
	${_R} d8P"      "Y8b,  ${_G} ,d8P"      "Y8b
	${_R}dP'           "8a ${_G} 8"           \`Yd ${_Z}   Your $(public) and $(private) keys fit
	${_R}8(  BEST SSH    \\${_G}  \\             )8${_Z}   together like the matching halves
	${_R}I8              / ${_G} /             8I  ${_Z}  of a friendship locket.  You can
	${_R} Yb,   FRIENDS /  ${_G}/   FOR      ,dP  ${_Z}give the $(public) key to any computer
	${_R}  "8a,         \\ ${_G} \\          ,a8"  ${_Z}   that you want to be besties with.
	${_R}    "8a,        \\${_G}  \\ EVAH! ,a8"
	${_R}      "Yba      / ${_G} /     adP"        ${_Z}   Later, when you connect to that
	${_R}        \`Y8a   / ${_G} /    a8P'         ${_Z} computer through SSH, both parties
	${_R}          \`88, \\${_G}  \\  ,88'         ${_Z}        make sure their halves of the
	${_R}            "8b \\ ${_G} \\d8"            ${_Z} locket match before logging you in.
	${_R}             "8b \\${_G}  8"
	${_R}              \`888${_G}
	${_R}                "

	Because SSH keys are unique, they can

	  0. $(username identify) you (i.e. serve as your $(username))
	  1. $(password authenticate) you (i.e. act like a $(password))

	:

	_tutr_pressenter

	cat <<-:

	An important difference between $(private) and $(public) keys is that
	there exists an algorithm that can derive the $(public) key from its
	corresponding $(private) key, but not vice-versa.  This is why it is
	unsafe to share your $(private) key with anyone.

	So what does it mean if an attacker ever takes control of your $(private)
	key?  They can impersonate you and log into any systems that have been
	told to trust the corresponding $(public) key.  If you ever suspect that
	your $(private) key has been compromised, log on to those systems as
	soon as possible and replace or remove the $(public) key.

	:

	_tutr_pressenter

	_tutr_open $_HTTPS_GITLAB_KEYS
	#|| _tutr_warn echo "Open '$_HTTPS_GITLAB_KEYS' in your web browser"

	cat <<-:

	I have opened a browser window to the GitLab page where you will save
	your $(public) key.  If you haven't already done so, you will sign up
	and/or log in to GitLab now.

	(If a browser window didn't pop up for you, go to
	  $(path $_HTTPS_GITLAB_KEYS) )

	Copy the contents of $(public id_rsa.pub), beginning with $(bld ssh-rsa)
	(here it is again):

	$(cat "$HOME/.ssh/id_rsa.pub")

	...and paste this into the $(bld Key) box on this page.  Click $(bld Add Key) to save.
	The button will be disabled if there is something wrong with your key.
	Be sure to leave off the "$(grn Tutor):" text at the beginning, as well as any
	extra spaces.

	It's that easy!

	:

	_tutr_pressenter

}



put_key_on_gitlab_pre() {
	_FAILS=0
}

put_key_on_gitlab_prologue() {
	cat <<-:
	Now that your $(public) key is on GitLab, you will run a command to make
	sure it works.  You'll either get the $(cyn Good News) or the $(red Bad News).

	$(cyn Good news)
	You'll see this message, but with your GitLab username instead of
	$(bld username):
	  $(bld Welcome to GitLab, @username!)

	$(red Bad news)
	You will get this password prompt:
	  $(bld "git@$_GL's password:")

	Just hit $(kbd Ctrl-C) to cancel it, and try again.
	If this persists, contact $_EMAIL for help.

	So what are you waiting for?  Let's find out if your SSH key is good.
	  $(cmd ssh -T git@$_GL)
	:
}

put_key_on_gitlab_test() {
	local pattern="^ssh -T git@$_GL$|^ssh git@$_GL -T$"
	local gh_pattern="^ssh -T git@github*$|^ssh git@github* -T$"

	if   [[ ${_CMD[@]} =~ $pattern ]]; then 
		if (( $_RES == 0 )); then return 0
		# GitHub returns 1 when a key is found, but shell access it not granted
		elif [[ ${_CMD[@]} =~ $gh_pattern ]] && (( $_RES == 1 )); then return 0 
		fi
	elif [[ ${_CMD[@]} =~ $pattern ]]; then
		(( ++_FAILS ))
		return $STATUS_FAIL
	else _tutr_generic_test -c ssh -a -T -a git@$_GL
	fi
}

put_key_on_gitlab_hint() {
	case $1 in
		$NOOP)
			;;
		$STATUS_FAIL)
			if (( _FAILS >= 3)); then
				cat <<-:
				It keeps going wrong, huh?  I'm sorry that this is happening to you.

				I think you should ask $_EMAIL for help now.
				:
			elif (( _FAILS == 2 )); then
				cat <<-:
				Are you sure that your key was saved on GitLab?  Go back to your browser
				tab and check that
				  0. the $(bld Key) field contains your $(public) key
				  1. and the $(bld Add Key) button was clicked

				If it helps, here is your $(public) key again:

				$(cat "$HOME/.ssh/id_rsa.pub")
				:
			elif (( _FAILS == 1 )); then
				cat <<-:
				Oof, that didn't quite work, did it?

				Try it again.  Maybe you'll have better luck this time.
				  $(cmd ssh -T git@$_GL)
				:
			fi
			;;
		*)
			_tutr_generic_hint $1 ssh "$HOME/.ssh"
			cat <<-:

			Run $(cmd cat id_rsa.pub) if you need to see your public key again.

			After you've saved your public key on GitLab, run
			  $(cmd ssh -T git@$_GL)
			as a test.
			:
			;;
	esac
}


put_key_on_gitlab_epilogue() {
	cat <<-:
	Isn't that something?  You told $(cmd ssh) to log in as
	$(username git)@$_GL, but it still recognized you by your
	actual username.  $(bld And) it didn't ask for a $(password)!

	SSH keys: $(username identification) and $(password authentication) in one!

	:

	_tutr_pressenter

	cat <<-:

	Now, all of this business with $(cmd ssh-keygen) and putting keys on GitLab
	needs to be repeated with $(bld every) different computer that you want to
	use $(bld Git) on.  It is better to think of your $(private) key as
	identifying this $(bld device) instead of yourself.  It is normal to have
	many different $(public) keys on your GitLab account; as you have seen,
	they are really easy to make.

	Come back to this lesson any time you need to brush up on $(cmd ssh-keygen).

	:

	_tutr_pressenter
}


epilogue() {
	cat <<-EPILOGUE
	With an SSH key on GitLab, you are ready to learn the best thing to
	happen to programmers since multi-user time-sharing operating systems
	came along: $(bld Git).

	In this lesson you learned how to

	* Create an SSH key with $(cmd ssh-keygen)
	* Learn what an SSH key is and how to put it on GitLab
	* Test that your SSH key is correctly set up with $(cmd ssh)

		                                 $(blk ASCII art credit: Philip Kaulfuss)
	EPILOGUE

	_tutr_pressenter
}


cleanup() {
	[[ -n $DEBUG ]] && _tutr_warn echo "cleanup(): 1 is $1"
	_tutr_lesson_complete_msg $1
	return $1
}



source main.sh && _tutr_begin \
	ssh_keygen \
	chdir_to_ssh_dir \
	ls_ssh_dir \
	view_private_key \
	pop_quiz0 \
	view_public_key \
	put_key_on_gitlab


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
