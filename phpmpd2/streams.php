<div id="streams">
<h2><a name="files"></a>Streams</h2>
<table cellspacing="0">
<form method="get" action="<?php echo $_SERVER["PHP_SELF"] ?>">
<tr><td>
<input type="hidden" name="command" value="add" />
<label>Stream URL: <input type="text" name="arg" class="textbox" /></label>
</td><td>
<input type="submit" value="Add" class="button" />
</td></tr>
</form>
<form method="post" enctype="multipart/form-data" action="<?php echo $_SERVER["PHP_SELF"] ?>">
<tr><td>
<input type="hidden" name="MAX_FILE_SIZE" value="30000" />
<input type="hidden" name="command" value="upload_playlist" />
<label>Playlist: <input type="file" name="playlist" accept="text/plain" class="textbox" /></label>
</td><td>
<input type="submit" value="Upload" class="button" />
</td></tr>
</form>
</table>
</div>
