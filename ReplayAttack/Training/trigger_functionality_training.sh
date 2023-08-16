#!/bin/bash

PHONE="smartphoneGoogle"


function waitphone {
    while [ -z "$PHONE_FOUND" ]; do
        echo "Phone not found, waiting for $PHONE/$ANDROID_SERIAL"
        sleep 5
       PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL`
    done
}

ANDROID_SERIAL="$1"
echo Phone is: $PHONE/$ANDROID_SERIAL
PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL | grep device`
waitphone
echo Phone ready, proceeding...

PACKAGE="$2"



training_time="$3"

tap_time="$4"

open_time="$5"

CROP_FUN=$(cat ../Test/Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat ../Test/Result/$MAC_DEVICE/Capture/Reverse_crop.txt)


end=$((SECONDS+$training_time))
while  [ $SECONDS -lt $end ]; do

temp=$(../Test/trigger_functionality_testing.sh "$ANDROID_SERIAL" "$PACKAGE" ../Test/Result/$MAC_DEVICE/Capture $CROP_FUN ../Test/Result/$MAC_DEVICE/Fun_coordinates.txt Fun True $tap_time $open_time)
 if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Something goes wrong"
 fi
sleep 2s
temp=$(../Test/trigger_functionality_testing.sh "$ANDROID_SERIAL" "$PACKAGE" ../Test/Result/$MAC_DEVICE/Capture $CROP_REVERSE ../Test/Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True $tap_time $open_time)
 if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Something goes wrong"
 fi
done
