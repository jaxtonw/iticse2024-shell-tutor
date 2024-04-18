# Multiple-choice quiz.  Shuffle arguments and present user with a menu of
# choices.  The first argument is the "correct" response.
# Accepts quoted strings as responses/distractors.
#
# Returns success when user makes correct choice.
# This function does not print the question/prompt
#
# Usage:
#   _tutr_quiz CORRECT_RESPONSE DISTRACTOR ...
#
_tutr_quiz() {
    if (( $# < 2 )); then
        echo "_tutr_quiz requires at least two arguments"
        return 1
    fi

    local correct=$1
    shift
    local IFS=$'\n'
    declare -a responses=( $(printf '%s\n' $correct $@ | sort -R) )

    select R in ${responses[*]} "I give up"; do
        if [[ $R = $correct ]]; then
            echo "You got it!"
            return 0
        elif [[ $R = "I give up" ]]; then
            return 6
        else
            echo "That is incorrect"
            return 1
        fi
    done
}
