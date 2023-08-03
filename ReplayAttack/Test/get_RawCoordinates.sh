#!/bin/bash

PHONE="smartphoneGoogle"

function waitphone {
    while [ -z "$PHONE_FOUND" ]; do
        echo "Phone not found, waiting for $PHONE/$ANDROID_SERIAL"
        sleep 5
       PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL`
    done
}

ANDROID_SERIAL="954AY0U0EE"
echo Phone is: $PHONE/$ANDROID_SERIAL
PHONE_FOUND=`adb devices | grep $ANDROID_SERIAL | grep device`
waitphone
echo Phone ready, proceeding...

mac_device="$1"
name="$2"


 adb -s $ANDROID_SERIAL shell getevent -l > Result/$mac_device/raw_${name}_coordinates.txt

