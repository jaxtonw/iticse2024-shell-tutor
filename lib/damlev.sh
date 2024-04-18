# An implementation of the Damerau-Levenshtein algorithm.  Works with Bash>=4.0 and Zsh.
#
# Translated from pseudocode into Shell by Erik Falor, June 2021
# https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Distance_with_adjacent_transpositions
#
# Tested in Bash versions 3.2(known not to work), 4.0, 4.3, 4.4, 4.4.18, 5.0, 5.1, 5.1.8
# Tested in Zsh versions 5.2, 5.3.1, 5.4.2, 5.5.1, 5.6.2, 5.7, 5.8


# Usage: 
#  _tutr_damlev WORD1 WORD2 [THRESHHOLD]
#
# When called with 2 arguments, print the Damerau-Levenshtein distance on STDOUT.
#
# When called with 3 arguments, quietly return 0 or 1 indicating the distance
# is greater than the provided threshhold
function _tutr_damlev {
    if [[ -n $BASH_VERSION && ${BASH_VERSINFO[0]} -lt 4 ]]; then
        # Bash <= 3.2 doesn't have associative arrays
        1>&2 echo "Error: your shell does not support associative arrays"
        return 127
    fi

    if (( $# < 2 )); then
        echo "Usage: _tutr_damlev word1 word2 [threshhold]" >&2
    elif (( ${#1} < ${#2} )); then
        _tutr_damlev "$2" "$1" $3
        return $?
    elif (( ${#2} == 0 )); then
        # When arg $2 is empty, Bash prints an error:
        #   DA[${2:${j}-1:1}]: bad array subscript
        return ${#1}
    else
        local A=$1
        local B=$2
        local lenA=${#A}
        local lenB=${#B}
        local INF=$(( lenA + lenB + 1))

        # Initialize tables
        # H  := the distance table 
        # DA := associated array of |Σ| integers;
        #   key   = the alphabet of the two commands
        #   value = the last i position in A when the letter was considered
        local -A H DA
        local i
        local lenH=$(( (lenA+1)*(lenB+1) ))
        local stride=$((lenA+1))
        for (( i=0; i<=lenH; i++ )); do
            H[$i]=0
        done

        for (( i=0; i<=lenA; i++ )); do
            H[$i]=$i
            DA[${1:${i}-1:1}]=0
        done

        local j
        for (( j=0; j<=lenB; j++ )); do
            H[$((j*stride))]=$j
            DA[${2:${j}-1:1}]=0
        done

        local del ins alt xpose cost min
        for (( i=1; i<=lenA; i++ )); do
            # DB is the last j position when A[i] == B[j]
            local DB=0
            for (( j=1; j<=lenB; j++ )); do
                # compute cost of deletion & insertion
                del=$(( H[$(((i-1) + j*stride))]+1 ))
                ins=$(( H[$((i + (j-1)*stride))]+1 ))

                # check whether A[i] == B[j]
                local j1=$DB
                [[ "${1:${i}-1:1}" = "${2:${j}-1:1}" ]] && (( cost=0, DB=j )) || cost=1

                # compute cost of altering the letter
                alt=$(( H[$(((i-1) + (j-1)*stride))]+cost ))

                # compute cost of transposition
                local i1=${DA[${B:${j}-1:1}]}
                if (( i1-1 >= 0 && j1-1 >= 0 )); then
                    #    d[k−1, ℓ−1] + (i−k−1) + 1 + (j-ℓ−1)) //transposition
                    xpose=$(( H[$(((i1-1) + (j1-1)*stride))] + (i-i1-1) + 1 + (j-j1-1) ))
                else
                    xpose=$INF
                fi

                # find the lowest cost and store in the distance table
                (( del < ins )) && min=$del || min=$ins
                (( alt < min )) && min=$alt
                (( xpose < min )) && min=$xpose
                H[$((i+stride*j))]=$min
            done

            # update the alphabet table
            DA[${1:${i}-1:1}]=$i
        done
        local dist=${H[$((lenA + stride*lenB))]}


        if (( $# == 3 )); then
            # When a threshhold is given, return True if the distance falls
            # within the threshhold
            (( dist != 0 && dist <= $3 ))
        else
            # Otherwise, display the computed distance
            echo $dist
        fi
    fi
}
