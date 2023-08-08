#!/bin/bash
ANDROID_SERIAL="$1"
INTERFACE="$2"
SSID=$(cat local_networks.txt | grep $INTERFACE | awk '{ print $2 }')
PASSWORD=$(cat local_networks.txt | grep $INTERFACE | awk '{ print $3 }')

echo "SSID=$SSID"
echo "PASSWORD=$PASSWORD"

#forget all the networks
adb -s $ANDROID_SERIAL shell am start -n 'com.adbwifisettingsmanager/.WifiSettingsManagerActivity' --esn remove -e ssid 'all'
sleep 5s
adb -s $ANDROID_SERIAL shell am force-stop com.adbwifisettingsmanager

#disable wifi
adb -s $ANDROID_SERIAL shell 'am start -n 'com.adbwifisettingsmanager/.WifiSettingsManagerActivity' --esn disableWifi'
sleep 5s
#spegni app
adb -s $ANDROID_SERIAL shell am force-stop com.adbwifisettingsmanager
check=$(adb -s $ANDROID_SERIAL shell ip address show wlan0 | grep "inet ")
echo "after disabling the ip address is $check"

#enable wifi
adb -s $ANDROID_SERIAL shell 'am start -n 'com.adbwifisettingsmanager/.WifiSettingsManagerActivity' --esn enableWifi'
sleep 5s
#spegni app
adb -s $ANDROID_SERIAL shell am force-stop com.adbwifisettingsmanager
check=$(adb -s $ANDROID_SERIAL shell ip address show wlan0 | grep "inet ")
echo "after enabling the ip address is $check"

#per il check della rete corrente
curr_SSID=$(adb -s $ANDROID_SERIAL shell dumpsys wifi | grep "current SSID")
echo $curr_SSID
#echo 'current SSID(s):{iface=wlan0,ssid="iotlab4"}' | cut -d'=' -f 3 | cut -d'"' -f 2
adb -s $ANDROID_SERIAL shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid $SSID -e password_type WPA -e password $PASSWORD #da verificare ch>#adb -s $ANDROID_SERIAL shell am start -n com.steinwurf.adbjoinwifi/.MainActivity -e ssid $SSID
sleep 5s
adb -s $ANDROID_SERIAL shell am force-stop com.steinwurf.adbjoinwifi
#per il check della rete corrente dopo il cambio rete
new_SSID=$(adb -s $ANDROID_SERIAL shell dumpsys wifi | grep "current SSID")
echo $new_SSID
#to see if there is an ip address
check=$(adb -s $ANDROID_SERIAL shell ip address show wlan0 | grep "inet ")
echo $check
#per trovare il mac
mac_smartphone=$(adb -s $ANDROID_SERIAL shell ip address show wlan0 | grep  link/ether | awk '{ print $2 }')
echo $mac_smartphone
