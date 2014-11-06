<div id="playlist">
<?php
//$listall=do_mpd_command($connection,"listall"."",null,true);
//echo "<pre>";echo $listall["file"][array_rand($listall["file"])];echo "</pre>";
if ($mpd_status["state"] == "play" && array_key_exists("song", $mpd_status) && $mpd_status["song"] == 1) { //playing second song, so first can be removed
	do_mpd_command($connection, "delete "."0", null, true);
	$mpd_status["playlistlength"]--;
}
if (!array_key_exists("nextsong", $mpd_status) && credit()==0) { //no mo payed song, do funky random add
	$listall=do_mpd_command($connection,"listall"."",null,true);
	do_mpd_command($connection,"add \"".$listall["file"][array_rand($listall["file"])]."\"",null,true);
}

echo "<span class=\"current_playlist_h\"><a name=\"playlist\"></a>Current Playlist</span>\n";
/*echo "<form action=\"".$_SERVER["PHP_SELF"]."\" method=\"post\"";

if (array_key_exists("playlists", $layout_vars["default_targets"])) {
	if ($layout_vars["frames"] == true) echo " target=\"".$layout_vars["default_targets"]["playlists"]["frame"]."\"";
	echo ">\n<input type=\"hidden\" name=\"content\" value=\"".$layout_vars["default_targets"]["playlists"]["content"]."\" />\n<table cellspacing=\"0\">\n";
} else {
	echo "><table cellspacing=\"0\">\n";
}

echo "<tr>\n<td class=\"nobg\">";
make_link("", "playlist", "Shuffle", array("command" => "shuffle"));
echo "</td>\n";
echo "<td class=\"nobg\"><input type=\"text\" name=\"arg\" style=\"width: 100%\" class=\"textbox\" /></td>\n";
echo "<td class=\"nobg\"><input type=\"submit\" name=\"command\" value=\"save\" class=\"button\" /></td>\n";
echo "<td class=\"nobg\">";
make_link("", "playlist", "Clear", array("command" => "clear"));
echo "</td>\n";
echo "</tr></table>\n</form>\n";*/

if($configuration["playlist_lines"] >= $mpd_status["playlistlength"]) {
	$playlist_start = 0;
	$playlist_end = $mpd_status["playlistlength"];
} else {
	$playlist_start = $configuration["playlist_focus"] - round($configuration["playlist_lines"] / 2 - .1);
	$playlist_end = $configuration["playlist_focus"] + round($configuration["playlist_lines"] / 2);
	if($playlist_start < 0) {
		$playlist_end -= $playlist_start;
		$configuration["playlist_focus"] = $configuration["playlist_lines"];
		$playlist_start = 0;
	}
	if($playlist_end > $mpd_status["playlistlength"]) {
		$playlist_end = $mpd_status["playlistlength"];
	}
}

if($configuration["playlist_lines"] < $mpd_status["playlistlength"] && $playlist_start > 0) {
	echo "<table cellspacing=\"0\" class=\"nostyle\" style=\"text-align: center\"><tr>";
	echo "<td class=\"nobg\">";
	make_link("", "playlist", "prev", $arguments = array("playlist_focus" => ($configuration["playlist_focus"] > $configuration["playlist_lines"] ? strval($configuration["playlist_focus"] - $configuration["playlist_lines"]) : "0" )));
	echo "</td>";
	echo "</tr></table>";
}

//echo "<table cellspacing=\"0\">\n<tr class=\"head\">";
echo "<table cellspacing=\"0\">\n";
/*foreach($configuration["columns_playlist"] as $key => $column) {
	switch ($column) {
	case "Function":
		//echo "<td>".$configuration["delete"]."</td>";
		echo "<td></td>";
		break;
	case "Number":
		echo "<td>#</td>";
		break;
	case "songformat":
		echo "<td>Song</td>";
		break;
	default:
		echo "<td>".$column."</td>";
	}
}
echo "</tr>\n";*/

for($counte = intval($playlist_start); $counte < $playlist_end; $counte++) {
	$songinfo = do_mpd_command($connection, "playlistinfo ".$counte, null, true);
	$songalt = "";

	foreach ($songinfo as $key => $val) {
		if ($key != "file")
			$songalt = $songalt.$key.": ".$val." ";
	}
	echo "<tr";
	if(array_key_exists("song", $mpd_status) && $counte == $mpd_status["song"]) {
		echo " class=\"hilight\"";
	} else if($counte % 2 != 1) {
			echo " class=\"alt\"";
	}
	echo ">";
	foreach($configuration["columns_playlist"] as $key => $column) {
		if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
			echo "<td>";
			switch($column) {
			case "Title":
				//make_link("", "status", htmlspecialchars($songinfo[$column]), array("command" => "play", "arg" => $counte), false, null, null, $songalt);
				echo htmlspecialchars($songinfo[$column]);
				break;
			case "Time":
				echo format_time($songinfo[$column]);
				break;
			default:
				echo $songinfo[$column];
			}
			echo "</td>";
		} else {
			echo "<td>";
			switch($column) {
			case "Title":
				//	make_link("", "status", htmlspecialchars($songinfo["file"]), array("command" => "play", "arg" => $counte), false, null, null, $songalt);
				echo htmlspecialchars($songinfo["file"]);
				break;
			case "Function":
				make_link("", "playlist", $configuration["delete"], array("command" => "delete", "arg" => $counte));
				break;
			case "Number":
				echo $counte;
				break;
			case "songformat":
				//make_link("", "status", format_song_title($configuration["song_display_format"], $songinfo, strval($counte)), array("command" => "play", "arg" => $counte), false, null, null, $songalt);
				echo format_song_title($configuration["song_display_format"],$songinfo, strval($counte));
				break;
			default:
				echo $configuration["unknown_string"];
			}
			echo "</td>";
		}
	}
	echo "</tr>\n";
}
echo "</table>\n";

if($configuration["playlist_lines"] < $mpd_status["playlistlength"] && $playlist_end < $mpd_status["playlistlength"]) {
	echo "<table cellspacing=\"0\" class=\"nostyle\" style=\"text-align: center\"><tr>";
	echo "<td class=\"nobg\">";
	make_link("", "playlist", "next", $arguments = array("playlist_focus" => ($configuration["playlist_focus"] < $mpd_status["playlistlength"] - $configuration["playlist_lines"] ? strval($configuration["playlist_focus"] + $configuration["playlist_lines"]) : $mpd_status["playlistlength"] )));
	echo "</td>";
	echo "</tr></table>";
}
?>
</div>
