<div id="playlists">
<?php
$playlists = array();
$letters = array();
$ls = do_mpd_command($connection, "lsinfo".(array_key_exists("directory", $configuration) ? " \"".$configuration["directory"]."\"" : "" ), null, true);

if(array_key_exists("playlist", $ls)) {
	if(is_array($ls["playlist"])) {
		foreach($ls["playlist"] as $key => $pl) {
			$playlists[] = $pl;
			if(!isset($letters[strtoupper(mbFirstChar($pl))]))
				$letters[strtoupper(mbFirstChar($pl))] = true;
		}
	} else {
		$playlists[] = $ls["playlist"];
		$letters[strtoupper(mbFirstChar($ls["playlist"]))] = true;
	}
}

if(count($playlists) > 0) {
	$pl = null;
	$counte = 0;
	echo "<h2><a name=\"playlists\"></a>Available Playlists <small>";
	make_index_table($letters, "playlists_", false);
	echo "</small></h2>\n";

	echo "<table cellspacing=\"0\">\n";
	echo "<tr class=\"head\"><td style=\"width: ".strlen($configuration["delete"])."em\">".$configuration["delete"]."</td><td>Title</td></tr>\n";
	foreach($playlists as $key => $pl) {
		echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "")."><td>";
		if($letters[strtoupper(mbFirstChar($pl))]) {
			echo "<a name=\"playlists_".strtoupper(mbFirstChar($pl))."\" style=\"display: inline\" />";
			$letters[strtoupper(mbFirstChar($pl))] = false;
		}
		make_link("", "playlists", $configuration["delete"], array("command" => "rm", "arg" => htmlentities(rawurlencode($pl))));
		echo "</td><td>";
		make_link("", "playlist", htmlspecialchars($pl), array("command" => "load", "arg" => htmlentities(rawurlencode($pl))));
		echo "</td></tr>\n";
		$counte++;
	}
	echo "</table>\n";
} else {
	echo "No playlists found.\n";
}
?>
</div>
