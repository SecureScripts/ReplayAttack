#!/bin/bash
ANDROID_SERIAL="$1"
MAC_SMARTPHONE="$2"
MAC_DEVICE="$3"
INTERFACE="$4"
PACKAGE="$5"

CROP_FUN=$(cat Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)

tap_time="5s"
open_time="10s"

sniffing_time=60
filter='(ether src  $MAC_DEVICE and ether dst $MAC_SMARTPHONE) or (ether dst $MAC_DEVICE and ether src $MAC_SMARTPHONE)'


EXP_FOLDER="Result/$MAC_DEVICE/Experiments/LocalConnectivity"
mkdir -p $EXP_FOLDER

adb -s $ANDROID_SERIAL shell input keyevent 224
sleep 2s


tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$sniffing_time" &

./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Fun_coordinates.txt Fun True $tap_time $open_time


./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True $tap_time $open_time


 wait

python3 CheckLocalConnectivity.py "$EXP_FOLDER/capture.pcap"
