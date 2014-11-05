<?php
function style_button($name) {
	global $mpd_status;
	switch($name) {
	case "previous":
		make_link("", "status", "previous", array("command" => "previous"), false, "styles/ember/previous.png");
		break;
	case "play":
		make_link("", "status", "play", array("command" => "play"), false, ($mpd_status["state"] == "play" ? "styles/ember/play_hi.png" : "styles/ember/play.png"));
		break;
	case "pause":
		make_link("", "status", "pause", array("command" => "pause"), false, ($mpd_status["state"] == "pause" ? "styles/ember/pause_hi.png" : "styles/ember/pause.png"));
		break;
	case "stop":
		make_link("", "status", "stop", array("command" => "stop"), false, ($mpd_status["state"] == "stop" ? "styles/ember/stop_hi.png" : "styles/ember/stop.png"));
		break;
	case "next":
		make_link("", "status", "next", array("command" => "next"), false, "styles/ember/next.png");
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
		return "styles/ember/sliderdark.png";
	case "light":
		return "styles/ember/sliderlight.png";
	}
}
?>
