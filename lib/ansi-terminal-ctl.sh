# ANSI terminal color escape codes and functions
#
# Functions echo their arguments sandwiched between a color escape and the
# reset code.  This means that nesting function calls may not work as espected.
# If you want to do something complex, use variables

## Reset colors/effects
_Z="[0m"
_z="[0m"


## Terminal effects
# underline
_u="[4m"
unl()  { echo ${_u}$*${_Z} ; }

# bold/bright
_o="[1m"
bld()  { echo ${_o}$*${_Z} ; }

# BOLD reverse video/standout
_v="[1;7m"
rev()  { echo ${_v}$*${_Z} ; }


## Colors
# Variables with lower-case names are dim colors
# Upper-case names are bright/bold colors
# Functions ending in _ are low/dim colors

# black
_k="[0;30m"
_K="[1;30m"
blk_() { echo ${_k}$*${_Z} ; }
blk()  { echo ${_K}$*${_Z} ; }

# red
_r="[0;31m"
_R="[1;31m"
red_() { echo ${_r}$*${_Z} ; }
red()  { echo ${_R}$*${_Z} ; }

# green
_g="[0;32m"
_G="[1;32m"
grn_() { echo ${_g}$*${_Z} ; }
grn()  { echo ${_G}$*${_Z} ; }

# yellow
_y="[0;33m"
_Y="[1;33m"
ylw_() { echo ${_y}$*${_Z} ; }
ylw()  { echo ${_Y}$*${_Z} ; }

# blue
_b="[0;34m"
_B="[1;34m"
blu_() { echo ${_b}$*${_Z} ; }
blu()  { echo ${_B}$*${_Z} ; }

# magenta
_m="[0;35m"
_M="[1;35m"
mgn_() { echo ${_m}$*${_Z} ; }
mgn()  { echo ${_M}$*${_Z} ; }

# cyan
_c="[0;36m"
_C="[1;36m"
cyn_() { echo ${_c}$*${_Z} ; }
cyn()  { echo ${_C}$*${_Z} ; }

# white
_w="[0;37m"
_W="[1;37m"
wht_() { echo ${_w}$*${_Z} ; }
wht()  { echo ${_W}$*${_Z} ; }


## Semantic colors
# Use these functions for common features across all lessons.  This improves
# consistency, increases readability, and prevents errors.
cmd()  { echo ${_g}$*${_Z} ; }
err()  { echo ${_r}$*${_Z} ; }
path() { echo ${_u}$*${_Z} ; }
kbd()  { echo ${_m}$*${_Z} ; }
var()  { echo ${_c}$*${_Z} ; }
DuckieCorp() { echo ${_Y}DuckieCorp${_z} ; }
_py() { (( $# == 0 )) && echo $(ylw_ Python) || echo $(ylw_ $*) ; }

## User defined colors
# Lesson developers should define functions to simplify coloring and to improve
# readability.
#
# These functions print either its own name in its characteristic color, or
# colors its arguments:
# username() { (( $# == 0 )) && echo $(mgn username) || echo $(mgn $*); }
# password() { (( $# == 0 )) && echo $(ylw password) || echo $(ylw $*); }
