<div id="tagfiles">
<?php
echo "<h2><a name=\"tagfiles\"></a>Files";
if (array_key_exists ("artist", $configuration) || array_key_exists ("album", $configuration)) {
	echo " <small>[";
	
	$letters_tagfiles = array();
	$tagfiles = array();
	$thisfile = "";
	fputs($connection, "find ".(array_key_exists ("album", $configuration) ? "album \"".$configuration["album"] : "artist \"".$configuration["artist"])."\"\n");
	while(!feof($connection)) {
		$var = parse_mpd_var(fgets($connection, 1024));
		if(isset($var)){
			if ($var === true) break;
			if ($var[0] == "file") {
				$thisfile = $var[1];
				$tagfiles[$thisfile] = array("file" => $thisfile);
			} else {
				$tagfiles[$thisfile][$var[0]] = $var[1];
			}
		}
	}

	foreach ($tagfiles as $key => $val) {
		if (!isset ($letters_tagfiles[strtoupper (mbFirstChar (get_songinfo_first($val, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0)))]))
			$letters_tagfiles[strtoupper (mbFirstChar (get_songinfo_first($val, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0)))] = true;
	}

	make_link("", "playlist", "add all", $arguments = array("command" => "addlist", "arg" => $tagfiles));
	echo "] ";

	if (count ($tagfiles) > 0) {
		$songinfo = null;
		$counte = 0;

		make_index_table($letters_tagfiles, "tagfiles_", false);
		echo "</small></h2>\n";

		echo "<table cellspacing=\"0\">\n<tr class=\"head\">";
		foreach($configuration["columns_files"] as $key => $column) {
			echo "<td".($column == "Function" ? " style=\"width: ".strlen($configuration["add"])."em\"" : "").">";
			switch ($column) {
			case "Function":
				echo $configuration["add"];
				break;
			case "Number":
				echo "#";
				break;
			case "songformat":
				make_link("", "tagfiles", "Song", array("sort" => "file"));
				break;
			default:
				make_link("", "tagfiles", $column, array("sort" => $column));
			}
			echo "</td>";
		}
		echo "</tr>\n";

		foreach($tagfiles as $key => $songinfo) {
			echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">";
			foreach($configuration["columns_files"] as $keyz => $column) {
				echo "<td>";
				if(array_key_exists(strtoupper(mbFirstChar($songinfo["file"])), $letters_tagfiles) && $letters_tagfiles[strtoupper(mbFirstChar($songinfo["file"]))] != false) {
					echo "<a name=\"tagfiles_".strtoupper(mbFirstChar($songinfo["file"]))."\" style=\"display: inline\"></a>";
					$letters_tagfiles[strtoupper(mbFirstChar($songinfo["file"]))] = false;
				}
				switch ($column) {
				case "Function":
					make_link("", "status", $configuration["add"], array("command" => "add", "arg" => htmlentities(rawurlencode($songinfo["file"]))));
					break;
				case "Number":
					echo $counte;
					break;
				case "Title":
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						make_link("", "files", htmlspecialchars($songinfo[$column]), array("search" => "1", "searchtext" => htmlentities(rawurlencode($songinfo[$column])), "searchwhat" => "title", "exact" => "true"));
					} else {
						echo htmlspecialchars($songinfo["file"]);
					}
					break;
				case "Artist":
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						make_link("", "albums", htmlspecialchars($songinfo[$column]), array("artist" => htmlentities(rawurlencode($songinfo[$column]))));
					} else {
						echo $configuration["unknown_string"];
					}
					break;
				case "Album":
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						make_link("", "tagfiles", htmlspecialchars($songinfo[$column]), array("album" => htmlentities(rawurlencode($songinfo[$column]))));
					} else {
						echo $configuration["unknown_string"];
					}
					break;
				case "Time":
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						echo format_time($songinfo[$column]);
					} else {
						echo $configuration["unknown_string"];
					}
					break;
				case "Track":
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						echo $songinfo[$column];
					} else {
						echo $configuration["unknown_string"];
					}
					break;
				case "songformat":
					echo format_song_title($configuration["song_display_format"], $songinfo, strval($counte));
					break;
				default:
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						echo htmlentities($songinfo[$column]);
					} else {
						echo $configuration["unknown_string"];
					}
					break;
				}
				echo "</td>";
			}
			echo "</tr>\n";
			$counte++;
		}

		echo "</table>\n";
	} else {
		echo "</small></h2>\nNo files found.<br />\n";
	}
} else {
	echo "</h2>\nNo artist or album selected.<br />\n";
}
?>
</div>
