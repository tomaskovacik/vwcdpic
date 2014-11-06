<div id="albums">
<?php
echo "<h2><a name=\"albums\"></a>Albums";

$letters_albums = array();
$tmp = do_mpd_command ($connection, "list album".(array_key_exists ("artist", $configuration) ? " \"".$configuration["artist"]."\"" : ""), null, true);

if (array_key_exists ("Album", $tmp)) {
	if (!is_array ($tmp["Album"]))
		$albums = array ($tmp["Album"]);
	else
		$albums = $tmp["Album"];

	natcasesort ($albums);

	$albums = array_merge (array("Any album" => ""), array_values ($albums));

	foreach ($albums as $key => $val) {
		if (!isset ($letters_albums[strtoupper (mbFirstChar ($val))]))
			$letters_albums[strtoupper (mbFirstChar ($val))] = true;
	}

	$songinfo = null;
	$counte = 0;

	echo " <small>";
	make_index_table($letters_albums, "albums_", false);
	echo "</small></h2>\n";

	echo "<table cellspacing=\"0\">\n";

	foreach($albums as $key => $val) {
		if ($letters_albums[strtoupper (mbFirstChar ($val))] == true) {
			echo "<a name=\"albums_".strtoupper (mbFirstChar ($val))."\"></a>";
			$letters_albums[strtoupper (mbFirstChar ($val))] = false;
		}
		echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">";
		echo "<td>";
		make_link("", "tagfiles", (is_string ($key) ? $key : $val), $arguments = array("album" => htmlentities(rawurlencode($val))), false, null, "tagfiles");
		echo "</td>";
		echo "</tr>\n";
		$counte++;
	}

	echo "</table>\n";
} else {
	echo "</h2>\nNo albums found.<br />\n";
}
?>
</div>
