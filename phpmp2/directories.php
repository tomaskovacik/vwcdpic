<div id="directories">
<?php
$dirs = array();
$letters_dirs = array();
$ls = do_mpd_command($connection, "lsinfo".(array_key_exists("directory", $configuration) ? " \"".$configuration["directory"]."\"" : "" ), null, true);

if(array_key_exists("directory", $ls)) {
	if(is_array($ls["directory"])) {
		foreach($ls["directory"] as $key => $dir) {
			$dirs[] = $dir;
			if(!isset($letters_dirs[strtoupper(mbFirstChar(basename($dir)))]))
				$letters_dirs[strtoupper(mbFirstChar(basename($dir)))] = true;
		}
	} else {
		$dirs[] = $ls["directory"];
		$letters_dirs[strtoupper(mbFirstChar(basename($ls["directory"])))] = true;
	}
}

natcasesort($dirs);
$dirs = array_values($dirs);

if(array_key_exists("directory", $configuration) && strlen($configuration["directory"]) > 0 && $configuration["show_dotdot"] == true) {
	$newdir = (dirname($configuration["directory"]));
	$dirs = array_merge(array("<<" => ($newdir == "." || $newdir == "" || $newdir == "/" ? "" : $newdir)), $dirs);
}

if(count($dirs) > 0) {
	$dir = null;
	$counte = 0;
	echo "<h2><a name=\"directories\"></a>Directories  <small>";
	//echo "<h2><a name=\"directories\"></a>Directories  <small>[";
//	make_link("", "playlist", "add all", $arguments = (array_key_exists("directory", $configuration) ? array("command" => "addall_recursive", "arg" => $configuration["directory"]) : array("command" => "addall_recursive")));
//	echo "] ";
	make_index_table($letters_dirs, "dirs_", false);
	echo "</small></h2>\n";

	echo "<table cellspacing=\"0\" class=\"directory_list\">\n";
	if ($configuration["show_directory_columns"] == true) {
		echo "<tr class=\"head\">";
		foreach($configuration["columns_directories"] as $key => $column) {
			 
			switch ($column) {
			case "Function":
				//echo "<td".($configuration["wrap_functions"] == true ? " class=\"anotfull\"" : "")." style=\"width: ".strlen($configuration["add"])."em\">".$configuration["add"]."</td>";
				echo "<td></td>";
				break;
			case "Update":
				//echo "<td".($configuration["wrap_functions"] == true ? " class=\"anotfull\"" : "")." style=\"width: ".strlen($configuration["update"])."em\">".$configuration["update"]."</td>";
				echo "<td></td>";
				break;
			case "Number":
				echo "<td>#</td>";
				break;
			default:
				echo "<td>".$column."</td>";
			}
		}
		echo "</tr>\n";
	}

	foreach($dirs as $key => $dir) {
		echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">";
		foreach($configuration["columns_directories"] as $keyz => $column) {
			echo "<td";
			if ($column == "Function")
				echo " style=\"width: ".strlen($configuration["add"])."em\"";
			elseif ($column == "Update")
				echo " style=\"width: ".strlen($configuration["update"])."em\"";
			echo ">";
			if(is_int($key) && array_key_exists(strtoupper(mbFirstChar($dir)), $letters_dirs) && $letters_dirs[strtoupper(mbFirstChar($dir))] != false) {
				echo "<a name=\"dirs_".strtoupper(mbFirstChar($dir))."\" style=\"display: inline\"></a>";
				$letters[strtoupper(mbFirstChar($dir))] = false;
			}
			if (!strpos($dir,"mediaartlocal")){
			switch ($column) {
			case "Function":
				if (is_int($key))
					make_link("", "playlist", $configuration["add"], array("command" => "add", "arg" => htmlentities(rawurlencode($dir))));
				break;
			case "Update":
				if (is_int($key))
					make_link("", "directories", $configuration["update"], array("command" => "update", "arg" => htmlentities(rawurlencode($dir))));
				break;
			case "Number":
				echo $counte;
				break;
			case "Title":
				make_link("", "directories", (is_string($key) ? $key : htmlspecialchars(basename($dir))), array("directory" => htmlentities(rawurlencode($dir))));
				break;
			default:
				echo $configuration["unknown_string"];
			}}
			echo "</td>";
		}
		echo "</tr>\n";
		$counte++;
	}
	echo "</table>\n";
} else {
	echo "No directories found.\n";
}
?>
</div>
