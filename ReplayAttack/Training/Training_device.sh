#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"


training_time=300
tap_time="5s"
open_time="10s"




#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5
#echo $MAC_SMARTPHONE

filter="(ether src $MAC_DEVICE and ether dst $MAC_SMARTPHONE)"
for i in {1..5}
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p "$EXP_FOLDER"
   
   adb -s "$ANDROID_SERIAL" shell input keyevent 224
   sleep 2s
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$training_time" &
   ./trigger_functionality_training.sh "$ANDROID_SERIAL" "$PACKAGE" $training_time $tap_time $open_time $MAC_DEVICE
   wait
   python3 TrainingReplay.py "$EXP_FOLDER/capture.pcap" "$EXP_FOLDER"  > $EXP_FOLDER/accuracy.txt
done
