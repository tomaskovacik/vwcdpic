<?php
load_config_cookies ($_COOKIE);

if (array_key_exists ("directory", $_REQUEST)) {
	make_config_cookie ("directory", $_REQUEST["directory"]);
	$configuration["directory"] = $_REQUEST["directory"];
	eat_config_cookie ("searched");
	if (array_key_exists ("searched", $configuration))
		unset ($configuration["searched"]);
/* Doesn't need to be cleared.
	eat_config_cookie ("artist");
	if (array_key_exists ("artist", $configuration))
		unset ($configuration["artist"]);
	eat_config_cookie ("album");
	if (array_key_exists ("album", $configuration))
		unset ($configuration["album"]);*/
}

if (array_key_exists ("search", $_REQUEST)) {
	make_config_cookie ("searched", (array_key_exists ("exact", $_REQUEST) && $_REQUEST["exact"] == "true" ? "find " : "search ").$_REQUEST["searchwhat"]." \"".$_REQUEST["searchtext"]."\"");
	$configuration["searched"] = (array_key_exists ("exact", $_REQUEST) && $_REQUEST["exact"] == "true" ? "find " : "search ").$_REQUEST["searchwhat"]." \"".$_REQUEST["searchtext"]."\"";
	eat_config_cookie ("directory");
	if (array_key_exists ("directory", $configuration))
		unset ($configuration["directory"]);
}

if (array_key_exists ("artist", $_REQUEST)) {
	if ($_REQUEST["artist"] != "") {
		make_config_cookie ("artist", $_REQUEST["artist"]);
		$configuration["artist"] = $_REQUEST["artist"];
		eat_config_cookie ("album");
		if (array_key_exists ("album", $configuration))
			unset ($configuration["album"]);
	} else {
		eat_config_cookie ("artist");
		if (array_key_exists ("artist", $configuration))
			unset ($configuration["artist"]);
		eat_config_cookie ("album");
		if (array_key_exists ("album", $configuration))
			unset ($configuration["album"]);
	}
}

if (array_key_exists ("album", $_REQUEST)) {
	if ($_REQUEST["album"] != "") {
		make_config_cookie("album", $_REQUEST["album"]);
		$configuration["album"] = $_REQUEST["album"];
	} else {
		eat_config_cookie("album");
		if (array_key_exists ("album", $configuration))
			unset ($configuration["album"]);
	}
}

if (array_key_exists ("sort", $_REQUEST)) {
	if (!array_key_exists ("sort", $configuration)) {
		$configuration["sort"] = array($_REQUEST["sort"]);
	} else {
		if (in_array ($_REQUEST["sort"], $configuration["sort"])) {
			unset ($configuration["sort"][array_search ($_REQUEST["sort"], $configuration["sort"])]);
		}
		array_unshift ($configuration["sort"], $_REQUEST["sort"]);
	}
	make_config_cookie ("sort", $configuration["sort"]);
}

$allowable = array(
	"mpd_host" => "text",
	"mpd_port" => "text",
	"font_size" => "text",
	"time_elapsed" => "bool",
	"title" => "text",
	"auto_refresh" => "bool",
	"refresh_freq" => "text",
	"layout" => "text",
	"style" => "text",
	"add" => "text",
	"delete" => "text",
	"update" => "text",
	"playlist_lines" => "number",
	"reset_on_next_song" => "bool",
	"filenames_only" => "bool",
	"filenames_replace_underscores" => "bool",
	"show_directory_columns" => "bool",
	"song_display_format" => "text",
	"unknown_string" => "text",
	"combined_slider" => "bool",
	"combined_slider_control" => "text",
	"graphical_sliders" => "bool",
	"display_volume" => "bool",
	"display_crossfade" => "bool"
);

foreach($_REQUEST as $var => $value) {
	if(array_key_exists($var, $allowable)) {
		switch($allowable[$var]) {
		case "text":
		case "number":
			make_config_cookie($var, $value);
			$configuration[$var] = $value;
			break;
		case "bool":
			make_config_cookie($var, $value == "true" ? "true" : "false");
			$configuration[$var] = ($value == "true" ? true : false);
			break;
		}
	}
}

if (array_key_exists ("form_vars", $_REQUEST)) {
	foreach($_REQUEST["form_vars"] as $num => $var) {
		if(array_key_exists($var, $allowable)) {
			switch($allowable[$var]) {
			case "text":
			case "number":
				make_config_cookie($var, $_REQUEST[$var]);
				$configuration[$var] = $_REQUEST[$var];
				break;
			case "bool":
				make_config_cookie($var, array_key_exists($var, $_REQUEST) && $_REQUEST[$var] == "true" ? "true" : "false");
				$configuration[$var] = (array_key_exists($var, $_REQUEST) && $_REQUEST[$var] == "true" ? true : false);
				break;
			}
		}
	}
}
?>
