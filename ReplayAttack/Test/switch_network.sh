#!/bin/bash
ANDROID_SERIAL="$1"
INTERFACE="$2"
SSID=$(cat local_networks.txt | grep $INTERFACE | awk '{ print $2 }')
PASSWORD=$(cat local_networks.txt | grep $INTERFACE | awk '{ print $3 }')
#per il check della rete corrente
curr_SSID=$(adb -s $ANDROID_SERIAL shell dumpsys wifi | grep "current SSID")
echo "$curr_SSID"
#echo 'current SSID(s):{iface=wlan0,ssid="iotlab4"}' | cut -d'=' -f 3 | cut -d'"' -f 2
adb shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid $SSID -e password_type WPA -e password $PASSWORD #da verificare che funziona quando la rete è già nota!
#adb shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid SSID
adb -s $ANDROID_SERIAL shell am force-stop com.steinwurf.adbjoinwifi
#per il check della rete corrente dopo il cambio rete
new_SSID=$(adb -s $ANDROID_SERIAL shell dumpsys wifi | grep "current SSID")
echo "$new_SSID"
#per trovare il mac
mac_smartphone=$(adb -s $ANDROID_SERIAL shell ip address show wlan0 | grep  link/ether | awk '{ print $2 }')
echo "$mac_smartphone"
