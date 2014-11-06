<?php
function style_button($name) {
	global $mpd_status;
	switch($name) {
	case "previous":
		make_link("", "status", "previous", array("command" => "previous"), false, "styles/dark/previous.png");
		break;
	case "play":
		make_link("", "status", "play", array("command" => "play"), false, ($mpd_status["state"] == "play" ? "styles/dark/play_hi.png" : "styles/dark/play.png"));
		break;
	case "pause":
		make_link("", "status", "pause", array("command" => "pause"), false, ($mpd_status["state"] == "pause" ? "styles/dark/pause_hi.png" : "styles/dark/pause.png"));
		break;
	case "stop":
		make_link("", "status", "stop", array("command" => "stop"), false, ($mpd_status["state"] == "stop" ? "styles/dark/stop_hi.png" : "styles/dark/stop.png"));
		break;
	case "next":
		make_link("", "status", "next", array("command" => "next"), false, "styles/dark/next.png");
		break;
	default:
		return false;
	}
}

function style_slider_image($darklight = null) {
	switch ($darklight) {
	case null:
		return true;
	case "dark":
		return "styles/dark/sliderdark.png";
	case "light":
		return "styles/dark/sliderlight.png";
	}
}
?>
