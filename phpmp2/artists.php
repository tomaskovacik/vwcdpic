<div id="artists">
<?php
echo "<h2><a name=\"artists\"></a>Artists";

$letters_artists = array();
$tmp = do_mpd_command ($connection, "list artist", null, true);

if (array_key_exists ("Artist", $tmp)) {
	if (is_array ($tmp["Artist"]))
		$artists = $tmp["Artist"];
	else
		$artists = array ($tmp["Artist"]);

	natcasesort ($artists);

	$artists = array_merge (array("Any artist" => ""), array_values($artists));

	foreach ($artists as $key => $val) {
		if (!array_key_exists (strtoupper (mbFirstChar ($val)), $letters_artists))
			$letters_artists[strtoupper (mbFirstChar ($val))] = true;
	}

	$songinfo = null;
	$counte = 0;

	echo " <small>";
	make_index_table($letters_artists, "artists_", false);
	echo "</small></h2>\n";

	echo "<table cellspacing=\"0\">\n";

	foreach($artists as $key => $val) {
		if ($letters_artists[strtoupper (mbFirstChar ($val))] == true) {
			echo "<a name=\"artists_".strtoupper (mbFirstChar ($val))."\"></a>";
			$letters_artists[strtoupper (mbFirstChar ($val))] = false;
		}
		echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">";
		echo "<td>";
		make_link("", "albums", (is_string ($key) ? $key : $val), $arguments = array("artist" => htmlentities(rawurlencode($val))), false, null, "albums");
		echo "</td>";
		echo "</tr>\n";
		$counte++;
	}

	echo "</table>\n";
} else {
	echo "</h2>\nNo artists found.<br />\n";
}
?>
</div>
