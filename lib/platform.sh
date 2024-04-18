# variables that identify system features
# _OS   - OS type (Linux, Mac, or Windows)
# _PLAT - Platform (like OS but disambiguates Linux from WSL, and Git+Bash from Cygwin)
# _ARCH - Architecture (x86 vs. ARM)
# _SH   - Shell (Bash vs. Zsh)

case $(uname -s) in
    Darwin)
        typeset -r _OS=MacOSX
        typeset -r _PLAT=Apple
        ;;
    *MINGW*)
        typeset -r _OS=Windows
        typeset -r _PLAT=MINGW
        ;;
    *CYGWIN*)
        typeset -r _OS=Windows
        typeset -r _PLAT=Cygwin
        ;;
    Linux)   
        typeset -r _OS=Linux
        if [[ -n $WSL_DISTRO_NAME || -n $WSL_INTEROP ]]; then
            typeset -r _PLAT=WSL
        else
            typeset -r _PLAT=Linux
        fi
        ;;
    *)
        typeset -r _OS=unknown
        typeset -r _PLAT=unknown
        ;;
esac

typeset -r _ARCH=$(uname -m)

case $SHELL in
    *zsh)  typeset -r _SH=Zsh ;;
    *bash) typeset -r _SH=Bash ;;
    *)     typeset -r _SH=unknown ;;
esac

export _OS _PLAT _ARCH _SH
