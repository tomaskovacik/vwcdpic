<?php
if(isset($mpd_status["song"]) && (!isset($configuration["lastsong"]) || (($mpd_status["song"] != $configuration["lastsong"] && $configuration["reset_on_next_song"] == true)))) {
	make_config_cookie("lastsong", $mpd_status["song"]);
	$configuration["lastsong"] = $mpd_status["song"];
	make_config_cookie("playlist_focus", $mpd_status["song"]);
	$configuration["playlist_focus"] = $mpd_status["song"];
}

if(array_key_exists("playlist_focus", $_REQUEST)) {
	make_config_cookie("playlist_focus", $_REQUEST["playlist_focus"]);
	$configuration["playlist_focus"] = $_REQUEST["playlist_focus"];
}
if(!isset($configuration["playlist_focus"])) {
	$configuration["playlist_focus"] = (isset($mpd_status["song"]) ? $mpd_status["song"] : $configuration["playlist_lines"] / 2);
}
?>
