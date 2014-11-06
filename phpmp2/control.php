<div id="control">
<?php

	include ('../../lib/ClientSwitcher.php');
if($configuration["combined_slider"] == true) {
	if(isset($mpd_status["time"])) {
		$elapsed_time = floatval(trim(strtok($mpd_status["time"], ":")));
		$total_time = floatval(trim(strtok("\0")));
	} else {
		$elapsed_time = 0;
		$total_time = 0;
	}
	$combined_slider_targets = array(
		"volume" => array("value" => $mpd_status["volume"], "maximum" => 100, "command" => "setvol"),
		"xfade" => array("value" => $mpd_status["xfade"], "maximum" => 15, "command" => "crossfade"),
		"seek" => array("value" => $elapsed_time, "maximum" => $total_time, "command" => (isset($mpd_status["song"]) ? "seek ".$mpd_status["song"] : ""))
	);
	echo "<table cellspacing=\"0\" class=\"nostyle\" style=\"text-align: center\"><tr class=\"nostyle\">\n";
	if(!isset($configuration["combined_slider_control"]))
		$configuration["combined_slider_control"] = "seek";
	foreach($combined_slider_targets as $key => $properties) {
		echo "<td>";
		if($configuration["combined_slider_control"] == $key) {
			$slider_var = $properties;
			make_link("", "control", ucwords($key), array("combined_slider_control" => $key), true);
		} else {
			make_link("", "control", ucwords($key), array("combined_slider_control" => $key));
		}
		echo "</td>\n";
	}
	echo "</tr></table>\n<table cellspacing=\"0\" class=\"nostyle\" style=\"text-align: center\"><tr class=\"nostyle\"><td style=\"background: none\"></td><td style=\"width: ".($configuration["slider_width"] * 4 + 5)."px\">\n";
	create_slider($slider_var["value"], 0, $slider_var["maximum"], $configuration["slider_width"], $slider_var["command"], true, $configuration["combined_slider_control"]=="seek");
	echo "\n</td><td style=\"background: none\"></td></tr></table>\n";
} else {
	if($configuration["display_volume"]) {
		echo "<table cellspacing=\"0\" class=\"nostyle\"><tr>\n<td class=\"nostyle\">";
		make_link("", "control", "Volume", array("display_volume" => "false"));
		echo "</td>\n<td class=\"nostyle\" style=\"width: ".($configuration["slider_width"] * 4 + 5)."px\">\n";
		create_slider($mpd_status["volume"], 0, 100, $configuration["slider_width"], "setvol", true);
		echo "\n</td></tr></table>\n";
	} else {
		echo "<br />";
		make_link("", "control", "Volume", array("display_volume" => "true"));
		echo ": ".$mpd_status["volume"]."\n";
	}
	if($configuration["display_crossfade"]) {
		echo "<table cellspacing=\"0\" class=\"nostyle\"><tr>\n<td class=\"nostyle\">";
		make_link("", "control", "Crossfade", array("display_crossfade" => "false"));
		echo "</td>\n<td class=\"nostyle\" style=\"width: ".($configuration["slider_width"] * 4 + 5)."px\">\n";
		create_slider($mpd_status["xfade"], 0, 15, $configuration["slider_width"], "crossfade", true);
		echo "\n</td></tr></table>\n";
	} else {
		echo "<br />";
		make_link("", "control", "Crossfade", array("display_crossfade" => "true"));
		echo ": ".$mpd_status["xfade"]."<br />\n";
	}
}
?>
<table cellspacing="0" class="nostyle" style="text-align: center"><tr>
<td><?php make_link("", "status", "random", array("command" => "random", "arg" => (intval(trim($mpd_status["random"])) != 0 ? "0" : "1")), (intval(trim($mpd_status["random"])) != 0 ? true : false)); ?></td>
<td><?php make_link("", "status", "repeat", array("command" => "repeat", "arg" => (intval(trim($mpd_status["repeat"])) != 0 ? "0" : "1")), (intval(trim($mpd_status["repeat"])) != 0 ? true : false)); ?></td>
</tr></table>
<form action="<?php echo $_SERVER["PHP_SELF"]; ?>" method="post">
<?php
if(array_key_exists("content", $_REQUEST))
	echo "<input type=\"hidden\" name=\"content\" value=\"".$_REQUEST["content"]."\" />";
?>
<table cellspacing="0" class="nostyle" style="text-align: center"><tr>
<td class="nostyle"><?php style_button("previous"); ?></td>
<td class="nostyle"><?php style_button("play"); ?></td>
<td class="nostyle"><?php style_button("pause"); ?></td>
<td class="nostyle"><?php style_button("stop"); ?></td>
<td class="nostyle"><?php style_button("next"); ?></td>
</tr></table>
</form>



	
</div>
