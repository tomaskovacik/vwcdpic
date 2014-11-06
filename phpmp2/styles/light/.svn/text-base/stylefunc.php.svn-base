<?php
function style_button($name) {
	global $mpd_status;
	switch($name) {
	case "previous":
		make_link("", "status", "previous", array("command" => "previous"), false, "styles/light/previous.png");
		break;
	case "play":
		make_link("", "status", "play", array("command" => "play"), false, ($mpd_status["state"] == "play" ? "styles/light/play_hi.png" : "styles/light/play.png"));
		break;
	case "pause":
		make_link("", "status", "pause", array("command" => "pause"), false, ($mpd_status["state"] == "pause" ? "styles/light/pause_hi.png" : "styles/light/pause.png"));
		break;
	case "stop":
		make_link("", "status", "stop", array("command" => "stop"), false, ($mpd_status["state"] == "stop" ? "styles/light/stop_hi.png" : "styles/light/stop.png"));
		break;
	case "next":
		make_link("", "status", "next", array("command" => "next"), false, "styles/light/next.png");
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
		return "styles/light/sliderdark.png";
	case "light":
		return "styles/light/sliderlight.png";
	}
}
?>
