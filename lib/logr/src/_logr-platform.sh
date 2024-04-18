# TODO: Cite properly FROM: Shell Tutor
# variables that identify system features
# __LOGR_OS   - OS type (Linux, Mac, or Windows)
# __LOGR_PLAT - Platform (like OS but disambiguates Linux from WSL, and Git+Bash)
# __LOGR_ARCH - Architecture (x86 vs. ARM)
# __LOGR_SH   - Shell (Bash vs. Zsh)

case $(uname -s) in
    Darwin)
        __LOGR_OS=MacOSX
        __LOGR_PLAT=Apple
        ;;
    *MINGW*)
        __LOGR_OS=Windows
        __LOGR_PLAT=MINGW
        ;;
    Linux)   
        __LOGR_OS=Linux
        if [[ -n $WSL_DISTRO_NAME || -n $WSL_INTEROP ]]; then
            __LOGR_PLAT=WSL
        else
            __LOGR_PLAT=Linux
        fi
        ;;
    *)
        __LOGR_OS=unknown
        __LOGR_PLAT=unknown
        ;;
esac

__LOGR_ARCH=$(uname -m)

case $SHELL in
    *zsh)
        __LOGR_SH=Zsh
        __LOGR_SH_VERSION=$ZSH_VERSION
        __LOGR_SH_VERSION_MAJ=${ZSH_VERSION%%.*}
        ;;
    *bash) 
        __LOGR_SH=Bash
        __LOGR_SH_VERSION=$BASH_VERSION
        __LOGR_SH_VERSION_MAJ=${BASH_VERSINFO[0]}
        ;;
    *)     
        __LOGR_SH=unknown
        __LOGR_SH_VERSION=?
        __LOGR_SH_VERSION_MAJ=?
        ;;
esac


export __LOGR_OS __LOGR_PLAT __LOGR_ARCH __LOGR_SH __LOGR_SH_VERSION __LOGR_SH_VERSION_MAJ
