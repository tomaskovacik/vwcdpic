
<div id="auth">
<?php
echo "<h2><a name=\"auth\"></a>MPD Authentication</h2>";
if($authorized && $configuration["use_cookies"]==true) {
	echo "<form action=\"http://".$_SERVER["SERVER_NAME"].$_SERVER["PHP_SELF"]."\" method=\"post\">";
	if(array_key_exists("content", $_REQUEST))
		echo "<input type=\"hidden\" name=\"content\" value=\"".$_REQUEST["content"]."\" />";
	echo "<table cellspacing=\"0\">\n";
	echo "<tr><td>\n";
	echo "<input type=\"submit\" name=\"action\" value=\"Logout\" class=\"button\" />";
	echo "</td></tr>\n</table>\n";
	echo "</form>\n";
} else {
	echo "<form action=\"http://".$_SERVER["SERVER_NAME"].$_SERVER["PHP_SELF"]."\" method=\"post\">";
	if(array_key_exists("content", $_REQUEST))
		echo "<input type=\"hidden\" name=\"content\" value=\"".$_REQUEST["content"]."\" />";
	echo "<table cellspacing=\"0\">\n";
	echo "<tr><td>\n";
	echo "<label accesskey=\"p\"><b>P</b>assword:</label><input type=\"password\" name=\"password\" class=\"textbox\" style=\"100%\" />";
	echo "</td><td>";
	echo "<input type=\"submit\" name=\"action\" value=\"Login\" class=\"button\" />";
	echo "</td></tr>\n</table>\n";
	echo "</form>\n";
}
?>
</div>

