<body>

<div id="topbar">
<table class="nostyle">
<tr>
<td class="anotfull">Current&nbsp;Directory:&nbsp;<?php dir_links (array_key_exists("directory", $configuration) ? $configuration["directory"] : "") ?></td>
<td style="width: 9%"><?php make_link("", "search", "Find Songs", array(), false, null, "search") ?></td>
<td style="width: 9%"><?php make_link("", "files", "Files", array(), false, null, "files") ?></td>
<td style="width: 9%"><?php make_link("", "directories", "Directories", array(), false, null, "directories") ?></td>
<td style="width: 9%"><?php make_link("", "playlists", "Available Playlists", array(), false, null, "playlists") ?></td>
<td style="width: 9%"><?php make_link("", "tagfiles", "Browse by ID3") ?></td>
<td style="width: 9%"><?php make_link("", "options", "phpMp2 Options") ?></td>
<td style="width: 9%"><?php make_link ("", "files", "Update", array("command" => "update")) ?></td>
</tr>
</table>
</div>

<?php include("search.php"); ?>
<?php include("files.php"); ?>
<?php include("directories.php"); ?>
<?php include("playlists.php"); ?>

</body>
