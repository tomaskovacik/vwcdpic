<div id="options">
<h2><a name="options"></a>phpMp2 options <span style="font-size: 70%">(see config.php for more information)</span></h2>
<table cellspacing="0">
<?php
make_form ($_SERVER["PHP_SELF"], "_top", array(
	"mpd_host" => $configuration["mpd_host"],
	"mpd_port" => $configuration["mpd_port"],
	"font_size" => $configuration["font_size"],
	"playlist_lines" => $configuration["playlist_lines"],
	"reset_on_next_song" => $configuration["reset_on_next_song"],
	"filenames_only" => $configuration["filenames_only"],
	"filenames_replace_underscores" => $configuration["filenames_replace_underscores"],
	"unknown_string" => $configuration["unknown_string"],
	"combined_slider" => $configuration["combined_slider"],
	"combined_slider_control" => array(
		"volume" => $configuration["combined_slider_control"] == "volume",
		"seek" => $configuration["combined_slider_control"] == "seek",
		"xfade" => $configuration["combined_slider_control"] == "xfade"
	),
	"graphical_sliders" => $configuration["graphical_sliders"],
	"auto_refresh" => $configuration["auto_refresh"],
	"refresh_freq" => $configuration["refresh_freq"],
	"show_dotdot" => $configuration["show_dotdot"]
));
/*
<td><?php make_link("", "_top", "auto refresh", array("auto_refresh" => ($configuration["auto_refresh"] == true ? "false" : "true")), $configuration["auto_refresh"] == true); ?></td>
</tr>
*/
?></table>

<h3>Layouts</h3>
<table cellspacing="0">
<?php
if( $handle=opendir( "./layouts" ) ) {
	while( $dir = readdir( $handle ) ) {
		if( strncmp($dir, ".", strlen(".")) != 0 && is_dir( "./layouts/".$dir ) ) {
			echo "<tr><td>";
			make_link("index.php", "_top", $dir, array("layout" => $dir));
			echo "</td></tr>\n";
		}
	}
	closedir( $handle );
}
?>
</table>

<h3>Styles</h3>
<table cellspacing="0">
<?php
if( $handle=opendir( "./styles" ) ) {
	while( $dir = readdir( $handle ) ) {
		if( strncmp($dir, ".", strlen(".")) != 0 && is_dir( "./styles/".$dir ) ) {
			echo "<tr><td>";
			make_link("index.php", "_top", $dir, array("style" => $dir));
			echo "</td></tr>\n";
		}
	}
	closedir( $handle );
}
?>
</table>
</div>
