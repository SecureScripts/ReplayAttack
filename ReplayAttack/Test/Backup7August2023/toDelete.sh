#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
PACKAGE="$3"
file="./temp.txt"
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)
while [ True ]; do
  content=$(cat $file)
  if [[ $content == "END SNIFFING TIME" ]]
  then
    ./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse
    rm $file
    break
  else
    sleep 1s
  fi
done
