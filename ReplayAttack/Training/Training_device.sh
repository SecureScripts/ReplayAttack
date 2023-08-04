#!/bin/bash
ANDROID_SERIAL="$1"
MAC_SMARTPHONE="$2"
MAC_DEVICE="$3"
INTERFACE="$4"
PACKAGE="$5"

CROP=$(cat Result/$MAC_DEVICE/Capture/crop.txt)
for i in 1
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p $EXP_FOLDER
   
    adb -s $ANDROID_SERIAL shell input keyevent 224 
    sleep 2s
   
   python3 TrainingReplay.py $INTERFACE $MAC_SMARTPHONE $MAC_DEVICE 300 $EXP_FOLDER > $EXP_FOLDER/accuracy.txt &
   ./trigger_functionality_training.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP Result/$MAC_DEVICE/coordinates.txt
   wait
done
