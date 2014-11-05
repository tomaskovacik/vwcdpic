<?
include ('functions.php');
if (array_key_exists("ammount", $_REQUEST)) {
credit($_REQUEST["ammount"]);
}

echo "<center><h1>Current credit=" .credit()."</h1><br />";
echo "<a href='credit.php?ammount=+1'><img src=\"plus.png\" alt=\"PLUS\"></a>";
if (credit()>0) echo "<a href='credit.php?ammount=-1'><img src=\"minus.png\" alt=\"MINUS\"></a></center>";
?>
