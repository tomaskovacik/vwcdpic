<body>

<div id="topbar">
<h2>
Back to Directory:
<span style="font-size: 70%"><?php dir_links (array_key_exists("directory", $configuration) ? $configuration["directory"] : "") ?></span>
</h2>
<table class="anotfull">
<tr>
<td>
[<?php make_link("", "files", "Files", array(), false, null, "files"); ?>]
[<?php make_link("", "playlists", "Playlists", array(), false, null, "playlists"); ?>]
</td>
<td style="text-align: right">
[<?php make_link ("", "tagfiles", "Browse by ID3") ?>]
[<?php make_link("", "search", "Search") ?>]
[<?php make_link("", "options", "Options") ?>]
[<?php make_link ("", "files", "Update", array("command" => "update")) ?>]
</td>
</tr>
</table>
</div>

<?php include("search.php"); ?>
<?php include("files.php"); ?>

</body>
