#!/bin/bash

# This script requires following packages: 'youtube-dl', 'ffmpeg', 'jq'.
# Make sure you have already installed them before using the script.
# To automate process of installing dependencies you can launch the 'dependencies.sh' script.

# Constants:
readonly SCRIPT_NAME="YT-DL cli"
readonly SCRIPT_VERSION="v1.1"
readonly SCRIPT_VERSION_DATE="18.12.2022"
readonly CONFIG_PATH=~/.config/yt-dl.json

# Variables:
# - Config related
config_saving_dir=~/download			    # Songs destination directory
config_saving_file_name="%(title)s.%(ext)s"	# Songs file name format
config_saving_audio_format="mp3"		    # Songs file extension
config_saving_audio_quality=0			    # Best quality = 0, Worst quality = 10
config_searching_results_count=6		    # How much results should be displayed when searching by title
config_youtube_dl="youtube-dl"				# Path to your youtube-dl binary

# - Found songs by title searching 
songs=()

# Functions:
# - Backend
function download_song
{
	"${config_youtube_dl}" -o "${config_saving_dir}/${config_saving_file_name}" -x --audio-format "$config_saving_audio_format" --audio-quality "$config_saving_audio_quality" "$1"
}

function is_url_valid
{
    regex='(https|http)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

    [[ "$1" =~ $regex ]]
}

function search_songs
{
	songs=()
	local search_results=$(mktemp)

	"${config_youtube_dl}" -j --default-search "ytsearch${config_searching_results_count}" "$1" \
		| jq '{title:.fulltitle, url: .webpage_url}' \
		> $search_results

	local line_number=0
	local temp_string=""
	while IFS= read -r line
	do
		line_number=$((line_number+1))
		temp_string="${temp_string}${line}"

		if [ $(( $line_number % 4 )) -eq 0 ]; then
			songs[${#songs[@]}]=$(jq '.' <(echo "$temp_string"))
			temp_string=""
		fi
	done < "$search_results"

	rm $search_results
}

function show_found_songs
{
	local number=0
	local title=""
	for i in "${!songs[@]}"; do
		number=$((i+1))
		title=$(jq '.title' <(echo "${songs[$i]}"))
		echo "$number) $title"
	done
	echo "0) Back to Main menu"
}

function detect_distro
{
	echo $(lsb_release -is)
}

function update_youtubedl
{
	distro=$(detect_distro)
	
	case $distro in
		"Debian" | "Ubuntu" | "Kali" | "Mint")
			sudo "${config_youtube_dl}" -U
			;;
		"Arch" | "ManjaroLinux")
			sudo pacman -S youtube-dl
			;;
		*)
			echo -e "The script could not to detect your distro (${distro})!\n" \ 
				"Please update youtube-dl manually."
			;;
	esac
}

function create_config
{
	echo -e $(jq -n \
		--arg saving_dir $config_saving_dir \
		--arg saving_file_name $config_saving_file_name \
		--arg saving_audio_format $config_saving_audio_format \
		--arg saving_audio_quality $config_saving_audio_quality \
		--arg searching_results_count $config_searching_results_count \
		--arg youtube_dl $config_youtube_dl \
		'{$saving_dir, $saving_file_name, $saving_audio_format, $saving_audio_quality, $searching_results_count, $youtube_dl}') | jq . > "$1"
}

function load_config
{
	if [ ! -f $CONFIG_PATH ]; then
		local config_dir=${CONFIG_PATH%/*}
		mkdir -p $config_dir

		touch $CONFIG_PATH
		create_config $CONFIG_PATH
	fi

	config_saving_dir=$(jq '.saving_dir' $CONFIG_PATH | tr -d '"')
	config_saving_file_name=$(jq '.saving_file_name' $CONFIG_PATH | tr -d '"')
	config_saving_audio_format=$(jq '.saving_audio_format' $CONFIG_PATH | tr -d '"')
	config_saving_audio_quality=$(jq '.saving_audio_quality' $CONFIG_PATH | tr -d '"')
	config_searching_results_count=$(jq '.searching_results_count' $CONFIG_PATH | tr -d '"')
	config_youtube_dl=$(jq '.youtube_dl' $CONFIG_PATH | tr -d '"')	
}

function check_downloaded_songs_dir
{
	if [[ ! -d "$config_saving_dir" ]]; then
		mkdir -p "$config_saving_dir"
		echo -e "Songs directory has been created automatically.\n"
	fi
}

function show_downloaded_songs
{
	local found_songs_array=()
	local found_songs_count=0

	if [[ -d "$config_saving_dir" ]]; then
		local found_songs=$(find "${config_saving_dir}" -type f -name "*.${config_saving_audio_format}" | sort)
		if [[ -n "${found_songs}" ]]; then
			readarray -t found_songs_array <<< "$found_songs"
			found_songs_count="${#found_songs_array[@]}"
		fi
	fi

	echo -e "Songs directory '${config_saving_dir}':\n"

	for song in "${found_songs_array[@]}"
	do
		local song_filename=$(basename "${song}")
		echo -e " ${song_filename}"
	done

	echo -e "\nFound ${found_songs_count} song(s) in total."
}

function press_any_key
{
	echo ""
	read -n 1 -s -r -p "Press any key to continue..."
}

# - Menu:
function show_menu
{
	clear
	echo -e "|      ${SCRIPT_NAME}      |\n"

	PS3='> '
	menu=(
		"Download the song (URL)"	# (1)
		"Search the song (Title)" 	# (2)
		"Update the youtube-dl"		# (3)
		"Show the downloaded songs"	# (4)
		"About"				        # (5)
		"Quit"				        # (6)
	)
	
	COLUMNS=12
	select option in "${menu[@]}"
	do
		case $REPLY in
			1)
				menu_url
				;;
			2)
				menu_search
				;;
			3)
				menu_update
				;;
			4)
				menu_downloaded
				;;
			5)
				menu_about
				;;
			6)
				menu_quit
				;;
			*)
				echo "Please choose valid option (1-6)."
				;;
		esac
	done
}

function menu_url
{
	clear
	echo -e "[Download the song (URL)]\n"

	echo "Please enter the song URL."

	local song_url=""
	while ! is_url_valid "$song_url"
	do
		read -p "> " song_url
	done 
	echo ""
	
	download_song "$song_url"

	press_any_key
	show_menu
}

function menu_search
{
	clear
	echo -e "[Search the song (Title)]\n"

	echo "Please enter the song's title."

	local title=""
	while [[ $title == "" ]]
	do
		read -p "> " title
	done 
	echo ""

	search_songs $title
	echo "Please choose the song's number:"
	show_found_songs

	read -p "> " song_number
	echo ""

	if [ $song_number -eq 0 ]; then
		show_menu
		return 0
	fi

	local song_index=$((song_number-1))
	local song_url=$(jq '.url' <(echo "${songs[song_index]}") | tr -d '"')

	download_song "$song_url"

	press_any_key
	show_menu
}

function menu_update
{
	clear
	echo -e "[Update the youtube-dl]\n"

	echo "Updating the youtube-dl."
	echo ""

	update_youtubedl

	press_any_key
	show_menu
}

function menu_downloaded
{
	clear
	echo -e "[Show the downloaded songs]\n"

	check_downloaded_songs_dir
	show_downloaded_songs

	press_any_key
	show_menu
}

function menu_about
{
	clear
	echo -e "[About]\n"

	echo -e ""\
		"NAME:\t\t${SCRIPT_NAME}\n" \
		"VERSION:\t${SCRIPT_VERSION} (${SCRIPT_VERSION_DATE})\n" \
		"DESCRIPTION:\n" \
		"\n" \
		" Shell script that lets you to download videos from YouTube as songs.\n" \
		" Currently available features are:\n" \
		" - Searching videos by their title\n" \
		" - Downloading videos by direct link\n" \
		"\n" \
		" Your songs will be stored to directory:\n" \
		"  '${config_saving_dir}'\n" \
		" Your configuration file is stored in:\n" \
		"  '${CONFIG_PATH}'"

	press_any_key
	show_menu
}

function menu_quit
{
	clear
	exit
}

load_config
show_menu
