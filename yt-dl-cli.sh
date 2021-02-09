#!/bin/bash

function show_menu
{
	clear
	echo "YT-DL (cli)"

	PS3='> '
	options=("Download song (URL)" "Search song" "Update youtube-dl" "Quit")
	
	select opt in "${options[@]}"
	do
		case $REPLY in
			1 )
				dl_url
				;;
			2 )
				dl_search
				;;
			3 )
				update
				;;
			4 )
				quit
				;;
			* )
				echo "Please choose 1-4 option."
				;;
		esac
	done
}

function dl_url
{
	echo "Downloading from url"
	read $asdf
	show_menu
}

function dl_search
{
	echo "Searching a song ..."
	read $asdf
	show_menu
}

function update
{
	echo "Updating the youtube-dl"
	read $asdf
	show_menu
}

function quit
{
	echo "Quiting..."
	exit
}

show_menu
