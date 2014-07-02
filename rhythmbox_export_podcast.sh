#!/bin/sh
echo "<?xml version=\"1.0\"?>
<opml version=\"1.0\">
<body>"
for i in `xmlstarlet sel -t -m "/rhythmdb/entry[@type='podcast-feed']" -v location -n ~/.local/share/rhythmbox/rhythmdb.xml`
do
echo "<outline xmlUrl=\""$i"\" />"
done
echo "</body>
</opml>"


