#!/bin/bash
ANDROID_SERIAL="$1"
MAC_SMARTPHONE="$2"
MAC_DEVICE="$3"
INTERFACE="$4"
PACKAGE="$5"

CROP=$(cat Result/$MAC_DEVICE/Capture/crop.txt)
training_time=300
tap_time="5s"
open_time="10s"


filter="(ether src $MAC_DEVICE and ether dst $MAC_SMARTPHONE)"
for i in 1
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p "$EXP_FOLDER"
   
   adb -s "$ANDROID_SERIAL" shell input keyevent 224
   sleep 2s
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$training_time" &
   ./trigger_functionality_training.sh "$ANDROID_SERIAL" "$PACKAGE" Result/"$MAC_DEVICE"/Capture "$CROP" Result/"$MAC_DEVICE"/coordinates.txt $training_time $tap_time $open_time
   wait
   python3 TrainingReplay.py "$EXP_FOLDER" "$EXP_FOLDER/capture.pcap"  > $EXP_FOLDER/accuracy.txt
done
