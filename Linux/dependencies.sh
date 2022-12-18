#!/bin/bash

# Constants:
readonly SCRIPT_NAME="YT-DL cli dependencies"
readonly SCRIPT_VERSION="v1.1"
readonly SCRIPT_VERSION_DATE="18.12.2022"

# Functions:
function detect_ditro
{
    echo $(lsb_release -is)
}

function confirm_choice
{
	read -p "Do you want to continue? [Y/n] " reply
	
	if [[ "$reply" != "n" && "$reply" != "N" ]]; then
		echo 1
	else
		echo 0
	fi
}

function menu_debian_based
{
	clear
	echo -e "[Install dependencies: Debian based distros]\n"

	local confirmed="$(confirm_choice)"
	
	if [[ "${confirmed}" -ne 1 ]]; then
	    echo -e "Aborted.\n"
	    exit
	fi
	
	echo -e "Accepted.\n"
	
	sudo apt install wget ffmpeg jq
	
	sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
	
	echo -e "Finished!\n"
	exit
}

function menu_arch_based
{
	clear
	echo -e "[Install dependencies: Arch based distros]\n"
	
	local confirmed="$(confirm_choice)"
	
	if [[ "${confirmed}" -ne 1 ]]; then
	    echo -e "Aborted.\n"
	    exit
	fi
	
	echo -e "Accepted.\n"
	
	sudo pacman -S wget ffmpeg jq youtube-dl
	
	echo -e "Finished!\n"
	exit
}


function menu_quit
{
	clear
	exit
}

function show_menu
{
	local detected_distro="$(detect_ditro)"

	clear
	echo -e "" \
			"|      ${SCRIPT_NAME}      |\n" \
			"|      ${SCRIPT_VERSION} (${SCRIPT_VERSION_DATE})           |\n"

	echo -e "" \
			"Detected distro: ${detected_distro}\n" \
			""
			
	echo -e "Choose what you want to do:"
	PS3='> '
	menu=(
		"Install dependencies: Debian based distros"	# (1)
		"Install dependencies: Arch based distros"		# (2)
		"Quit"				        					# (3)
	)
	
	COLUMNS=12
	select option in "${menu[@]}"
	do
		case $REPLY in
			1)
				menu_debian_based
				;;
			2)
				menu_arch_based
				;;
			3)
				menu_quit
				;;
			*)
				echo "Please choose valid option (1-3)."
				;;
		esac
	done
}

show_menu