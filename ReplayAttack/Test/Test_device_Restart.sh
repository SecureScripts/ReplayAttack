#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"

CROP_FUN=$(cat Result/$MAC_DEVICE/Capture/Fun_crop.txt)
CROP_REVERSE=$(cat Result/$MAC_DEVICE/Capture/Reverse_crop.txt)

tap_time="5s"
open_time="10s"
delay_time=10


#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5

#temp_target_ip_address=$(arp -a | grep $MAC_DEVICE | awk '{print $2}')
#let len=${#temp_target_ip_address}-1
#IP_DEVICE=$(cut -c 2-$len <<< $temp_target_ip_address)
#iptables -I FORWARD 1 -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -I FORWARD 2 -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE
#trap 'iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP; iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE' SIGINT
PLUG_NAME=$6

tap_number=$(wc -l < Result/$MAC_DEVICE/Fun_coordinates.txt)
sniffing_time=$((tap_number*5+1+10+10))



filter="(ether src  $MAC_DEVICE and ether dst $MAC_SMARTPHONE) or (ether dst $MAC_DEVICE and ether src $MAC_SMARTPHONE)"
START=1
END=1


./CaptureFunctionality.sh $ANDROID_SERIAL $MAC_DEVICE $INTERFACE $PACKAGE $MAC_SMARTPHONE $PLUG_NAME

for (( i=$START; i<=$END; i++ ))
do
   result="Experiment Failed"
   COUNTER=0
   while [[ $result != "Experiment Successfully" ]]


   do
   result="Experiment Successfully"
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Delayed/Experiment_$i"
   MODEL_FOLDER="../Training/Result/$MAC_DEVICE/Experiments/Experiment_1"
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
   



   echo "#############################STARTING ATTACK AFTER DELAY #####################################"
   python3 ReplayAttack.py Result/$MAC_DEVICE/Experiments/Delayed/capture.pcap $MAC_SMARTPHONE $MAC_DEVICE $delay_time $MODEL_FOLDER > $EXP_FOLDER/res.txt


  echo "CHECK GROUND TRUTH"
  temp=$(./trigger_functionality_testing.sh $ANDROID_SERIAL $PACKAGE Result/$MAC_DEVICE/Capture $CROP_FUN Result/$MAC_DEVICE/Ground_coordinates.txt Fun True $tap_time $open_time)
        if [[ "${temp##*$'\n'}" != "Comparison ok" ]]
        then
          COUNTER=$((COUNTER+1))
          echo "Experiment Failed for GROUND TRUTH: Repeat: $COUNTER"
          result="Experiment Failed"
          if [[ "$COUNTER" -gt 3 ]]
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

chmod -R 777 Result
python3 getAccuracy.py "Result/$MAC_DEVICE/Experiments/Delayed/" "$END"> Result/$MAC_DEVICE/Experiments/Delayed/Final_res.txt

#iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE

