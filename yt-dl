#!/bin/bash

# This script requires the 'youtube-dl' and 'ffmpeg' packages.
# Make sure you already have installed all of them.

# Config variables
config_saving_dir="./download/"
config_saving_file_name="%(title)s.%(ext)s"
config_saving_audio_format="mp3"
config_saving_audio_quality=0 # 0 - Best | 10 - Worst

function dl_url
{
	youtube-dl -o "${config_saving_dir}${config_saving_file_name}" -x --audio-format $config_saving_audio_format --audio-quality $config_saving_audio_quality $1
}

function show_menu
{
	clear
	echo -e "YT-DL (cli)\n"

	PS3='> '
	menu=("Download the song (URL)" "Search the song (Title)" "Update the youtube-dl" "Quit")
	
	select option in "${menu[@]}"
	do
		case $REPLY in
			1 )
				menu_url
				;;
			2 )
				menu_search
				;;
			3 )
				menu_update
				;;
			4 )
				menu_quit
				;;
			* )
				echo "Please choose valid option (1-4)."
				;;
		esac
	done
}

function menu_url
{
	echo -e "\n[Download the song (URL)]\n"

	echo "Please enter the song URL."
	read -p "> " song_url
	echo ""
	
	dl_url $song_url

	echo ""
	read -n 1 -s -r -p "Press any key to continue..."

	show_menu
}

function menu_search
{
	echo -e "\n[Search the song (Title)]\n"

	#TODO

	read -n 1 -s -r -p "Press any key to continue..."
	show_menu
}

function menu_update
{
	echo -e "\n[Update the youtube-dl]\n"

	#TODO

	read -n 1 -s -r -p "Press any key to continue..."
	show_menu
}

function menu_quit
{
	exit
}

show_menu
