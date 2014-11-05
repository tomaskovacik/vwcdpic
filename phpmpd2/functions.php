<?php
//Creates a link to the given URL, with the frame target and content information specified in the current layout's layoutvars.php
// under $target, with the given title and arguments. (get-vars)
function make_link ($url, $target, $text, $arguments = array(), $hilight = false, $picture = null, $anametarget = null, $title = null) {
	global $layout_vars;
	$firstarg = true;
	echo "<a href=\"".$url;
	foreach ($arguments as $arg => $value) {
		if (is_array ($value)) {
			foreach ($value as $kkey => $vval) {
				echo ($firstarg ? "?" : "&amp;");
				echo $arg."[".$kkey."]=".$vval;
				$firstart = false;
			}
		} else {
			echo ($firstarg ? "?" : "&amp;");
			echo $arg."=".$value;
			$firstarg = false;
		}
	}
	if ($target != "") {
		if ($target == "_top") {
			if ($anametarget != null)
				echo "#".$anametarget;
			echo "\" target=\"_top";
		} elseif ($target == "_blank") {
			if ($anametarget != null)
				echo "#".$anametarget;
			echo "\" target=\"_blank";
		} elseif (array_key_exists($target, $layout_vars["default_targets"])) {
			if ($firstarg) {
				echo "?";
				$firstarg = false;
			} else {
				echo "&amp;";
			}
			echo "content=".$layout_vars["default_targets"][$target]["content"];
			if ($anametarget != null)
				echo "#".$anametarget;
			echo "\"";
			if ($layout_vars["frames"] == true) echo " target=\"".$layout_vars["default_targets"][$target]["frame"];
		}
	} else {
		if ($anametarget != null)
			echo "#".$anametarget;
	}
	if ($hilight == true)
		echo "\" class=\"hilight";
	if ($title != null)
		echo "\" title=\"".$title;
	if ($picture != null) {
		echo "\"><img src=\"".$picture."\" alt=\"".$text."\" /></a>";
	} else {
		echo "\">".$text."</a>";
	}
}

//Creates entry fields for updating non-boolean configuration values, or for entering streams and such.
function make_form ($url, $target, $vars = array(), $method = "post", $submitcaption = "Submit", $intable = true, $trcount = 0) {
	global $layout_vars;
	if (count ($vars) > 0) {
		echo "<form action=\"".$url."\" method=\"".$method;
		if ($target == "_top") {
			echo "\" target=\"_top\">\n";
		} elseif ($target == "_blank") {
			echo "\" target=\"_blank\">\n";
		} else {
			echo "\" target=\"".$target."\">\n<input type=\"hidden\" name=\"content\" value=\"".$layout_vars["default_targets"][$target]["content"]."\" />\n";
		}
		if ($intable == true) {
			$counte = $trcount;
			foreach ($vars as $variable => $value) {
				echo "<input type=\"hidden\" name=\"form_vars[".$counte."]\" value=\"".$variable."\" />";
				echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "").">\n";
				if (is_array ($value)) {
					echo "<td>".str_replace ('_', ' ', $variable)."</td>\n";
					$first = true;
					foreach ($value as $val => $isselected) {
						if (!$first) {
							//$counte++;
							echo "<tr".($counte % 2 != 1 ? " class=\"alt\"" : "")."><td></td>";
						}
						echo "<td><label><input type=\"radio\" name=\"".$variable."\" value=\"".$val."\" ".($isselected == true ? "checked " : "")." class=\"textbox\" />".str_replace ('_', ' ', $val)."</label></td></tr>\n";
						$first = false;
					}
				} elseif (is_bool ($value)) {
						echo "<td><label for=\"".$variable."\">".str_replace ('_', ' ', $variable)."</label></td><td><input type=\"checkbox\" name=\"".$variable."\" value=\"true\" ".($value == true ? "checked " : "")." id=\"".$variable."\" class=\"textbox\" />enable</td>\n";
				} else {
					echo "<td><label>".str_replace('_', ' ', $variable)."</label></td><td><input type=\"text\" class=\"textbox\" name=\"".$variable."\" value=\"".$value."\" id=\"".$variable."\" /></td>";
				}
				echo "</tr>\n";
				$counte++;
			}
			if ($intable) echo "<tr><td><input type=\"submit\" value=\"".$submitcaption."\" class=\"button\" /></td><td> </td></tr>";
		} else {
			foreach ($vars as $variable => $value) {
				if (is_array ($value)) {
					echo str_replace ('_', ' ', $variable).":\n";
					foreach ($value as $val => $isselected) {
						echo "<label><input type=\"radio\" name=\"".$variable."\" value=\"".$val."\" ".($isselected == true ? "checked " : "")."/>".str_replace ('_', ' ', $value)."</label><br />/n";
					}
				} elseif (is_bool ($value)) {
						echo "<label><input type=\"checkbox\" name=\"".$variable."\" value=\"true\" ".($value == true ? "checked " : "")."/>".str_replace ('_', ' ', $variable)."</label>\n";
				} else {
					echo "<label>".str_replace('_', ' ', $variable).":</label> <input type=\"text\" name=\"".$variable."\" value=\"".$value."\" id=\"".$variable."\" />";
				}
				echo "<br />\n";
			}
			echo "<input type=\"submit\" value=\"".$submitcaption."\" class=\"button\" />";
		}
		echo "\n</form>\n";
	}
}

//Creates links to a series of directories, breaking at each "/".
function dir_links ($dir) {
	if (strlen($dir) > 0) {
		make_link ("", "files", "Music", array ("directory" => ""));
		$bit = strtok ($dir, "/");
		$cdir = $bit;
		while ($bit) {
			echo " / ";
			make_link ("", "files", $bit, array ("directory" => $cdir));
			$bit = strtok ("/");
			$cdir = $cdir."/".$bit;
		}
	} else {
		make_link ("", "files", "Music", array ("directory" => ""));
	}
}

//Loads configuration variables from cookies.
function load_config_cookies($cookies) {
	global $configuration;
	foreach($cookies as $key => $value) {
		if(strncmp($key, "phpMp_config_", strlen("phpMp_config_")) == 0) {
			if($value == "true")
				$configuration[substr($key, strlen("phpMp_config_"))] = true;
			elseif($value == "false")
				$configuration[substr($key, strlen("phpMp_config_"))] = false;
			else
				$configuration[substr($key, strlen("phpMp_config_"))] = $value;
		}
	}
}

//Creates a cookie holding a configuration value.
function make_config_cookie($key, $value) {
	if (is_array ($value)) {
		foreach ($value as $valkey => $valval) {
			setcookie("phpMp_config_".$key."[".$valkey."]", $valval);
		}
	} else {
		setcookie("phpMp_config_".$key, $value);
	}
}

//Destroys a configuration cookie.
function eat_config_cookie($key) {
	setcookie("phpMp_config_".$key, "", time() - 3600);
}

//Parses information returned by mpd.
function parse_mpd_var($in_str) {
	$got = trim($in_str);
	if(!isset($got))
		return null;
	if(strncmp("OK", $got,strlen("OK"))==0) 
		return true;
	if(strncmp("ACK", $got,strlen("ACK"))==0) {
		str_replace("\n", "\n<br />", $got);
		print $got."<br />";
		return true;
	}
	$key = trim(strtok($got, ":"));
	$val = trim(strtok("\0"));
	return array(0 => $key, 1 => $val);
}

//Sends a command to mpd and parses the results.
function do_mpd_command($conn, $command, $varname = null, $return_array = false) {
	$retarr = array();
	fputs($conn, $command."\n");
	while(!feof($conn)) {
		$var = parse_mpd_var(fgets($conn, 1024));
		if(isset($var)){
			if($var === true && count($retarr) == 0)
				return true;
			if($var === true)
				break;
			if(isset($varname) && strcmp($var[0], $varname)) {
				return $var[1];
			} elseif($return_array == true) {
				if(array_key_exists($var[0], $retarr)) {
					if(is_array($retarr[($var[0])])) {
						array_push($retarr[($var[0])], $var[1]);
					} else {
						$tmp = $retarr[($var[0])];
						$retarr[($var[0])] = array($tmp, $var[1]);
					}
				} else {
					$retarr[($var[0])] = $var[1];
				}
			}
		}
	}
	return $retarr;
}

//Sends a command list to mpd and returns true if it was successful.
function do_mpd_command_list($conn, $command, $arglist) {
	fputs($conn, "command_list_begin\n");
	foreach($arglist as $key => $arg) {
		fputs($conn, $command." ".$arg."\n");
	}
	fputs($conn, "command_list_end\n");
	while(!feof($conn)) {
		$var = parse_mpd_var(fgets($conn, 1024));
		if(isset($var)){
			if($var === true)
				return true;
		}
	}
	return false;
}

//Creates a slider of length $length that can vary $var from $min to $max, hilighted up to the point of $current.
// If $intonly is true, it rounds off each segment to the nearest integer.
function create_slider($current, $min, $max, $length, $var, $intonly = false, $istime = false) {
	global $configuration, $layout_vars;
	if($configuration["graphical_sliders"] == true && style_slider_image() == true && function_exists("imagecreatetruecolor")) {
		echo "<form method=\"get\">\n";
		echo "<input type=\"hidden\" name=\"sliderlength\" value=\"".$length."\" />\n";
		echo "<input type=\"hidden\" name=\"slidermin\" value=\"".$min."\" />\n";
		echo "<input type=\"hidden\" name=\"slidermax\" value=\"".$max."\" />\n";
		echo "<input type=\"hidden\" name=\"slidercommand\" value=\"".$var."\" />\n";
		echo "<input type=\"hidden\" name=\"sliderintonly\" value=\"".($intonly ? "true" : "false")."\" />\n";
		if (array_key_exists ("content", $_REQUEST)) echo "<input type=\"hidden\" name=\"content\" value=\"".$_REQUEST["content"]."\" />\n";
		echo "<input type=\"image\" alt=\"[slider]\" src=\"slider.php?imagedark=".style_slider_image("dark")."&amp;imagelight=".style_slider_image("light")."&amp;length=".$length."&amp;value=".$current."&amp;min=".$min."&amp;max=".$max."\" name=\"slider\">\n</form>";
	} else {
		echo "<div style=\"width: ".($length + 4)."px\">";
		for($segment = 0; $segment <= intval($length/4); $segment++) {
			$pos = $segment * 4 * (($max - $min) / $length);
			echo "<a href=\"?command=".$var."&amp;arg=".($intonly ? intval($pos) : $pos).(array_key_exists("content", $_REQUEST) ? "&content=".$_REQUEST["content"] : "")."\" title=\"".($istime ? intval($pos/60).":".intval($pos)%60: ($intonly ? intval($pos) : $pos))."\" class=\"".($pos <= $current ? "sliderlite" : "sliderdark")."\"> </a>\n";
		}
		echo "</div>";
	}
}

//Returns a song title string formatted according to $format (see config.php) derived from the information in $songinfo.
function format_song_title($format, $songinfo, $number = null) {
	global $configuration;
	$output = $format;
	$tags = explode("[", $output);
	if($tags) {
		foreach($tags as $key => $tag_raw) {
			$tag = substr($tag_raw, 0, strpos($tag_raw, "]"));
			if(strlen($tag) > 0) {
				switch($tag) {
				case "Number":
					if($number != null) {
						$replace = $number;
					} else {
						$replace = null;
					}
					break;
				case "Title":
					$replace = (array_key_exists($tag, $songinfo) ? htmlspecialchars($songinfo[$tag]) : ($configuration["filenames_replace_underscores"] ? str_replace('_',' ', htmlspecialchars($songinfo["file"])) : htmlspecialchars($songinfo["file"])));
					break;
				default:
					$replace = (array_key_exists($tag, $songinfo) ? htmlspecialchars($songinfo[$tag]) : $configuration["unknown_string"]);
				}
				if($replace != null)
					$output = str_replace("[".$tag."]", $replace, $output);
			}
		}
	}
	return $output;
}

//Formats a time given in seconds.
function format_time($seconds) {
	$hrs = intval($seconds/(60*60));
	$min = intval($seconds/60) - ($hrs * 60);
	$sec = $seconds - ($min * 60) - ($hrs * 60 * 60);
	return ($hrs > 0 ? strval($hrs).":".str_pad(strval($min), 2, "0", STR_PAD_LEFT) : strval($min)).":".str_pad(strval($sec), 2, "0", STR_PAD_LEFT);
}

//Makes a table of index letters.
function make_index_table($letters_arr, $prefix, $make_table = true) {
	if(count($letters_arr) > 0) {
		$letters = array_keys($letters_arr);
		natcasesort($letters);
		$letters = array_flip($letters);
		if ($make_table)
			echo "<table cellspacing=\"0\"><tr class=\"nobg\">\n";
		else
			echo "[ ";
		foreach($letters as $letter => $truth) {
			if ($make_table)
				echo "<td class=\"nobg\" style=\"width: 2em\">";
			echo "<a href=\"#".$prefix.$letter."\">".$letter." </a>";
			if ($make_table)
				echo "</td>\n";
		}
		if ($make_table)
			echo "<td class=\"nobg\" style=\"width: 100%\"></td></tr></table>\n";
		else
			echo "]";
	}
}

//Returns the first character of a multibyte string.
function mbFirstChar($str) {
	if (strlen ($str) > 0) {
		$i = 1;
		$ret = "$str[0]";
		while($i < strlen($str) && ord($str[$i]) >= 128  && ord($str[$i]) < 192) {
			$ret.=$str[$i];
			$i++;
		}
		return $ret;
	} else {
		return "";
	}
}

//Sorts two given songs according to the sortorder given in $configuration.
function sort_song ($a, $b) {
	global $configuration;
	return sort_songinfo ($a, $b, isset($configuration["sort"]) ? $configuration["sort"] : array("file"), 0);
}

//Helper function for sort_song.
function sort_songinfo ($a, $b, $sort_history, $depth) {
	if ($a == $b)
		return 0;
	if ($depth >= count($sort_history)) return strnatcasecmp ($a["file"], $b["file"]);
	$sortname = $sort_history[$depth];
	if (array_key_exists ($sortname, $a)) {
		if (array_key_exists ($sortname, $b)) {
			return strnatcasecmp ($a[$sortname], $b[$sortname]);
		} else {
			return 1;
		}
	} else {
		if (array_key_exists ($sortname, $b)) {
			return -1;
		} else {
			return sort_songinfo ($a, $b, $sort_history, $depth + 1);
		}
	}
}

//Returns the first value in the sort order that is set in $info.
function get_songinfo_first ($info, $sort_history, $depth) {
	if (count ($sort_history) > $depth) {
		$sortname = $sort_history[$depth];
		if (array_key_exists ($sortname, $info)) {
			return $info[$sortname];
		} else {
			return get_songinfo_first ($info, $sort_history, $depth + 1);
		}
	} else {
		return "";
	}
}
function credit($ammount="0"){
	$file = "credit.txt";
	$credit = file_get_contents($file);
	switch ($ammount){
	case "0":return $credit;break;
	default: $credit=$credit+$ammount;
	}
	if (file_put_contents($file, $credit)) {
		return true;
	} else {
		return false;
	}
}

?>
