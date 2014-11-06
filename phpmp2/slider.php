<?php
$imgerr = @imagecreate (100, 75)
	or die("Cannot Initialize new GD image stream");
$bgc = ImageColorAllocate ($imgerr, 0, 0, 0);
$tc  = ImageColorAllocate ($imgerr, 255, 255, 255);
ImageFilledRectangle ($imgerr, 0, 0, 100, 75, $bgc);
$imgh = @imagecreatetruecolor ($_GET["length"], 16)
	or die("Cannot Initialize new GD image stream");
$bgch = ImageColorAllocate ($imgh, 0, 0, 0);
if (!array_key_exists("imagedark", $_GET) || !array_key_exists("imagelight", $_GET)) {
	$error = true;
	ImageString ($imgerr, 1, 50 - (ImageFontWidth(1) * strlen($filename)) / 2, 1, "No file specified.", $tc);
} else {
	if (file_exists ($_GET["imagedark"])) {
		if (file_exists ($_GET["imagelight"])) {
			$imgdark = @ImageCreateFromPNG ($_GET["imagedark"]);
			$imglight = @ImageCreateFromPNG ($_GET["imagelight"]);
			imagedestroy($imgerr);
			if ($_GET["value"] <= $_GET["min"]) {
				imagecopyresized ( $imgh, $imgdark, 0, 0, 0, 0, imagesx ($imgh), imagesy ($imgh), imagesx ($imgdark), imagesy ($imgdark));
			} elseif ($_GET["value"] >= $_GET["max"]) {
				imagecopyresized ( $imgh, $imglight, 0, 0, 0, 0, imagesx ($imgh), imagesy ($imgh), imagesx ($imglight), imagesy ($imglight));
			} else {
				imagecopyresized ( $imgh, $imglight, 0, 0, 0, 0, imagesx ($imgh) * ($_GET["value"] / ($_GET["max"] - $_GET["min"])), imagesy ($imgh), imagesx ($imglight), imagesy ($imglight));
				imagecopyresized ( $imgh, $imgdark, imagesx ($imgh) * ($_GET["value"] / ($_GET["max"] - $_GET["min"])), 0, 0, 0, imagesx ($imgh), imagesy ($imgh), imagesx ($imgdark), imagesy ($imgdark));
			}
		} else {
			$error = true;
			ImageString ($imgerr, 1, 50 - (ImageFontWidth(1) * strlen($filename)) / 2, 1, $_GET["imagelight"], $tc);
			ImageString ($imgerr, 1, 50 - (ImageFontWidth(1) * strlen($filename)) / 2, 10, "does not exist.", $tc);
		}
	} else {
		$error = true;
		ImageString ($imgerr, 1, 50 - (ImageFontWidth(1) * strlen($filename)) / 2, 1, $_GET["imagedark"], $tc);
		ImageString ($imgerr, 1, 50 - (ImageFontWidth(1) * strlen($filename)) / 2, 10, "does not exist.", $tc);
	}
}

if (isset ($error)) {
	$imgh = $imgerr;
}

if (function_exists("imagepng")) {
	Header("Content-type: image/png");
	ImagePNG($imgh);
}
elseif (function_exists("imagejpeg")) {
	Header("Content-type: image/jpeg");
	ImageJPEG($imgh, "", 0.5);
}
elseif (function_exists("imagewbmp")) {
	Header("Content-type: image/vnd.wap.wbmp");
	ImageWBMP($imgh);
}
else
	die("No image support in this PHP server");

if(isset($imgerr)) imagedestroy($imgerr);
if(isset($imgh)) imagedestroy($imgh);
if(isset($imgdark)) imagedestroy($imgdark);
if(isset($imglight)) imagedestroy($imglight);
?>
