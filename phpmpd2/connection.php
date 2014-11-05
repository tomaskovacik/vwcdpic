<?php
$is_connected = false;
$authorized = false;

if($configuration["use_cookies"]==true) {
	if(isset($configuration["hide"])) {
		make_config_cookie("playlist_hide", $hide);
	}
}

$connection = fsockopen($configuration["mpd_host"], $configuration["mpd_port"], $errno, $errstr, 10);
if(isset($connection) && is_resource($connection)) {
	while(!feof($connection)) {
		$gt = fgets($connection, 1024);
		if(parse_mpd_var($gt))
			break;
	}
	if(array_key_exists("action", $_REQUEST) && $_REQUEST["action"] == "Logout") {
		eat_config_cookie("password");
	} else {
		$pass = (array_key_exists("action", $_REQUEST) && $_REQUEST["action"] == "Login" ? $_REQUEST["password"] : (isset($configuration["password"]) ? $configuration["password"] : null));
		if(isset($pass)) {
			if(do_mpd_command($connection, "password ".$pass) === true) {
				$authorized = true;
				if($configuration["use_cookies"]=="yes")
					make_config_cookie("password", $pass);
			}
		}
	}
	if(array_key_exists("command", $_REQUEST)) {
		switch($_REQUEST["command"]) {
		case "addall":
			$files = array();
			$command = "add";
			$ls = do_mpd_command($connection, "lsinfo".(array_key_exists("directory", $configuration) ? " \"".$configuration["directory"]."\"" : "" ), null, true);
			if(array_key_exists("file", $ls)) {
				if(is_array($ls["file"])) {
					foreach($ls["file"] as $key => $file) {
						$files[] = "\"".$file."\"";
					}
				} else {
					$files[] = "\"".$ls["file"]."\"";
				}
				if(do_mpd_command_list($connection, $command, $files) === true) {
					$command_successful = true;
				} else {
					$command_successful = false;
				}
			}
			break;
		case "addall_recursive":
			$files = array();
			$command = "add";
			$ls = do_mpd_command($connection, "listall".(array_key_exists("directory", $configuration) ? " \"".$configuration["directory"]."\"" : "" ), null, true);
			if(array_key_exists("file", $ls)) {
				if(is_array($ls["file"])) {
					foreach($ls["file"] as $key => $file) {
						$files[] = "\"".$file."\"";
					}
				} else {
					$files[] = "\"".$ls["file"]."\"";
				}
				if(do_mpd_command_list($connection, $command, $files) === true) {
					$command_successful = true;
				} else {
					$command_successful = false;
				}
			}
			break;
		case "addlist":
			$files = array();
			$command = "add";
			$ls = $_REQUEST["arg"];
			if(is_array($ls)) {
				foreach($ls as $key => $file) {
					$files[] = "\"".$file."\"";
				}
			} else {
				$files[] = "\"".$ls."\"";
			}
			if(do_mpd_command_list($connection, $command, $files) === true) {
				$command_successful = true;
			} else {
				$command_successful = false;
			}
			break;
		case "upload_playlist":
			$files = array();
			$command = "add";
			$handle = fopen($_FILES["playlist"]["tmp_name"], "r");
			while (!feof($handle)) {
				$buffer = fgets($handle, 4096);
				$files[] = $buffer;
			}
			fclose($handle);
			if(do_mpd_command_list($connection, $command, $files) === true) {
				$command_successful = true;
			} else {
				$command_successful = false;
			}
			break;
		case "add":
			$command = $_REQUEST["command"];
			if(array_key_exists("arg", $_REQUEST) && strlen($_REQUEST["arg"])>0) $command.=" \"".$_REQUEST["arg"]."\"";
			if (credit("-1") === true && do_mpd_command($connection, $command) === true){
				$command_successful = true;
			} else {
				$command_successful = false;
			}
			break;
		default:
			$command = $_REQUEST["command"];
			if(array_key_exists("arg", $_REQUEST) && strlen($_REQUEST["arg"])>0) $command.=" \"".$_REQUEST["arg"]."\"";
			if(do_mpd_command($connection, $command) === true) {
				$command_successful = true;
			} else {
				$command_successful = false;
			}
		}
	}
	if(array_key_exists("slidercommand", $_REQUEST)) {
			$command = $_REQUEST["slidercommand"]." \"";
			if ($_REQUEST["sliderintonly"] == "true") $command .= round((($_REQUEST["slider_x"] * ($_REQUEST["slidermax"] - $_REQUEST["slidermin"])) / $_REQUEST["sliderlength"]) + $_REQUEST["slidermin"]);
			else $command .= ((($_REQUEST["slider_x"] * ($_REQUEST["slidermax"] - $_REQUEST["slidermin"])) / $_REQUEST["sliderlength"]) + $_REQUEST["slidermin"]);
			$command .= "\"";
			if(do_mpd_command($connection, $command) === true) {
				$command_successful = true;
			} else {
				$command_successful = false;
			}
	}
	$files = array();
	$letters_files = array();
	if (array_key_exists ("searched", $configuration)) {
		$ls = do_mpd_command ($connection, $configuration["searched"], null, true);
	} else {
		$ls = do_mpd_command($connection, "lsinfo".(array_key_exists("directory", $configuration) ? " \"".$configuration["directory"]."\"" : "" ), null, true);
	}
	if (is_array ($ls) && array_key_exists ("file", $ls)) {
		if (is_array ($ls["file"])) {
			foreach ($ls["file"] as $key => $file) {
				$tmp = do_mpd_command($connection, "listallinfo \"".$file."\"", null, true);
				$files[] = $tmp;
				if (!isset ($letters_files[strtoupper (mbFirstChar (get_songinfo_first($tmp, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0)))]))
					$letters_files[strtoupper (mbFirstChar (get_songinfo_first($tmp, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0)))] = true;
			}
		} else {
			$tmp = do_mpd_command($connection, "listallinfo \"".$ls["file"]."\"", null, true);
			$files[] = $tmp;
			$letters_files[strtoupper (mbFirstChar (get_songinfo_first($tmp, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0)))] = 1;
		}
		$files = array_values($files);
		usort($files, "sort_song");
	}
	$mpd_status = do_mpd_command ($connection, "status", null, true);

	$is_connected = true;
}
?>
