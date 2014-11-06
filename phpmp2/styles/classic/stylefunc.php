<?php
function style_button ($name) {
	global $mpd_status;
	switch ($name) {
	case "previous":
		make_link("", "status", "[&lt;&lt;]", array("command" => "previous"), false);
		break;
	case "play":
		make_link("", "status", "[play]", array("command" => "play"), false);
		break;
	case "pause":
		make_link("", "status", "[| |]", array("command" => "pause"), false);
		break;
	case "stop":
		make_link("", "status", "[stop]", array("command" => "stop"), false);
		break;
	case "next":
		make_link("", "status", "[&gt;&gt;]", array("command" => "next"), false);
		break;
	default:
		return false;
	}
}

function style_slider_image($darklight = null) {
	return false;
}
?>
