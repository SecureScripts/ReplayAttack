#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"

CROP_FUN=$(cat Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)

tap_time="5s"
open_time="10s"

sniffing_time=60
delay_time=10


#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5

filter="(ether src  $MAC_DEVICE and ether dst $MAC_SMARTPHONE) or (ether dst $MAC_DEVICE and ether src $MAC_SMARTPHONE)"
for i in {1..5}
do
   result="Experiment Failed"
   COUNTER=0
   while [[ $result != "Experiment Successfully" ]]


   do
   result="Experiment Successfully"
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Real_Time/Experiment_$i"
   MODEL_FOLDER="../Training/Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p $EXP_FOLDER
   
   adb -s $ANDROID_SERIAL shell input keyevent 224 
   sleep 2s
   
   echo "CHECK THE INITIAL STATE"
    temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Ground_coordinates.txt Reverse True $tap_time $open_time)
    echo "THE INITIAL STATE IS ${temp##*$'\n'}"
    if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
    then
    	echo "REVERSING THE STATE"
    	 temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True $tap_time $open_time)
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Experiment Failed"
        result="Experiment Failed: Repeat"
        continue
        fi
    fi
   
   echo "#############################STARTING SNIFFING#####################################"
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$sniffing_time" &
    sleep 10s

    temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Fun_coordinates.txt Fun True $tap_time $open_time)
    wait
    chmod +r "$EXP_FOLDER"/capture.pcap
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Experiment Failed"
        result="Experiment Failed: Repeat"
        continue
        fi

    sleep 5s
   temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_REVERSE Result/$MAC_DEVICE/Reverse_coordinates.txt Reverse True $tap_time $open_time)
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
        echo "Experiment Failed"
        result="Experiment Failed: Repeat"
        continue
        fi
   echo "#############################STARTING ATTACK AFTER DELAY #####################################"
   python3 ReplayAttack.py $EXP_FOLDER/capture.pcap $MAC_SMARTPHONE $MAC_DEVICE $delay_time $MODEL_FOLDER > $EXP_FOLDER/res.txt


  echo "CHECK GROUND TRUTH"
  temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Ground_coordinates.txt Fun True $tap_time $open_time)
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
          COUNTER=$((COUNTER+1))
          echo "Experiment Failed for GROUND TRUTH: Repeat: $COUNTER"
          result="Experiment Failed"
          if [[ "$COUNTER" -gt 2 ]]
          then
            echo "Replay Attack NOT working."
            echo "Replay Attack NOT working"> $EXP_FOLDER/attackResult.txt
            break
          else
            continue
          fi
        else
          echo "Experiment Successfully"
          echo "Replay Attack working"> $EXP_FOLDER/attackResult.txt
          break
        fi

  done

done
