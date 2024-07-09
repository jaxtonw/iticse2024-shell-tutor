#!/bin/sh

. .lib/shell-compat-test.sh

_DURATION=5

# Put tutorial library files into $PATH
PATH="$PWD/.lib:$PATH"

source ansi-terminal-ctl.sh
source progress.sh


# This assignment's number
_A=1.1

# Name of the starter code repo
_REPONAME=cs1440-winder-jaxton-assn$_A

# origin of the starter code repo
_SSH_REPO_URL=git@github.com:jaxtonw/$_REPONAME

# Should be the hostname where students are expected to push to
_GIT_REMOTE_HOST=github.com

# The instructor's username. Should be contained in the _SSH_REPO_URL 
_INSTRUCTOR_USERNAME=jaxtonw

# Enforce naming standard. When set to 0 (true), force the repo naming standard of 'cs1440-LAST-FIRST-assn$_A'
_ENFORCE_NAMING_STANDARD=1

# Used to swap between GitHub/GitLab (or other platforms) dynamically
_GIT_REMOTE_PLAT=GitHub

if [[ -n $_TUTR ]]; then
	source generic-error.sh
	source git.sh
	source noop.sh
	source open.sh

	# make sure realpath(1) or an equivalent is available
	which realpath &>/dev/null || source realpath.sh

	# This function is named `_Git` to avoid clashing with Zsh's `_git`
	_Git() { (( $# == 0 )) && echo $(blu Git) || echo $(blu $*); }
	_GitPlat() { (( $# == 0 )) && echo $(cyn $_GIT_REMOTE_PLAT) || echo $(cyn $*); }
	_local() { (( $# == 0 )) && echo $(ylw local) || echo $(ylw $*); }
	_remote() { (( $# == 0 )) && echo $(mgn remote) || echo $(mgn $*); }
	_origin() { (( $# == 0 )) && echo $(red origin) || echo $(red $*); }

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



setup() {
	source screen-size.sh 80 35

	source assert-program-exists.sh
	_tutr_assert_program_exists ssh
	_tutr_assert_program_exists git

	source ssh-connection-test.sh
	_tutr_assert_ssh_connection_is_okay

	export _BASE="$PWD"
}


_tutr_lesson_statelog_global() {
	_TUTR_STATE_CODE= # We don't have a meaningful and general state code yet...
	_TUTR_STATE_TEXT=$(_tutr_git_default_text_statelog "$_REPO_PATH")
}


prologue() {
	[[ -z $DEBUG ]] && clear
	echo
	cat <<-PROLOGUE
	$(_tutr_progress)

	This lesson helps you make and submit your certificate.
	It takes about $_DURATION minutes.

	PROLOGUE

	_tutr_pressenter
}



make_certificate_ff() {
	./make-certificate.sh
}

make_certificate_rw() {
	rm -f certificate.txt shell-logs.tgz shell-logs.zip
}

make_certificate_prologue() {
	cat <<-:
	It is time to create the $(ylw Certificate of Completion).  You know the drill.
	Just run
	  $(cmd ./make-certificate.sh)
	:
}

make_certificate_test() {
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	_tutr_file_untracked certificate.txt && return 0
	_tutr_generic_test -c ./make-certificate.sh -d "$_BASE"
}

make_certificate_hint() {
	case $1 in
		$WRONG_PWD) _tutr_minimal_chdir_hint "$_BASE" ;;
		*) _tutr_generic_hint $1 ./make-certificate.sh "$_BASE" ;;
	esac
}



commit_certificate_ff() {
	if [[ -n $BASH ]]; then
		local RESTORE_FAILGLOB=$(shopt -p failglob)
		local RESTORE_NULLGLOB=$(shopt -p nullglob)
		shopt -u failglob
		shopt -s nullglob
	elif [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt null_glob local_options
	fi
	git add certificate.txt shell-logs*
	git commit -m "committing certificate and log archive"
	[[ -n $BASH ]] && eval $RESTORE_FAILGLOB && eval $RESTORE_FAILGLOB
}

commit_certificate_pre() {
	if [[ -n $BASH ]]; then
		local RESTORE_FAILGLOB=$(shopt -p failglob)
		local RESTORE_NULLGLOB=$(shopt -p nullglob)
		shopt -u failglob
		shopt -s nullglob
	elif [[ -n $ZSH_NAME ]]; then
		emulate -L zsh
		setopt null_glob local_options
	fi
	ARCHIVE=(*.zip *.tgz)
	[[ -n $BASH ]] && eval $RESTORE_FAILGLOB && eval $RESTORE_FAILGLOB
}

commit_certificate_prologue() {
	if [[ -n ${ARCHIVE[@]} ]]; then
		cat <<-:
		The certificate comes in two parts
		  - A text file named $(path certificate.txt)
		  - An archive called $(path ${ARCHIVE[0]})

		Now add and commit the certificate and archive files.
		:
	else
		cat <<-:
		Now add and commit the certificate.
		:
	fi
}

commit_certificate_test() {
	_UNTRACKED_CERT=99
	_STAGED_CERT=98
	_MISSING_CERT=96
	_MISSING_ARCHIVE=95
	_UNTRACKED_ARCHIVE=94
	_STAGED_ARCHIVE=93
	_BRANCH_NOT_AHEAD=92
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	[[ ! -f "$_BASE/certificate.txt" ]] && return $_MISSING_CERT
	_tutr_file_untracked certificate.txt && return $_UNTRACKED_CERT
	if [[ -n ${ARCHIVE[@]} ]]; then
		[[ ! -f "$_BASE/${ARCHIVE[0]}" ]] && return $_MISSING_ARCHIVE
		_tutr_file_untracked ${ARCHIVE[0]} && return $_UNTRACKED_ARCHIVE
		_tutr_file_staged ${ARCHIVE[0]} && return $_STAGED_ARCHIVE
	fi
	_tutr_file_staged certificate.txt && return $_STAGED_CERT
	_tutr_branch_ahead && return 0
	# Fell through, I'm not sure how a student could do this
	return $_BRANCH_NOT_AHEAD
}

commit_certificate_hint() {
	case $1 in
		$_UNTRACKED_CERT)
			cat <<-:
			Add $(path certificate.txt) to the next commit with $(cmd git add certificate.txt).
			:
			;;

		$_STAGED_CERT)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the certificate to the
			$(_Git) repository.
			:
			;;

		$_MISSING_CERT)
			cat <<-:
			Uh-oh!  Where did $(path certificate.txt) go?  It needs to be in the root of
			this repository.  Find it and put it back here!

			Alternatively, you can just re-create it by running
			  $(cmd ./make-certificate.sh).
			:
			;;

		$_UNTRACKED_ARCHIVE)
			cat <<-:
			Add $(path ${ARCHIVE[0]}) to the next commit with $(cmd git add ${ARCHIVE[0]}).
			:
			;;

		$_STAGED_ARCHIVE)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the archive and
			certificate in the $(_Git) repository.
			:
			;;

		$_MISSING_ARCHIVE)
			cat <<-:
			Uh-oh!  Where did $(path ${ARCHIVE[@]}) go?  It needs to be in the root of
			this repository.  Find it and put it back here!

			Alternatively, you can just re-create it by running
			  $(cmd ./make-certificate.sh).
			:
			;;

		$_BRANCH_NOT_AHEAD)
			cat <<-:
			Something isn't right with your repository; I'll attempt to fix it...

			:

			git remote remove origin
			git remote add -f origin $_SSH_REPO_URL
			git branch --set-upstream-to=origin/master

			cat <<-:

			Now run $(cmd tutor test) to proceed.

			If you get this message again, reach out to $_EMAIL for help.
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_BASE"
			;;

		*)
			cat <<-:
			As a reminder, the steps of your $(_Git) workflow are
			  0. $(cmd git add certificate.txt)
			  1. $(cmd 'git commit -m "Brief commit message"')
			  2. $(cmd git push -u origin master)

			:
			;;

	esac
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
	To submit your work, you must change where the $(_origin) URL points.
	You can see where it is currently pointing by running
	  $(cmd git remote -v)

	As in other assignments, you will rename $(_origin) to $(_origin old-origin), then
	create a new $(_remote) named $(_origin) pointing to a repo on your account.

	Use this command to make the change:
	  $(cmd git remote rename origin old-origin)
	:
}

# Ensure that a remote called 'origin' no longer exists
git_remote_rename_test() {
	if   [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = -v ]]; then return $NOOP
	fi

	_WRONG_REMOTE_NAME=99
	local remote="$(git remote)"
	if   echo $remote | command grep -q -E old-origin; then return 0
	elif [[ -z $remote ]] ; then return 0  # if all remotes are deleted, let them through
	elif [[ $remote != origin ]]; then
		_REMOTE=$remote
		return $_WRONG_REMOTE_NAME
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = help ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = log ]]; then return $NOOP
	else _tutr_generic_test -c git -a remote -a rename -a origin -a old-origin -d "$_BASE"
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
			_tutr_generic_hint $1 git "$_BASE"
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
		echo
		_tutr_pressenter
	fi
}



# Add a new repo URL under the name 'origin'
git_remote_add_rw() {
	git remote remove origin
}

git_remote_add_ff() {
	local repo=/tmp/assn$_A
	_tutr_info printf "'Just guessing... using $repo as the remote URL for origin'"
	if [[ ! -d $repo ]]; then
		git clone --bare "$_REPO_PATH" $repo
	fi
	git remote add origin $repo
}

git_remote_add_prologue() {
	cat <<-:
	Next, associate $(_origin) with a new $(_GitPlat) URL that includes your name.

	Recall that $(_Git) needs this URL to precisely match this pattern:
	:
	if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
		if [[ -n $_GL_USERNAME ]]; then
			cat <<-:
			$(path git@${_GIT_REMOTE_HOST}:${_GL_USERNAME}/cs1440-LASTNAME-FIRSTNAME-assn$_A)
			:
		else
			cat <<-:
			$(path git@${_GIT_REMOTE_HOST}:USERNAME/cs1440-LASTNAME-FIRSTNAME-assn$_A)

			* Replace $(cyn USERNAME) with your $(bld $_GIT_REMOTE_PLAT username)
				* Your $(bld $_GIT_REMOTE_PLAT username) is most likely your $(bld Student ID)
				* You can see your username by clicking on your avatar in the
				upper-right corner of $_GIT_REMOTE_PLAT while logged in.
			:
		fi
		cat <<-:
		* Replace $(cyn LASTNAME-FIRSTNAME) with your $(bld real names)
		:
	else
		cat <<-:
		$(path git@${_GIT_REMOTE_HOST}:${_GL_USERNAME}/PROJECTNAME)

		* Replace $(cyn PROJECTNAME) with the desired name for your project.
		:
	fi

	cat <<-:

	Run $(cmd git remote add origin URL) to make this change
	:
}

git_remote_add_test() {
	_WRONG_SUBCOMMAND=95
	if   [[ "$PWD" != "$_BASE" ]]; then return $WRONG_PWD
	elif _tutr_noop; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = help ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = status ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = log ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = -v ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} = remote && ${_CMD[2]} = remove ]]; then return $NOOP
	elif [[ ${_CMD[0]} = git && ${_CMD[1]} != remote ]]; then return $_WRONG_SUBCOMMAND
	fi

	_NO_ORIGIN=99
	_IS_INSTRUCTOR_USERNAME=98
	_INSTRUCTOR_REPONAME=97
	_BAD_ASSN=96
	_BAD_USERNAME=95
	_BAD_SLASH=94
	_BAD_HOST=93
	_BAD_COURSE=92
	_HTTPS_URL=91
	_NOT_SSH_URL=90
	_LASTNAME_FIRSTNAME=89
	_AT_SIGN=88

	local URL=$(git remote get-url origin 2>/dev/null)
	if   [[ -z $URL ]]; then return $_NO_ORIGIN
	elif [[ $URL =  https:* ]]; then return $_HTTPS_URL
	elif [[ $URL != git@* ]]; then return $_NOT_SSH_URL
	elif [[ $URL =  git@$_GIT_REMOTE_HOST/* ]]; then return $_BAD_SLASH
	elif [[ $URL != *$_GIT_REMOTE_HOST* ]]; then return $_BAD_HOST
	elif [[ $URL =  *:$_INSTRUCTOR_USERNAME/* ]]; then return $_IS_INSTRUCTOR_USERNAME
	elif [[ $URL =  */$_REPONAME* ]]; then return $_INSTRUCTOR_REPONAME
	elif [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
		if [[ $URL != */cs1440-* ]]; then return $_BAD_COURSE
		elif [[ $URL =  *LASTNAME* || $URL =  *FIRSTNAME* ]]; then return $_LASTNAME_FIRSTNAME
		elif [[ $URL = git@$_GIT_REMOTE_HOST:@* ]]; then return $_AT_SIGN
		elif [[ $URL != *-assn$_A && 
				$URL != *-assn$_A.git ]]; then return $_BAD_ASSN
		fi
	fi

	if [[ -n $_GL_USERNAME ]]; then
		if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
			if [[ $URL = git@$_GIT_REMOTE_HOST:$_GL_USERNAME/cs1440-*-assn$_A ||
				$URL = git@$_GIT_REMOTE_HOST:$_GL_USERNAME/cs1440-*-assn$_A.git ]]; then
				return 0
			elif [[ $URL != git@$_GIT_REMOTE_HOST:$_GL_USERNAME* ]]; then
				return $_BAD_USERNAME
			fi
		else
			if [[ $URL = git@$_GIT_REMOTE_HOST:$_GL_USERNAME* ]]; then
				return 0
			fi
		fi
	elif [[ -z $_GL_USERNAME ]]; then
		if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
			if [[ $URL = git@$_GIT_REMOTE_HOST:*/cs1440-*-assn$_A ||
				$URL = git@$_GIT_REMOTE_HOST:*/cs1440-*-assn$_A.git ]]; then
			return 0
			fi
		else
			if [[ $URL = git@$_GIT_REMOTE_HOST:* ]]; then
				return 0
			fi
		fi
	fi
	_tutr_generic_test -c git -n -d "$_BASE"
}

git_remote_add_hint() {
	case $1 in
		$_NO_ORIGIN)
			cat <<-:
			There is no $(_remote) called $(_origin).  Create it with
			  $(cmd git remote add origin NEW_URL).

			Replace $(cmd NEW_URL) in the above command with an address as
			described above (run $(cmd tutor hint) to review the instructions).

			:
			;;

		$_IS_INSTRUCTOR_USERNAME)
			cat <<-:
			$(_origin) points to the address of MY repo, not YOURS!

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_INSTRUCTOR_REPONAME)
			cat <<-:
			The name you gave your repo is wrong - it still contains MY name.
			
			:

			if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
				cat <<-:
				Your repository's name should include YOUR name and look like this:
				$(bld cs1440-LASTNAME-FIRSTNAME-assn$_A)

				Also, replace $(cyn LASTNAME-FIRSTNAME) with your $(bld real names)
				
				:
			fi
			cat <<-:
			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_LASTNAME_FIRSTNAME)
			cat <<-:
			Somehow I doubt those are your first and last names.

			:
			if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
				cat <<-:
				Your repository's name should include your $(bld real) name and look like this:
				$(bld cs1440-LASTNAME-FIRSTNAME-assn$_A)

				Of course, replace $(cyn LASTNAME-FIRSTNAME) with your $(bld real names).
				
				:
			fi
			cat <<-:
			Use $(cmd git remote remove origin) to erase it so you can try again.
			:
			;;

		$_AT_SIGN)
			cat <<-:
			The username you put into the URL contains an "at sign" $(kbd @).
			Your repo's URL only needs one $(kbd @), which goes near the beginning,
			like this:

			:
			if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
				if [[ -n $_GL_USERNAME ]]; then
					cat <<-:
					$(path git@$_GIT_REMOTE_HOST:$_GL_USERNAME/cs1440-LASTNAME-FIRSTNAME-assn$_A))
					:
				else
					cat <<-:
					$(path git@$_GIT_REMOTE_HOST:USERNAME/cs1440-LASTNAME-FIRSTNAME-assn$_A))

					Of course, replace $(cyn USERNAME) with your $(bld GitLab username).
					:
				fi
			else
				if [[ -n $_GL_USERNAME ]]; then
					cat <<-:
					$(path git@$_GIT_REMOTE_HOST:$_GL_USERNAME/REPONAME))
					:
				else
					cat <<-:
					$(path git@$_GIT_REMOTE_HOST:USERNAME/REPONAME))

					Of course, replace $(cyn USERNAME) with your $(bld $_GIT_REMOTE_PLAT username).
					:
				fi

			fi
			cat <<-:

			Use $(cmd git remote remove origin) to erase it and start over.
			:
			;;

		$_BAD_USERNAME)
			cat <<-:
			You entered the wrong username into the URL.

			Your $_GIT_REMOTE_PLAT username is $(bld $_GL_USERNAME), so the URL should
			look like this:
			:

			if [[ $_ENFORCE_NAMING_STANDARD == 0 ]]; then
				cat <<-:
				$(path git@$_GIT_REMOTE_HOST:$_GL_USERNAME/cs1440-LASTNAME-FIRSTNAME-assn$_A))

				Also, replace $(cyn LASTNAME-FIRSTNAME) with your $(bld real names)

				:
			else
				cat <<-:
				$(path git@$_GIT_REMOTE_HOST:$_GL_USERNAME/REPONAME))
				
				:
			fi
			cat <<-:
			Use $(cmd git remote remove origin) to erase it and start over.
			:
			;;

		# Unreachable if $_ENFORCE_NAMING_STANDARD == 0
		$_BAD_ASSN)
			cat <<-:
			This repository's name must end in $(bld "-assn$_A"), signifying that it
			is for Assignment #$_A.

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_BAD_SLASH)
			cat <<-:
			This SSH address will not work because there is a slash $(bld "'/'") between the
			hostname $(ylw $_GIT_REMOTE_HOST) and your username.  (Use $(cmd git remote -v) to
			see for yourself).

			Instead of a slash that character should be a colon $(bld "':'")

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_BAD_HOST)
			cat <<-:
			The hostname of the URL should be $(ylw $_GIT_REMOTE_HOST).

			If you push your code to the wrong Git server it will not be submitted.

			Use $(cmd git remote remove origin) to erase this and try again.
			:
			;;

		$_BAD_COURSE)
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
			_tutr_generic_hint $1 git "$_BASE"
			;;
	esac
	cat <<-:

	After you figure out what NEW_URL should be, use this command:
	  $(cmd git remote add origin NEW_URL)

	If it helps, run $(cmd git remote -v) to see $(_remote my) URL.
	Use $(cmd tutor hint) to review the instructions about the new URL.
	:
}



# There is no good way to rewind this action
# push_certificate_rw() { }

push_certificate_ff() {
	git push -u origin master
}

push_certificate_prologue() {
	cat <<-:
	Finally, push your work to your new $(_origin).
	:
}

push_certificate_test() {
	_UNTRACKED_CERT=99
	_STAGED_CERT=98
	_BRANCH_AHEAD=97
	_MISSING_CERT=96
	_MISSING_ARCHIVE=95
	_UNTRACKED_ARCHIVE=94
	_STAGED_ARCHIVE=93
	[[ "$PWD" != "$_BASE" ]] && return $WRONG_PWD
	[[ ! -f "$_BASE/certificate.txt" ]] && return $_MISSING_CERT
	_tutr_file_untracked certificate.txt && return $_UNTRACKED_CERT
	if [[ -n ${ARCHIVE[@]} ]]; then
		[[ ! -f "$_BASE/${ARCHIVE[0]}" ]] && return $_MISSING_ARCHIVE
		_tutr_file_untracked ${ARCHIVE[0]} && return $_UNTRACKED_ARCHIVE
		_tutr_file_staged ${ARCHIVE[0]} && return $_STAGED_ARCHIVE
	fi
	_tutr_file_staged certificate.txt && return $_STAGED_CERT
	_tutr_branch_ahead && return $_BRANCH_AHEAD
	return 0
}

push_certificate_hint() {
	case $1 in
		$_UNTRACKED_CERT)
			cat <<-:
			Add $(path certificate.txt) to the next commit with $(cmd git add certificate.txt).
			:
			;;

		$_STAGED_CERT)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the certificate to the
			$(_Git) repository.
			:
			;;

		$_MISSING_CERT)
			cat <<-:
			Uh-oh!  Where did $(path certificate.txt) go?  It needs to be in the root of
			this repository.  Find it and put it back here!

			Alternatively, you can just re-create it by running
			  $(cmd ./make-certificate.sh).
			:
			;;

		$_UNTRACKED_ARCHIVE)
			cat <<-:
			Add $(path ${ARCHIVE[0]}) to the next commit with $(cmd git add ${ARCHIVE[0]}).
			:
			;;

		$_STAGED_ARCHIVE)
			cat <<-:
			Run $(cmd 'git commit -m "..."') to permanently save the archive and
			certificate in the $(_Git) repository.
			:
			;;

		$_MISSING_ARCHIVE)
			cat <<-:
			Uh-oh!  Where did $(path ${ARCHIVE[@]}) go?  It needs to be in the root of
			this repository.  Find it and put it back here!

			Alternatively, you can just re-create it by running
			  $(cmd ./make-certificate.sh).
			:
			;;

		$_BRANCH_AHEAD)
			cat <<-:
			Now run $(cmd git push -u origin master) to submit the certificate to $(_GitPlat).
			:
			;;

		$WRONG_PWD)
			_tutr_minimal_chdir_hint "$_BASE"
			;;

		*)
			cat <<-:
			As a reminder, the steps of your $(_Git) workflow are
			  0. $(cmd git add certificate.txt)
			  1. $(cmd 'git commit -m "Brief commit message"')
			  2. $(cmd git push -u origin master)

			:
			;;

	esac
}

push_certificate_epilogue() {
	browse_repo
	if [[ -n ${ARCHIVE[@]} ]]; then
		cat <<-:

		Before you finish, go look at the repository on $(_GitPlat) to make sure the
		certificate and archive both arrived safely.

		:
	else
		cat <<-:

		Before you finish, go look at the repository on $(_GitPlat) to make sure your
		certificate arrived safely.

		:
	fi
	_tutr_pressenter
}



cleanup() {
	_tutr_lesson_complete_msg $1 "You are done with Assignment #$_A!"
}



source main.sh && _tutr_begin \
	make_certificate \
	commit_certificate \
	git_remote_rename \
	git_remote_add \
	push_certificate \


# vim: set filetype=sh noexpandtab tabstop=4 shiftwidth=4 textwidth=76 colorcolumn=76:
