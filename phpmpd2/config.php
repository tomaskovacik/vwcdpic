<?php
/* some helpers for phpMpReloaded */
/*define('__PHPMPRELOADED_MPD_SETTINGS__', '../../config/mpd_config.php' );
define('__PHPMPRELOADED_CLIENT_SWITCHER__', '../../lib/ClientSwitcher.php');
if (file_exists( __PHPMPRELOADED_MPD_SETTINGS__ )){
	include(__PHPMPRELOADED_MPD_SETTINGS__);
}*/

$configuration = array(
// NEED TO SET THESE!
	//"mpd_host" => $mpd_host, //The host where mpd is being run.
	"mpd_host" => "localhost", //The host where mpd is being run.
	//"mpd_port" => $mpd_port, //The port which mpd is listening on.
	"mpd_port" => "6600", //The port which mpd is listening on.

// GENERAL
	"time_elapsed" => true, //Set to true to display elapsed time, false to display remaining time.
	"title" => "", //Title of the webpage.
	"font_size" => "12pt", //Font size.
	"auto_refresh" => true, //Set to true to cause the status page to automatically refresh every [refresh_freq] seconds.
	"refresh_freq" => 10, //Number of seconds between auto-refreshes.
	"use_cookies" => true, //Pretty much has to be true to function correctly. (Don't complain if you get problems setting this to false)

// VISUAL STYLE
	"layout" => "2column", //A directory in the layouts/ directory.
	"style" => "dark", //A directory in the styles/ directory.
	"add" => "add", //What to display in place of "add" in the "Function" column.
	"delete" => "", //What to display in place of "delete" in the "Function" column.
	"update" => "", //What to display in the "Update" column in the directory listing.
	"playlist_lines" => 10, //Number of lines shown in the playlist.
	"reset_on_next_song" => true, //Automatically resets the playlist view to center on the current song when the next song starts.

// OUTPUT FORMATTING
	"filenames_only" => false, //Show only the filename of the current song.
	"filenames_replace_underscores" => true, //Replace '_' with ' ' in filenames.
	"show_directory_columns" => false, //Display column headers in the Directories table.
	"song_display_format" => "[Artist] - [Title]", //Format for the song display.
//	Available tags for song_display_format:
//		[Number] - Current song's number in the playlist.
//		[Track] - The current song's track number.
//		[Title] - The current song's title.
//		[Artist] - The current song's artist.
//		[Album] - The album that the current song is part of.
//		[Time] - The total time of the current song, in seconds.
//		[file] - The filename of the current song.
	"columns_playlist" => array("songformat", "Time"), //Columns in the playlist and file browser.
	"columns_files" => array("Track","Title"), //Columns in the playlist and file browser.
	"columns_directories" => array("Title"), //Columns in the directory browser.
//	Available tags for columns_*:
//		"Function" - A column for the Add or Delete links.
//		"Update" - Update the mpd database for this directory. (ONLY available in columns_directories)
//		"Number" - Current song's number in the playlist.
//		"Track" - The current song's track number.
//		"Title" - The current song's title.
//		"Artist" - The current song's artist.
//		"Album" - The album that the current song is part of.
//		"Time" - The total time of the current song.
//		"file" - The filename of the current song.
//		"songformat" - The string contained in "song_display_format", as described above. (NOT available in columns_directories)
	"unknown_string" => "", //String to show when a column's value is unknown for a certain song/directory.
	"sort" => array("Artist","Album","Track","Title","file"), //Sort songs according to these parameters.
	"show_dotdot" => true, //Show the ".." entry in the directory browser.

// SLIDER OPTIONS
	"combined_slider" => false, //Set to true to combine volume and crossfade into one line, toggleing the slider between the two.
	"combined_slider_control" => "seek", //Set to the parameter to control with the combined slider. One of "volume", "xfade", "seek".
	"display_volume" => false, //Set to true to show the volume slider, if combined_slider != true.
	"display_crossfade" => false, //Set to true to show the volume slider, if combined_slider != true.
	"slider_width" => 240, //Width of the volume and crossfade sliders.
	"graphical_sliders" => false
)
?>
