#!/bin/bash
ANDROID_SERIAL="$1"
MAC_DEVICE="$2"
INTERFACE="$3"
PACKAGE="$4"


training_times=5
tap_time="5s"
open_time="10s"

tap_number=$(wc -l < ../Test/Result/$MAC_DEVICE/Fun_coordinates.txt)
tshark_time=$((tap_number*5+1+10+10))
tshark_time=$((tshark_time*training_times*2))
echo $tshark_time
#temp=$(./switch_network.sh $ANDROID_SERIAL $INTERFACE)
#MAC_SMARTPHONE="${temp##*$'\n'}"
MAC_SMARTPHONE=$5
#echo $MAC_SMARTPHONE

iptables -I FORWARD 1 -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP


filter="(ether src $MAC_DEVICE and ether dst $MAC_SMARTPHONE)"
for i in 1
do
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Experiment_$i"
   mkdir -p "$EXP_FOLDER"
   
   adb -s "$ANDROID_SERIAL" shell input keyevent 224
   sleep 2s
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$tshark_time" &
   ./trigger_functionality_training.sh "$ANDROID_SERIAL" "$PACKAGE" $training_times $tap_time $open_time $MAC_DEVICE
   wait
   chmod +r "$EXP_FOLDER"/capture.pcap
   python3 TrainingReplay.py "$EXP_FOLDER/capture.pcap" "$EXP_FOLDER"  > $EXP_FOLDER/accuracy.txt
done

chmod -R 777 Result


iptables -D FORWARD 1