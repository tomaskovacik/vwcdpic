#!/bin/bash
josm=~/.josm
pref=${josm}/preferences
pikovina=""

install_josm() {
case ${1}
in 
latest)
echo "installing josm-${1}.jar to /opt/josm"
sudo mkdir -p /opt/josm || echo "mkdir /opt/josm failed"
sudo wget -q http://josm.openstreetmap.de/josm-latest.jar -O /opt/josm/josm.jar
;;
*)
echo "installing josm-tested.jar to /opt/josm"
sudo mkdir -p /opt/josm || echo "mkdir /opt/josm failed"
sudo wget -q http://josm.openstreetmap.de/josm-tested.jar -O /opt/josm/josm.jar
;;
esac
sudo mkdir -p /usr/local/bin/ || echo "mkdir /usr/local/bin/ failed"
 echo "#!/bin/sh
# Simple wrapper script used to start JOSM from Debian package
# add cp1250 encoding for freemapkapor plugin
set -e

# First, the users preference as defined by \$JAVA_HOME. Next, use OpenJDK.
# Override to a specific one using \$JAVACMD
JAVA_CMDS=\"\$JAVA_HOME/bin/java /usr/lib/jvm/java-6-openjdk/bin/java /usr/bin/java\"

for jcmd in \$JAVA_CMDS; do 
    if [ -x \"\$jcmd\" -a -z \"\${JAVACMD}\" ]; then
        JAVACMD=\"\$jcmd\"
    fi
done

if [ \"\$JAVACMD\" ]; then
    echo \"Using \$JAVACMD to execute josm.\"
    exec \$JAVACMD -Dfile.encoding=cp1250 -Xmx512M -jar /opt/josm/josm.jar \"\$@\"
else    
    echo \"No valid JVM found to run JOSM.\"
    exit 1
fi
" | sudo tee /usr/local/bin/josm >/dev/null || echo "tee failed"
sudo chmod +x /usr/local/bin/josm || echo "chmod failed"
echo "Shortcut instaled in main menu: Applications > Science > Josm"
}

install_plugin() {
case ${1}
in
validator)
add_one validator.visible true
;;

freemapkapor)
add_one pluginmanager.sites http://freemapkapor.svn.sourceforge.net/viewvc/freemapkapor/sites/plugin.txt
add_one plugins ${1}
wget -q -O - http://freemapkapor.svn.sourceforge.net/viewvc/freemapkapor/sites/plugin.txt > ~/.josm/plugins/site-freemapkapor.svn.sourceforge.net-_viewvc_freemapkapor_sites_plugin_txt.txt
download_plugin ${1}
;;

slippymap)
add_one pluginmanager.sites http://josm.openstreetmap.de/plugin
add_one plugins ${1}
wget -q -O - http://josm.openstreetmap.de/plugin > ~/.josm/plugins/site-josm.openstreetmap.de-_plugin.txt
download_plugin ${1}
add_slippymap png nlc "/%z/%y/%x.png" "http://gpsteam.eu/cache/nlcmm/"
add_slippymap png nlc_transparent "/%z/%x/%y.png" "http://gpsteam.eu/cache/nlcml/"
add_slippymap png nlc_invert "/%z/%y/%x.png" "http://93.184.70.94:21880/cgi-bin/nlc_invert.fcgi"
add_slippymap png autoaulas@freemap.sk"/%z/%x/%y.png" "http://tiles.freemap.sk/A"
add_slippymap png turistika@freemap.sk "/%z/%x/%y.png" "http://tiles.freemap.sk/T"
add_slippymap png cyklo@freemap.sk"/%z/%x/%y.png" "http://tiles.freemap.sk/C"
replace_one slippymap.max_zoom_lvl 16
replace_one slippymap.min_zoom_lvl 14
replace_one slippymap.tile_source nlc_transparent

;;

wmsplugin)
add_one pluginmanager.sites http://josm.openstreetmap.de/plugin
add_one plugins ${1}
wget -q -O - http://josm.openstreetmap.de/plugin > ~/.josm/plugins/site-josm.openstreetmap.de-_plugin.txt
download_plugin ${1}
add_wms_server KatasterWMS "http://93.184.70.94:21880/cgi-bin/mapserv?request=GetMap&version=1.1.1&styles=&format=image/png&srs=epsg:4326&exceptions=application/vnd.ogc.se_inimage&layers=popis_text,okresy,linie,kladpar,zappar&"
add_wms_server "GMES Urban Atlas" "http://93.184.70.94:21880/cgi-bin/mapserv?request=GetMap&version=1.1.1&styles=&format=image/png&srs=epsg:4326&exceptions=application/vnd.ogc.se_inimage&layers=sk001l_bratislava,sk002l_kosice,sk003l_banska_bystrica,sk004l_nitra,sk005l_presov,sk007l_trnava,sk008l_trencin&"
add_wms_server Landsat "http://onearth.jpl.nasa.gov/wms.cgi?request=GetMap&layers=global_mosaic&styles=&format=image/jpeg&"
add_wms_server "PCL NM34-7" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-7&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM34-8" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-8&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM33-9" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM33-9&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM33-12" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM33-12&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM34-10" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-10&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM34-11" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-11&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "PCL NM34-12" "http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-12&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_wms_server "CLC 2006 100m" "http://93.184.70.94:21880/cgi-bin/mapserv?request=GetMap&version=1.1.1&styles=&format=image/png&srs=epsg:4326&exceptions=application/vnd.ogc.se_inimage&layers=CLC2006-100m&"
;;

imagery)
add_imagery_server "Bing Sat" bing:bing
add_imagery_server Landsat "wms:http://onearth.jpl.nasa.gov/wms.cgi?request=GetMap&layers=global_mosaic&styles=&format=image/jpeg&"
add_imagery_server "Landsat (mirror)" "wms:http://irs.gis-lab.info/?layers=landsat&"
add_imagery_server OpenStreetMap "tms:http://tile.openstreetmap.org/"
add_imagery_server "Yahoo Sat" "html:http://josm.openstreetmap.de/wmsplugin/YahooDirect.html?"
add_imagery_server Kataster-novsi "tms:http://93.184.70.94:21880/tilecache/tilecache.fcgi/1.0.0/kapor2_201105/"
add_imagery_server Kataster "tms:http://93.184.70.94:21880/tilecache/tilecache.fcgi/1.0.0/kapor2/"
add_imagery_server "GMES Urban Atlas" "tms:http://93.184.70.94:21880/tilecache/tilecache.fcgi/1.0.0/urbanatlas/"
add_imagery_server "PCL NM34-7" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-7&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM34-8" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-8&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM33-9" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM33-9&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM33-12" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM33-12&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM34-10" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-10&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM34-11" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-11&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "PCL NM34-12" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&SRS=EPSG:4326&LAYERS=NM34-12&STYLES=default&FORMAT=image/png&TRANSPARENT=TRUE&"
add_imagery_server "CLC 2006 100m" "wms:http://93.184.70.94:21880/cgi-bin/mapserv?request=GetMap&version=1.1.1&styles=&format=image/png&srs=epsg:4326&exceptions=application/vnd.ogc.se_inimage&layers=CLC2006-100m&"
#add_imagery_server "NLC transparent" "tms:http://gpsteam.eu/cache/nlcml/"
add_imagery_server "autoaulas@freemap.sk" "tms:http://tiles.freemap.sk/A"
add_imagery_server "turistika@freemap.sk" "tms:http://tiles.freemap.sk/T"
add_imagery_server "cyklo@freemap.sk" "tms:http://tiles.freemap.sk/C"
#add_imagery_server "NLC" "tms:http://93.184.70.94:21880/cgi-bin/nlc.fcgi/normal"
#add_imagery_server "NLC invert" "tms:http://93.184.70.94:21880/cgi-bin/nlc.fcgi/inv"

;;

*)
add_one pluginmanager.sites http://josm.openstreetmap.de/plugin
add_one plugins $1
wget -q -O - http://josm.openstreetmap.de/plugin > ~/.josm/plugins/site-josm.openstreetmap.de-_plugin.txt
download_plugin $1
;;

esac
}

add_wms_server() {
if ! grep -q wmsplugin.url.[0-9]*.url=${2} ${pref}
then
wms_start=`grep wmsplugin.url.[0-9]*.name= ${pref} | tail -n 1 | sed 's/wmsplugin.url.\([0-9]*\).name.*/\1/'`
sm=`expr ${wms_start} + 1`
echo "wmsplugin.url.${sm}.name=${1}
wmsplugin.url.${sm}.url=${2}" >> ${pref}
fi
}

add_imagery_server() {
if ! grep -q "imagery.layers.[0-9]*=${1}${pikovina}${2}" ${pref}
then
imagery_start=`grep imagery.layers.[0-9]*= ${pref} | tail -n 1 | sed 's/imagery.layers.\([0-9]*\)=.*/\1/'`
if [ "${imagery_start}" == "" ] 
then
sm=0;
else
sm=`expr ${imagery_start} + 1`
fi
echo "imagery.layers.${sm}=${1}${pikovina}${2}" >> ${pref}
fi
}

add_slippymap() {
if ! grep -q slippymap.custom_tile_source_[0-9]*.url=$4 ${pref}
then
sm_start=`grep slippymap.custom_tile_source_[0-9]*.name ${pref} | tail -n 1 | sed 's/slippymap.custom_tile_source_\([0-9]*\)\.name.*/\1/'`
sm=`expr ${sm_start} + 1`
echo "slippymap.custom_tile_source_${sm}.ext=${1}
slippymap.custom_tile_source_${sm}.name=${2}
slippymap.custom_tile_source_${sm}.path=${3}
slippymap.custom_tile_source_${sm}.url=${4}" >> ${pref}
fi
}

download_plugin() {
wget -q `grep $1.jar ~/.josm/plugins/site* |grep -v Plugin-Url|cut -f2 -d\;` -P ${josm}/plugins 1>/dev/null 2>&1 || echo  "download_plugin $1 failed";
}

add_one() {
if ! grep -q ${1}=.*$2.* ${pref}
then
if grep -q ${1}=.* ${pref}
then
tmp=`grep ${1}= ${pref}`${pikovina}${2}
sed -i 's%'${1}'=.*.%'${tmp}'%g' ${pref} >/dev/null || echo "sed add_one_line $1 $2 failed"
else
echo ${1}"="${2} >> ${pref}
fi
fi
}

replace_one() {
if grep -q ${1} ${pref}
then
sed -i 's%'${1}'.*.%'${1}'='${2}'%g' ${pref} >/dev/null || echo "sed add_one_line $1 $2 failed"
else
echo ${1}"="${2} >> ${pref}
fi
}


nastav() {
mkdir -p ${josm}/plugins
touch ${pref}
echo -n "Instaling plugins : "
for plugin in validator freemapkapor imagery buildings_tools SimplifyArea
do
echo -n ${plugin}" " 
install_plugin ${plugin} 
done
echo
add_one taggingpreset.sources http://download.freemap.sk/JOSM/presets_freemap.xml
replace_one pluginmanager.version-based-update.policy always
}

add_desktop() {
echo "[Desktop Entry]
Version=1.0
Name=Josm
Name[SK]=Josm
GenericName=Java OpenStreetMap Editor
GenericName[SK]=Java OpenStreetMap Editor
Comment=Editor for OpenStreetMap.org with freemap.sk customizations
Comment[SK]=Editor pre OpenstreetMap.org s pridanymi nastaveniami Slovenkej komunity (FreeMap.sk)
Exec=josm
Icon=josm
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;" > ~/.local/share/applications/josm.desktop
mkdir -p ~/.local/share/icons/
wget -q http://josm.openstreetmap.de/export/3265/trunk/images/logo.png -O ~/.local/share/icons/josm.png
}

install_josm ${1}
nastav
add_one taggingpreset.sources http://freemap.nodomain.sk/josm/presets_freemap.xml
add_one remotecontrol.enabled true
add_desktop
wget http://freemap.nodomain.sk/bookmarks.php -O ~/.josm/bookmarks
