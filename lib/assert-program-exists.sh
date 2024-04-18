_cmd_not_found() {
	cat <<-:
	The required program [0;32m$1[0m was not found.

	Contact $_EMAIL for help.
	:
}


_tutr_assert_program_exists() {
	if [[ -z $1 ]]; then
		cat <<-:
		Usage: $0 PROGRAM_NAME [ERROR_MESSAGE_CMD]
		:
		return
	fi

	if ! which $1 &>/dev/null; then
		if [[ -n $2 ]]; then
			_tutr_die $2 $1
		else
			_tutr_die _cmd_not_found $1
		fi
	fi
}


_tutr_warn_if_program_missing() {
	if [[ -z $1 ]]; then
		cat <<-:
		Usage: $0 PROGRAM_NAME [ERROR_MESSAGE_CMD]
		:
		return
	fi

	if ! which $1 &>/dev/null; then
		if [[ -n $2 ]]; then
			_tutr_warn $2 $1
		else
			_tutr_warn _cmd_not_found $1
		fi
        _tutr_pressenter
	fi
}
