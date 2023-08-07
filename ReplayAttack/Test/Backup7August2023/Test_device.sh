#!/bin/bash
ANDROID_SERIAL="$1"
MAC_SMARTPHONE="$2"
MAC_DEVICE="$3"
INTERFACE="$4"
PACKAGE="$5"

CROP_FUN=$(cat Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)
for i in 1
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Real_Time/Experiment_$i"
   MODEL_FOLDER="../Training/Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p $EXP_FOLDER
   
   adb -s $ANDROID_SERIAL shell input keyevent 224 
   sleep 2s
   
   echo "CHECK THE INITIAL STATE"
    temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Ground_coordinates.txt Reverse True)
    echo "THE INITIAL STATE IS ${temp##*$'\n'}"
    if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
    then
    	echo "REVERSING THE STATE"
    	./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True
    fi
   
   echo "#############################STARTING PYTHON SNIFFING#####################################"
   #python3 ReplayAttack.py $INTERFACE $MAC_SMARTPHONE $MAC_DEVICE 20 60 $MODEL_FOLDER "./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True" > $EXP_FOLDER/res.txt &

./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Fun_coordinates.txt Fun True #Set false during experiments
   wait
  echo "CHECK GROUND TRUTH"
  ./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Ground_coordinates.txt Fun True


done
