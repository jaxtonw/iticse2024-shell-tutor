# Determine the type of a command (alias, builtin, function, external program, etc.)
# Stores the result into $REPLY
_tutr_type() {
	if [[ -z $1 ]]; then
		echo "Usage: _type CMD"
		return 1
	fi

	case "$(builtin type $1)" in
		*alias*) REPLY=alias ;;
		*function*) REPLY=function ;;
		*builtin*) REPLY=builtin ;;
		*"not found"*) REPLY="not found" ;;
		*word*) REPLY=keyword ;;
		*) REPLY=external ;;
	esac
}
