<div id="files">
<?php

if(is_array($files) && count($files) > 0){
	echo "<h2><a name=\"files\"></a>Files <small>";
	//echo "<h2><a name=\"files\"></a>Files <small>[";
//	make_link("", "playlist", "add all", $arguments = (array_key_exists("directory", $configuration) ? array("command" => "addall", "arg" => $configuration["directory"]) : array("command" => "addall")));
//	echo "] ";
	$songinfo = null;
	$counte = 0;
//	make_index_table($letters_files, "files_", false);
	echo "</small></h2>\n";

	echo "<table cellspacing=\"0\" class=\"files_list\">\n<tr class=\"head\">";
	foreach($configuration["columns_files"] as $key => $column) {
		echo "<td".($column == "Function" ? " style=\"width: ".strlen($configuration["add"])."em\"" : "").">";
		switch ($column) {
		case "Function":
			//echo $configuration["add"];
			break;
		case "Number":
			echo "#";
			break;
		case "songformat":
			make_link("", "files", "Song", array("sort" => "file"));
			break;
		default:
			//make_link("", "files", $column, array("sort" => $column));
		}
		echo "</td>";
	}
	echo "</tr>\n";
	foreach($files as $key => $songinfo) {
		echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">";
		foreach($configuration["columns_files"] as $keyz => $column) {
			echo "<td>";
			if(array_key_exists(strtoupper(mbFirstChar($songinfo["file"])), $letters_files) && $letters_files[strtoupper(mbFirstChar($songinfo["file"]))] != false) {
				echo "<a name=\"files_".strtoupper(mbFirstChar($songinfo["file"]))."\" style=\"display: inline\"></a>";
				$letters_files[strtoupper(mbFirstChar($songinfo["file"]))] = false;
			}
			switch ($column) {
			case "Function":
				make_link("", "status", $configuration["add"], array("command" => "add", "arg" => htmlentities(rawurlencode($songinfo["file"]))));
				break;
			case "Number":
				echo $counte;
				break;
			case "Title":
				if (credit()>0){
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column])) {
						if (!array_key_exists("directory", $configuration)){
						make_link("", "status", htmlspecialchars($songinfo["Artist"]." - ".$songinfo[$column]), array("command" => "add", "arg" => htmlentities(rawurlencode($songinfo["file"]))));
						//						make_link("", "files", htmlspecialchars($songinfo[$column]), array("search" => "1", "searchtext" => htmlentities(rawurlencode($songinfo[$column])), "searchwhat" => "title", "exact" => "true"));
						} else {
							make_link("", "status", htmlspecialchars($songinfo[$column]), array("command" => "add", "arg" => htmlentities(rawurlencode($songinfo["file"]))));
						}
					} else {
						make_link("", "status", htmlspecialchars(preg_replace("/\\.[^.\\s]{3,4}$/", "", $songinfo["file"])), array("command" => "add", "arg" => htmlentities(rawurlencode($songinfo["file"]))));
					}
				}
				else {
					if (array_key_exists($column, $songinfo)) {
						if (!array_key_exists("directory", $configuration)){
							echo htmlspecialchars($songinfo["Artist"]." - ".$songinfo[$column]);
						} else {
							echo htmlspecialchars($songinfo[$column]);
						}
					} else {
						echo htmlspecialchars($songinfo["file"]);
					}
				}
				break;
			case "Artist":
				if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
					make_link("", "files", htmlspecialchars($songinfo[$column]), array("search" => "1", "searchtext" => htmlentities(rawurlencode($songinfo[$column])), "searchwhat" => "artist", "exact" => "true"));
				} else {
					echo $configuration["unknown_string"];
				}
				break;
			case "Album":
				if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
					make_link("", "files", htmlspecialchars($songinfo[$column]), array("search" => "1", "searchtext" => htmlentities(rawurlencode($songinfo[$column])), "searchwhat" => "album", "exact" => "true"));
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
				if (array_key_exists("directory", $configuration)){//no directory = unsorted songs
					if(array_key_exists($column, $songinfo) && strlen($songinfo[$column]) > 0) {
						echo $songinfo[$column];
					} else {
						echo $configuration["unknown_string"];
					}
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
//	echo "No files found.\n";
}
?>
</div>
