# Utility functions that guarantee cross-platform compatability

_logrf_currTimeMillis() {
	if [[ $__LOGR_SH == Zsh ]]; then
        print -P %D{%s.%6.} # 6 decimal points matches output of $EPOCHREALTIME
    elif [[ $__LOGR_SH == Bash ]] && (( $__LOGR_SH_VERSION_MAJ >= 5 )); then
        echo $EPOCHREALTIME
    else
        command date +"%s.%6N" # 6 decimal points matches output of $EPOCHREALTIME
    fi
}

_logrf_currTimeSec() {
	command date +"%s"
}

_logrf_uuidGen() {
    # Will print out a brand new UUID
    # Credit to markusfish on GitHub
    # https://gist.github.com/markusfisch/6110640

	local N B C='89ab'

	for (( N=0; N < 16; ++N ))
	do
		B=$(( $RANDOM%256 ))

		case $N in
			6)
				printf '4%x' $(( B%16 ))
				;;
			8)
				printf '%c%x' ${C:$RANDOM%${#C}:1} $(( B%16 ))
				;;
			3 | 5 | 7 | 9)
				printf '%02x-' $B
				;;
			*)
				printf '%02x' $B
				;;
		esac
	done

	echo
}