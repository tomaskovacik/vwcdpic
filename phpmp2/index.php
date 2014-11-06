<?php

ob_start ();

include ("config.php");
include ("functions.php");
include ("loadvars_pre.php");

if (file_exists ("layouts/".$configuration["layout"]."/vars.php"))
{
	include ("layouts/".$configuration["layout"]."/vars.php");
}
else
{
	echo "No layout vars found!<br />\n";
}

if ($layout_vars["frames"] != true ||
	array_key_exists ("content", $_REQUEST) ||
	array_key_exists ("command", $_REQUEST))
{
	include ("connection.php");
	$noconnect = false;
}
else
{
	$noconnect = true;
}
include ("loadvars_post.php");

if (isset ($is_connected) ? $is_connected == true : $noconnect == true)
{
	$errno = 0;
	$errstr = "";

	$frames = false;

	header ("Expires: Thu, 01 Dec 1994 16:00:00 GMT");
	header ("Cache-Control: no-cache, must-revalidate");
	header ("Pragma: no-cache");

	if ($layout_vars["frames"] == true && !array_key_exists ("content", $_REQUEST))
	{
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<?php
	}
	else
	{
		header ("Content-Type: text/html; charset=UTF-8");
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?php
	}

	ob_end_flush ();
?>
<html>

<head>
<title><?php echo $configuration["title"]; ?></title>
<meta http-equiv="Expires" content="Thu, 01 Dec 1994 16:00:00 GMT" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<?php
	if ($layout_vars["frames"] == true && !array_key_exists ("content", $_REQUEST))
	{
?>
<base target="_self" />
<?php
	}
	else
	{
		if (array_key_exists ("content", $_REQUEST))
		{
			echo "<meta name=\"content\" content=\"".$_REQUEST["content"]."\" />";
		}

		if (array_key_exists ("directory", $configuration))
		{
			echo "<meta name=\"directory\" content=\"".$configuration["directory"]."\" />";
		}

		echo "<style type=\"text/css\" media=\"screen\">\n";
		echo "<!--\n";
		echo "html { font-size: ".$configuration["font_size"]." }\n";
		echo "-->\n";
		echo "</style>\n";

		if (($layout_vars["frames"] == false
			|| (array_key_exists ("content", $_REQUEST)
			&& in_array ($_REQUEST["content"], $layout_vars["auto-reload"])))
			&& $configuration["auto_refresh"] == true)
		{
			echo "<meta http-equiv=\"REFRESH\" content=\"";
			echo $configuration["refresh_freq"];
			echo ";URL=index.php";

			if (array_key_exists ("content", $_REQUEST))
			{
				echo "?content=".$_REQUEST["content"];
			}

			echo "\" />\n";
		}

		if ($handle = opendir ("./styles"))
		{
			$dirs = array ();

			while ( $file = readdir ( $handle ) )
			{
				if ($file != "."
					&& $file != ".."
					&& is_dir ("./styles/".$file)
					&& file_exists ("./styles/".$file."/style.css"))
				{
					$dirs[] = $file;
				}
			}
			closedir ( $handle );

			foreach ($dirs as $key => $dir)
			{
				if ($configuration["style"] == $dir)
				{
					echo "<link rel=\"StyleSheet\" href=\"styles/";
					echo $dir;
					echo "/style.css\" type=\"text/css\" title=\"";
					echo $dir;
					echo "\" />\n";

					if (file_exists ("styles/".$dir."/stylefunc.php"))
					{
						include ("styles/".$dir."/stylefunc.php");
					}
					else
					{
						include ("defaultstylefunc.php");
					}
				}
				else
				{
					echo "<link rel=\"Alternate StyleSheet\" href=\"styles/";
					echo $dir;
					echo "/style.css\" type=\"text/css\" title=\"";
					echo $dir;
					echo "\" />\n";
				}
			}
		}
	}
?>
</head>
<?php
	if (array_key_exists ("content", $_REQUEST))
	{
		if (file_exists ("layouts/".$configuration["layout"]."/".$_REQUEST["content"].".php"))
		{
			include ("layouts/".$configuration["layout"]."/".$_REQUEST["content"].".php");
		}
		else
		{
			echo "<body>\n<h1>ERROR</h1>\n<p>Could not open content file!</p>\n</body>";
		}
	}
	else
	{
		if (file_exists ("layouts/".$configuration["layout"]."/layout.php"))
		{
			include ("layouts/".$configuration["layout"]."/layout.php");
		}
		else
		{
			echo "<body>\n<h1>ERROR</h1>\n<p>Could not open layout file!</p>\n</body>";
		}
	}
	if ($noconnect != true)
	{
		fclose ($connection);
	}
}
else
{
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>phpMp2 Error!</title>
</head>
<?php
	echo "<body>\n<h1>ERROR</h1>\n<p>Could not open connection! Is mpd started?</p>\n";
	if (isset ($errstr))
	{
		echo "$errstr ($errno)<br>\n";
	}



	echo "</body>\n";
}
?>


</html>
