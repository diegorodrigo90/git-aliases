#! /bin/bash

# Colors.
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_RESET="\e[0m"

# Files.
SHELLS=( ~/.zshrc ~/.bashrc)
GIT_ALIAS_FILE=~/.git_aliases

GIT_ALIASES_SOURCE="[ -f "${GIT_ALIAS_FILE}" ] && source "${GIT_ALIAS_FILE}""

git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?


# Display Help message.
Help()
{
    echo
    echo "info: this script add some git aliases for you."
    echo
    echo "usage $0"
    echo

    echo -e "${COLOR_GREEN}Commands:${COLOR_RESET}"
    echo "--help, -h          show this help."
    echo "--uninstall, -u     uninstall this script."
    echo
}

# Options strings.
SHORT=hu
LONG=help,uninstall

# Read the options.
OPTS=$(getopt --options $SHORT --long $LONG -- "$@")

# Invalid option.
if [ $? != 0 ] ;
then
    echo
    echo -e  "${COLOR_RED}Invalid option!${COLOR_RESET}"
    Help >&2 ;
    exit 1 ;
fi

eval set -- "$OPTS"

# Set initial values.
UNINSTALL=false

# Get the options
# Extract options into variables.
while true ; do
    case "$1" in
        -h | --help) # Display Help
            Help
        exit 1;;

        -u | --uninstall) # Enter a name
            UNINSTALL=true
        break ;;
        * ) # No option.
        break ;;
    esac
done

# Join array.
function join { local IFS="$1"; shift; echo "$*"; }

# Cancel on sudo.
if [ "$(id -u)" -eq 0 ]
then
    if [ -n "$SUDO_USER" ]
    then
        # Error message for no git installed.
        whiptail --title "Error!" --msgbox "This script should not be run with sudo!" 8 80
        exit 1
    fi
fi

# Run if git is installed.
if [ $GIT_IS_AVAILABLE -eq 0 ]; then
    #  Create git alias.
    function addAliasGit {
        local alias=$1
        local command=$2

        if git config --get-regexp ^alias | grep "alias.${alias} ${command}" > /dev/null
        then
            echo -e "Alias ${COLOR_GREEN}git "${alias}"${COLOR_RESET} is already installed."
        else
            # Documentation
            # https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases
            git config --global alias."${alias}" "${command}"
            echo -e "You can use the comand ${COLOR_GREEN}git "${command}"${COLOR_RESET} as ${COLOR_GREEN}git "${alias}"${COLOR_RESET}."
        fi
    }

    #  Create git alias.
    function removeAliasGit {
        local alias=$1
        local command=$2

        if git config --get-regexp ^alias | grep "alias.${alias} ${command}" > /dev/null
        then
            git config --global --unset alias."${alias}" "${command}"
            echo -e "Alias ${COLOR_GREEN}git "${alias}"${COLOR_RESET} removed."
        else
            echo -e "Alias ${COLOR_GREEN}git "${alias}"${COLOR_RESET} not installed."
        fi
    }


    # Create alias.
    function addAlias {
        local alias="$1"
        local command="$2"

        # Add if alias not exists.
        if ! grep -Ewq "alias ${alias}=" "${GIT_ALIAS_FILE}"  2> /dev/null
        then
            echo "alias ${alias}=\""${command}"\"" >> "${GIT_ALIAS_FILE}"
            echo -e "You can use the comand ${COLOR_GREEN}"${command}"${COLOR_RESET} as ${COLOR_GREEN}"${alias}"${COLOR_RESET}."
        else
            echo -e "Alias ${COLOR_GREEN}"${alias}"${COLOR_RESET} is already installed."
        fi
    }

    # Remove alias.
    function removeAlias {

        if [ -f "${GIT_ALIAS_FILE}" ];
        then
            rm "${GIT_ALIAS_FILE}"
            echo -e "Alias file  ${COLOR_GREEN}removed${COLOR_RESET}."
        fi
    }

    TITLE_MSG="Install Git aliases"

    BEFORE_RUN_MSG="This script will install some custom git aliases for you, all them are listed in README file. Proceed with installation?"

    # Change message for uninstall.
    if [ "$UNINSTALL" = true ] ;
    then
        TITLE_MSG="Uninstall Git aliases"

        BEFORE_RUN_MSG="You are abouit to  UNINSTALL the installed git aliases. Proceed with UNINSTALL?"
    fi


    # Ask for user confirmation before install.
    if (whiptail --title "${TITLE_MSG}" --yesno "${BEFORE_RUN_MSG}" 8 78); then

        mapfile -t git_aliases < git-alias.txt

        # Remove empty values.
        for i in ${!shell_aliases[@]}; do [[ -z ${shell_aliases[i]} ]] && unset shell_aliases[i]; done

        ## Add git aliases.
        for alias in "${git_aliases[@]}";
        do
            :
            a=($(echo "${alias}" | tr '=' '\n'))
            alias="${a[0]}"
            text=$(join " " ${a[@]})
            comand=$(echo "${text}"|sed 's/'${alias}'//'|sed 's/'$" "'//')


            if [ "$UNINSTALL" = true ] ;
            then
                removeAliasGit "${alias}" "${comand}"
            else
                addAliasGit "${alias}" "${comand}"
            fi

        done

        mapfile -t shell_aliases < shell-alias.txt

        # Remove empty values.
        for i in ${!shell_aliases[@]}; do [[ -z ${shell_aliases[i]} ]] && unset shell_aliases[i]; done

        ## Add shell aliases.
        for alias in "${shell_aliases[@]}";
        do
            :
            a=($(echo "${alias}" | tr '=' '\n'))
            alias="${a[0]}"
            text=$(join " " ${a[@]})
            comand=$(echo "${text}"|sed 's/'${alias}'//'|sed 's/'$" "'//')

            if [ "$UNINSTALL" = true ] ;
            then
                removeAlias # No arguments needed, it will remove entire file.
            else
                addAlias "${alias}" "${comand}"
            fi

        done

        if [ "$UNINSTALL" = true ] ;
        then
            # Loop in SHELLS array.
            for i in "${SHELLS[@]}"
            do :
                if [ -f "${i}" ];
                then
                    # Add if alias not exists.
                    if grep -Ewq "${GIT_ALIASES_SOURCE}" ${i}
                    then
                        grep -v "${GIT_ALIASES_SOURCE}" "${i}" > tmpfile && mv tmpfile "${i}"
                        echo -e "Aliases removed from ${COLOR_GREEN}"${i}"${COLOR_RESET}."
                    fi
                fi
            done
        else
            # Loop in SHELLS array.
            for i in "${SHELLS[@]}"
            do :
                if [ -f "${i}" ];
                then
                    # Add if alias not exists.
                    if ! grep -Ewq "${GIT_ALIASES_SOURCE}" ${i}
                    then
                        echo -e "\n${GIT_ALIASES_SOURCE}" >> ${i}
                        echo -e "Aliases added to ${COLOR_GREEN}"${i}"${COLOR_RESET}."
                    fi
                fi
            done

            notify-send 'Git aliases' 'All git aliases are installed!' 2> /dev/null
            echo -e "${COLOR_GREEN}Done! All aliases are installed!!${COLOR_RESET}"
        fi

    else
        echo "Installation canceled."
        exit 0
    fi

else
    # Error message for no git installed.
    whiptail --title "Error!" --msgbox "This script requires to have git installed. Please install and run this script again." 8 80
    exit 1
fi
