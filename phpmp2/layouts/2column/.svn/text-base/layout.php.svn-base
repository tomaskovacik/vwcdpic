<body>

<div id="topbar">
<table class="nostyle">
<tr>
<td class="anotfull">Current&nbsp;Directory:&nbsp;<?php dir_links (array_key_exists("directory", $configuration) ? $configuration["directory"] : "") ?></td>
<td style="width: 10%"><?php make_link("", "playlist", "Current&nbsp;Playlist", array(), false, null, "playlist") ?></td>
<td style="width: 10%"><?php make_link("", "search", "Find&nbsp;Songs", array(), false, null, "search") ?></td>
<td style="width: 10%"><?php make_link("", "files", "Files", array(), false, null, "search") ?></td>
<td style="width: 10%"><?php make_link("", "directories", "Directories", array(), false, null, "search") ?></td>
<td style="width: 10%"><?php make_link("", "playlists", "Available&nbsp;Playlists", array(), false, null, "playlists") ?></td>
<td style="width: 10%"><?php make_link("", "tagfiles", "Browse&nbsp;by&nbsp;ID3", array(), false, null, "tagfiles") ?></td>
<td style="width: 10%"><?php make_link ("", "files", "Update", array("command" => "update")) ?></td>
</tr>
</table>
</div>

<div style="float: right; width: 34%">
<?php include("status.php"); ?>
<?php include("control.php"); ?>
<?php include("auth.php"); ?>
<?php include("playlist.php"); ?>
<?php include("options.php"); ?>
</div>

<div style="float: left; width: 64%">
<?php include("search.php"); ?>
<?php include("files.php"); ?>
<?php include("directories.php"); ?>
<?php include("playlists.php"); ?>
</div>

</body>
